require 'rspec'
require './app/secure_key'
require 'database_cleaner'
require 'webmock/rspec'
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:sequel].strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner[:Sequel].clean
  end
end

