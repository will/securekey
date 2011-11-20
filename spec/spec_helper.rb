require 'rspec'
require './app/secure_key'
require 'webmock/rspec'
require 'timecop'
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    db = Sequel::Model.db
    (db.tables - [:schema_info, :schema_migrations]).each do |table|
      db[table].truncate
    end
  end
end

