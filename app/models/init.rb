require 'sequel'
require_relative 'seeds/init'
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

    # Return an array of models this model belongs to, the models those belong to, etc (if any)
    def owners
        foreign_keys = self.class.columns.select { |col_name| col_name.to_s.end_with? "_id" }
        foreign_keys.flat_map do |key|
            parent_model_klass = Object.const_get(key.to_s.capitalize.sub("_id", ""))
            parent_model = parent_model_klass[id:self[key]]
            [parent_model, parent_model.owners]
        end
    end

    class << self

        def dump
            puts "#{self.to_s}:"
            self.each do |i|
                puts i.values
            end
        end

        # Find a model with some value of an unknown attribute (could be a name, course number, etc)
        def search(value, try_with:nil)

            # Don't search ids (primary and foreign keys), just semantic columns
            col_names = self.columns.select do |col_name|
                !col_name.to_s.end_with? "id"
            end

            try_with_params = Proc.new do |params|
                col_names.each do |attr|
                    model = self[{ attr => value.to_s }.merge params]
                    return model if model
                end
            end

            if try_with
                # First, check for a group of additional params to try at once
                if try_with.keys.all? { |attr| self.columns.include?(attr) }
                    try_with_params.call try_with
                end

                # Then, try searching with suggested additional params one-by-one
                try_with.each do |k,v|
                    try_with_params.call(k => v) if self.columns.include?(k)
                end
            end

            # Finally, search only for given value.
            col_names.each do |attr| 
                model = self[attr => value.to_s]
                return model if model
            end
            nil
        end

        def search!(value, **args)
            search(value, **args) || raise("[#{self.to_s}.search! ] Error: no model with attribute '#{value}' found.")
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
require_relative 'term'
require_relative 'department'
require_relative 'track'
require_relative 'requirement'
require_relative 'course'
require_relative 'requirements_course'
require_relative 'courses_term'

# Initialize DB if necessary
def DB.init
    [Term, Department, Track, Course, Requirement, Requirements_Course, Courses_Term].each do |klass|
        klass.create_table?
    end
end
DB.init
