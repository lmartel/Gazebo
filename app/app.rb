require 'rubygems'
require 'sinatra/base'
require 'sequel'
# require 'sqlite3'

class TrackTracker < Sinatra::Base

	DB_URL = 'sqlite://test.db'

	get '/' do
		erb :index
	end
end

require_relative 'init'
