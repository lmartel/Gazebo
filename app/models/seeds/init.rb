module Seeds

    def self.make(klass, &block)
        klass.class_eval &block
    end
end

require_relative 'terms'
require_relative 'departments'
require_relative 'tracks'
require_relative 'courses'
require_relative 'requirements'

module Seedable

    MODELS = []

    class << self

        def included(base)
            base.extend(ClassMethods)
            Seedable::MODELS << base
        end

        def junction(klass, partner_name)
            partner_name = partner_name.to_s.capitalize
            klass.class_eval do
                define_method :includes do |*args|
                    args.flatten!
                    partner = Object.const_get(partner_name)
                    junction = Object.const_get("#{klass.class_name}s_#{partner_name}")
                    args.each do |arg|
                        within = klass.within_instance
                        params = { "#{within.class.class_name.downcase}_id".to_sym => within.id } if within
                        
                        found = partner.search! arg, try_with:params
                        junction.create "#{klass.class_name.downcase}_id".to_sym => self.id, "#{partner_name.downcase}_id".to_sym => found.id
                    end
                end
            end
        end
    end

    module ClassMethods

        @within = nil

        def within_instance
            @within
        end

        def seed
            name = class_name.downcase
            Seeds.send "seed_#{name}s"
            dump
        end

        def make(*args)
            create columns[1..-1].zip(args).to_h # [1..-1] to remove :id attribute
        end

        def within(name)
            name = name.to_s
            found = MODELS.select { |klass| 
                klass.table_exists? 
            }.map { |klass| 
                klass[name: name] || (klass.columns.include?(:abbreviation) and klass[abbreviation: name]) || nil
            }.compact
            raise "[Seeds::make::in] Error: model '#{name}' does not exist." if found.empty?
            raise "[Seeds::make::in] Error: multiple models named '#{name}' found: #{found}" if found.length > 1
            found = found.first

            # Inject foreign key into 'make' arguments
            mk = self.method(:make)
            self.define_singleton_method(:make) do |*args| 
                args << nil until args.length == columns.length - 2 # Pad nils for optional fields. -2 => -1 for :id, -1 to leave room for foreign key
                mk.call(*args, found.id) 
            end
            @within = found
            yield
            @within = nil
            self.define_singleton_method :make, mk
        end

        # Helper method: get class name without namespaces
        def class_name
            self.to_s.split("::").last
        end

    end
end
