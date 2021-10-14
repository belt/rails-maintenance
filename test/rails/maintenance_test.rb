require "test_helper"

class Rails::MaintenanceTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Rails::Maintenance::VERSION
  end
end
