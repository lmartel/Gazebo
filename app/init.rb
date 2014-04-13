# Initialize Sequel models
require_relative 'models/init'
require_relative 'seeds'

# Initialize and seed DB if necessary
[Department, Track, Requirement, Course].each do |klass|
    klass.class_eval do
        include Seedable
        create_table and seed unless table_exists?
    end
end 
