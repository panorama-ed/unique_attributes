# frozen_string_literal: true

require "spec_helper"
require "shared/unique_attributes_examples"
require "config/test_setup_migration"

RSpec.describe "SQLite3" do
  before :all do # rubocop:disable RSpec/BeforeAfterAll
    ActiveRecord::Base.establish_connection(:sqlite3_test)
    TestSetupMigration.migrate(:up)
  end

  after :all do # rubocop:disable RSpec/BeforeAfterAll
    ActiveRecord::Base.remove_connection
  end

  include_examples ".unique_attribute"
end
