require 'rspec'
require './app/secure_key'
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:sequel].strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner[:Sequel].clean
  end
  config.after(:each) do
    #DatabaseCleaner[:sequel].clean
  end

end

