require 'bundler'
Bundler.require
require './env'
require 'sequel'
require 'securerandom'

module SecureKey
  DB = Sequel.connect ENV['DATABASE_URL'] || 'postgres:///secure_key'
  def self.generate
    SecureRandom.random_number(2**256).to_s(36)
  end
end

require_relative 'user'

