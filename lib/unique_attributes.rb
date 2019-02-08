require "unique_attributes/version"

require "active_support/concern"

# UniqueAttributes provides the unique_attribute method to assign a unique
# attribute to the given model, using the passed block.

# Example: unique_attribute :code { SecureRandom.random_number(1000) }

module UniqueAttributes
  extend ActiveSupport::Concern

  # If we try saving an object 50 times and it fails each time, raise an error.
  # This should be high enough to handle even fairly collision-prone attribute
  # generation algorithms.
  SAVE_ATTEMPTS_LIMIT = 50

  included do # rubocop:disable Metrics/BlockLength
    class_attribute :unique_attributes
    self.unique_attributes = ({})

    # Indicate that a given attribute is unique and should be auto-assigned with
    # the given block.
    # @param name [Symbol] the name of the ActiveRecord attribute
    # @param block [Proc] the code to use to auto-assign the attribute
    # @param scope the scope to limit uniqueness by for the attribute; uses the
    #   same format as Rails' `validates *, uniqueness: { scope: __ }` pattern.
    def self.unique_attribute(name, block, scope: nil)
      unique_attributes[name] = block # Store the proc for this attribute.

      # Use a uniqueness scope if one is passed; otherwise have global
      # uniqueness.
      uniqueness_options = scope ? { scope: scope } : true

      # Note: This is restricted to update only since the attribute value is not
      # generated until we save the model the first time. The around_save
      # callback happens after validation, but before saving, so we need to make
      # it past validation at least one time before checking for a valid code.
      validates name, uniqueness: uniqueness_options, on: :update
      validates name, presence: true, on: :update

      # Assign all unique attributes when saving.
      # Note that even if we call unique_attribute more than once within a
      # class, Rails only runs this around_save logic once per save, so we
      # therefore need the around_save logic to handle *all* unique attributes
      # (not just the one defined in this method).
      around_save :save_with_unique_attributes
    end

    private

    # @return [Hash] the subset of the unique attributes hash for which we have
    #   no values set.
    def blank_unique_attributes
      self.class.unique_attributes.select { |k| send(k).nil? }
    end

    # Ensures that the attribute value exists and is unique (relying on a
    # database-level unique index) when saving. This will set the value on the
    # first save of the object.
    def save_with_unique_attributes
      blank_attrs = blank_unique_attributes

      # If we have blank unique attributes.
      if !blank_attrs.empty?
        attempts = 0
        attr_group = "(?<attr>#{blank_attrs.keys.join('|')})"
        other_fields = "(, [\\w`'\".]+)*"

        # Keep retrying until the save works.
        until persisted?
          attempts += 1 # Keep track of the number of times we've tried to save.

          # Set each of the blank attributes with the given blocks.
          blank_attrs.each { |attr, block| write_attribute(attr, block.call) }

          begin
            ActiveRecord::Base.transaction(requires_new: true) do
              yield # Perform the save, and see if it works.
            end
          rescue ActiveRecord::RecordNotUnique => error
            if attempts <= SAVE_ATTEMPTS_LIMIT # rubocop:disable Metrics/BlockNesting
              match = [
                # Postgres
                /Key \(#{attr_group}#{other_fields}\)=\([\w\s,]*\) already exists/, # rubocop:disable Metrics/LineLength
                # SQLite
                /column(s)? #{attr_group}#{other_fields} (is|are) not unique/,
                /UNIQUE constraint failed: #{self.class.table_name}\.#{attr_group}#{other_fields}:/ # rubocop:disable Metrics/LineLength
              ].inject(nil) { |m, regex| m || regex.match(error.message) }

              # If we've managed to hit the same unique attribute of a record
              # already in the database, then we should wipe the attribute and
              # try again
              if match # rubocop:disable Metrics/BlockNesting
                attr = match[:attr].to_sym
                blank_attrs = { attr => self.class.unique_attributes[attr] }
                write_attribute(attr, nil)
                next
              end
            end

            # If we're already at the attempts limit, or some other attribute
            # was the problem, let the error propagate.
            raise error
          end
        end
      else # If the unique values are already set, perform a regular save.
        yield
      end
    end
  end
end
