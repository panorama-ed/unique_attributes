require "spec_helper"

require "support/multiattribute_test_class"
require "support/scoped_test_class"
require "support/test_class"

RSpec.shared_examples ".unique_attribute" do
  let(:obj1) { TestClass.new(other_field: "Foo") }
  let(:obj2) { TestClass.new(other_field: "Bar") }

  it "generates a value when saving" do
    obj1.save!
    expect(obj1.autogenerated_username).to_not be_nil
  end

  it "does not overwrite a value that is manually set" do
    obj1.autogenerated_username = "Dummy"
    expect(obj1.autogenerated_username).to eq "Dummy"
  end

  it "does not generate a new value when saved multiple times" do
    obj1.save!
    val = obj1.autogenerated_username

    obj1.other_field = "A" # Set another field to force the object to save.
    obj1.save!

    # Check that the autogenerated field doesn't change.
    expect(obj1.autogenerated_username).to eq val
  end

  it "generates a new value if the one generated is already taken" do
    allow(TestClass).to receive(:generate_username).and_return("1", "1", "2")

    obj1.save!
    obj2.save!

    expect(obj1.autogenerated_username).to eq "1"
    expect(obj2.autogenerated_username).to eq "2"
  end

  it "raises an error if updated to an existing one" do
    obj1.save!
    obj2.save!

    # Update obj2's value to obj1's to create a uniqueness collision.
    obj2.autogenerated_username = obj1.autogenerated_username

    expect { obj2.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "respects the scope argument" do
    allow(ScopedTestClass).to receive(:generate_username).
      and_return("1", "1", "1", "1", "2")

    obj1 = ScopedTestClass.create!(other_field: "A")
    obj2 = ScopedTestClass.create!(other_field: "B")
    obj3 = ScopedTestClass.create!(other_field: "A")

    expect(obj1.autogenerated_username).to eq "1"
    expect(obj2.autogenerated_username).to eq "1"
    expect(obj3.autogenerated_username).to eq "2"
  end

  it "does not retry the save when an unrelated uniqueness violation occurs" do
    expect(TestClass).to receive(:generate_username).
      exactly(2).times.
      and_call_original

    obj1.save!
    obj2.other_field = obj1.other_field

    # This will raise an error because a database unique index ensures that
    # other_field is unique.
    expect { obj2.save! }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "raises the error when an unrelated non-uniqueness error occurs" do
    obj1.other_field = nil

    # This will raise an error because a database constraint ensures that
    # other_field is not NULL.
    expect { obj1.save! }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "raises the unique violation error if we've tried saving too many times" do
    # Stub out the username generation function to always cause collisions.
    allow(TestClass).to receive(:generate_username).and_return("1")

    obj1.save!

    # After retrying the save many times, we will eventually raise an error.
    expect { obj2.save! }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  context "when model has multiple unique_attribute fields" do
    it "only retries fields as needed" do
      # We stub the username/password generation such that the first two
      # usernames generated collide but the passwords do not. We use
      # expectations to ensure that the username is re-generated but the
      # password is not.
      expect(MultiattributeTestClass).to receive(:generate_username).
        exactly(3).times.
        and_return("1", "1", "2")
      expect(MultiattributeTestClass).to receive(:generate_password).
        exactly(2).times.
        and_return("A", "B")

      MultiattributeTestClass.create!
      MultiattributeTestClass.create!
    end

    context "when there's more than one conflict" do
      it "retries all conflicting fields" do
        # We stub the username/password generation such that the first time both
        # username and password are generated, there are conflicts. We use
        # expectations to ensure that both fields are re-generated as needed.
        expect(MultiattributeTestClass).to receive(:generate_username).
          exactly(3).times.
          and_return("1", "1", "2")
        expect(MultiattributeTestClass).to receive(:generate_password).
          exactly(3).times.
          and_return("A", "A", "B")

        MultiattributeTestClass.create!
        MultiattributeTestClass.create!
      end
    end
  end
end
