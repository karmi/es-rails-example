ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup
    super
    StackExchange::IndexManager.create_index force: true
    StackExchange::IndexManager.import

    Question.__elasticsearch__.refresh_index!
  end
end
