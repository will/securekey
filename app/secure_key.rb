require 'bundler'
Bundler.require
require './env'
require 'sequel'

module SecureKey
  DB = Sequel.connect ENV['DATABASE_URL'] || 'postgres:///secure_key'
end

require_relative 'user'

