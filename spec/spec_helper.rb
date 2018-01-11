require 'rspec'
require './app/secure_key'
require 'webmock/rspec'
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  def clean!
    db = Sequel::Model.db
    (db.tables - [:schema_info, :schema_migrations]).each do |table|
      db[table].truncate
    end
  end
  config.before(:suite) { clean! }
  config.before(:each) do
    @start = Sequel::Model.db['select txid_current()'].first[:txid_current]
  end
  config.after(:each) do
    if (Sequel::Model.db['select txid_current()'].first[:txid_current] - @start) > 1
      clean!
    end
  end
end

