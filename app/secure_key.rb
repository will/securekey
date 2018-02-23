require 'bundler'
Bundler.require
require 'sequel'
require 'securerandom'

module SecureKey
  DB = Sequel.connect ENV['DATABASE_URL'] || 'postgres:///secure_key'
  def self.generate
    SecureRandom.hex(32).upcase
  end
end

require_relative 'user'

