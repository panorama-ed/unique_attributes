require "spec_helper"
require "shared/unique_attributes_examples"
require "config/test_setup_migration"

RSpec.describe "SQLite3" do
  before :all do
    ActiveRecord::Base.establish_connection(:sqlite3_test)
    TestSetupMigration.migrate(:up)
  end

  include_examples ".unique_attribute"

  after :all do
    ActiveRecord::Base.remove_connection
  end
end
