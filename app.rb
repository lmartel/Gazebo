require 'rubygems'
require 'sinatra'
require 'sequel'
require 'sqlite3'

require './seeds.rb'

DB = Sequel.connect('sqlite://test.db')
Sequel::Model.plugin :schema

# Doesn't work with schema generator
# class Model < Sequel::Model

# 	@@models = []
# 	def self.models
# 		@@models
# 	end

# 	def self.inherited(subclass)
# 		@@models << subclass
# 		super
# 	end
# end

class Department < Sequel::Model
	one_to_many :tracks
	one_to_many :courses

	def before_save
		name.upcase!
	end

	set_schema do 
		primary_key :id
		String :name, null: false
	end
end

class Track < Sequel::Model
	many_to_one :department
	one_to_many :requirements

	set_schema do
		primary_key :id
		String :name, null: false
		foreign_key :department_id, :departments
	end
end

class Requirement < Sequel::Model
	many_to_many :courses
	many_to_one :track

	set_schema do
		primary_key :id
		String :name, null: false
		foreign_key :track_id, :tracks
	end
end

class Course < Sequel::Model
	many_to_many :requirements
	many_to_one :department

	set_schema do
		primary_key :id
		String :name, null: false
		foreign_key :department_id, :departments
		String :number
	    # Eventual TODO:
		# Integer :units_min
		# Integer :units_max
	end
end

# Initialize DB
[Department, Track, Requirement, Course].each do |klass|
	klass.class_eval do
		create_table and seed(self) unless table_exists?
	end
end

get '/' do
	erb :index
end

