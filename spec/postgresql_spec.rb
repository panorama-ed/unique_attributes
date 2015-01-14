require "spec_helper"
require "shared/unique_attributes_examples"

RSpec.describe "PostgreSQL" do
  before :all do
    ActiveRecord::Base.establish_connection(:postgresql_test)
    TestSetupMigration.migrate(:up)
  end

  include_examples ".unique_attribute"

  after :all do
    ActiveRecord::Base.remove_connection
  end
end
