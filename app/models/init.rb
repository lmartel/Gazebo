require 'sequel'
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

    def self.case_insensitive_attrs(*attrs)
        self.const_set :CASE_INSENSITIVE_ATTRS, attrs

        before_save = self.instance_method(:before_save)
        self.send :define_method, :before_save do
            (self.class)::CASE_INSENSITIVE_ATTRS.each do |attr|
                self[attr].upcase!
            end
            before_save.bind(self).call
            super()
        end

        brackets = self.method(:[])
        self.define_singleton_method :[] do |params|
            if params.kind_of? Hash
                self::CASE_INSENSITIVE_ATTRS.each do |attr| 
                    params[attr].upcase! if params[attr] 
                end
            end
            brackets.call(params)
        end
    end

    class << self
        alias_method :case_insensitive_attr, :case_insensitive_attrs
    end
end

# Load models
require_relative 'department'
require_relative 'track'
require_relative 'requirement'
require_relative 'course'
