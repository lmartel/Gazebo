module Seedable

    MODELS = []

    def self.included(base)
        base.extend(ClassMethods)
        Seedable::MODELS << base
    end

    module ClassMethods

        def seed
            name = self.to_s.split("::").last.downcase # strip namespace if any
            Seeds.send "seed_#{name}s"
            dump
        end

        def make(*args)
            create columns[1..-1].zip(args).to_h # [1..-1] to remove :id attribute
        end

        def within(name)
            name = name.to_s
            found = MODELS.map { |klass| klass[name: name] }.compact
            raise "[Seeds::make::in] Error: model '#{name}' does not exist." if found.empty?
            raise "[Seeds::make::in] Error: multiple models named '#{name}' found." if found.length > 1
            found = found.first

            # Inject foreign key into 'make' arguments
            mk = self.method(:make)
            self.define_singleton_method(:make) { |*args| mk.call(*args, found.id) }
            yield
            self.define_singleton_method :make, mk
        end

        def dump
            puts "#{self.to_s}:"
            self.each do |i|
                puts i.values
            end
        end


    end
    
end

module Seeds

    def self.make(klass, &block)
        klass.class_eval &block
    end

    def self.seed_departments
        make Department do
            make :cs
        end
    end

    def self.seed_tracks
        make Track do
            within :cs do
                make :theory
            end
        end
    end

    def self.seed_requirements
    end

    def self.seed_courses
    end
    
end