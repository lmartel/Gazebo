require 'sequel'
require_relative '../seeds'
Sequel::Model.plugin :schema

# Connect to database
if defined?(TrackTracker)
    DB = Sequel.connect(TrackTracker::DB_URL)
else

    # Enables DB access from ruby console without loading entire app.
    # use 'require_relative app/models/init'
    DB = Sequel.connect(ENV['HEROKU_POSTGRESQL_???_URL'] || ENV['DATABASE_URL'] || "sqlite://debug.db")
end

# Apply Sequel monkey patches
class Sequel::Model

    class << self

        def dump
            puts "#{self.to_s}:"
            self.each do |i|
                puts i.values
            end
        end

        def search(value)
            model = nil # avoids extra database call at end
            self.columns.find { |attr| model = self[attr => value] }
            model
        end

        def search!(value)
            search(value) || raise("[#{self.to_s}.search! ] Error: no model with attribute '#{value}' found.")
        end

        def seedable(with_junction:nil)
            include Seedable
            Seedable.junction(self, with_junction) if with_junction
        end

        def case_insensitive_attrs(*attrs)
            self.const_set :CASE_INSENSITIVE_ATTRS, attrs

            before_save = self.instance_method(:before_save)
            self.send :define_method, :before_save do
                (self.class)::CASE_INSENSITIVE_ATTRS.each do |attr|
                    v = self[attr]
                    v.upcase! if v.respond_to?(:upcase!)
                end
                before_save.bind(self).call
                super()
            end

            brackets = self.method(:[])
            self.define_singleton_method :[] do |params|
                if params.kind_of? Hash
                    self::CASE_INSENSITIVE_ATTRS.each do |attr| 
                        v = params[attr]
                        v.upcase! if v && v.respond_to?(:upcase!)
                    end
                end
                brackets.call(params)
            end
        end

        alias_method :case_insensitive_attr, :case_insensitive_attrs

    end
end

# Load models
require_relative 'department'
require_relative 'track'
require_relative 'requirement'
require_relative 'course'
require_relative 'course_requirement'

# Initialize and seed DB if necessary
new_tables = []
[Department, Track, Course, Requirement, Course_Requirement].map { |klass|
    klass.class_eval { self if !table_exists? and create_table and self.respond_to?(:seed) }
}.compact.each { |new_table| new_table.seed }

Course_Requirement.dump
