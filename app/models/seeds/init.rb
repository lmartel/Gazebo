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
                make_junction = lambda do |klass_to_create, self_obj, partner_obj|
                    klass_to_create.create "#{klass.class_name.downcase}_id".to_sym => self_obj.id, "#{partner_name.downcase}_id".to_sym => partner_obj.id
                end

                define_method :includes do |*args|
                    args.flatten!
                    partner = Object.const_get(partner_name)
                    junction_klass = Object.const_get("#{klass.class_name}s_#{partner_name}")
                    args.each do |arg|
                        if arg.kind_of? Proc
                            partner.each do |model|
                                make_junction[junction_klass, self, model] if arg.call(model)
                            end
                        else # Search for value
                            within = klass.within_model
                            if within
                                owners = [ within ].concat(within.owners).flatten
                                params = {}
                                owners.each do |owner|
                                    params[(owner.class.class_name.downcase + "_id").to_sym] = owner.id
                                end
                            end
                            
                            make_junction[junction_klass, self, partner.search!(arg, try_with:params)]
                        end
                    end
                end
            end
        end
    end

    module ClassMethods
        attr_reader :within_model

        def seed
            name = class_name.downcase
            Seeds.send "seed_#{name}s"
            dump
        end

        def make(*args)
            create columns[1..-1].zip(args.flatten).to_h # [1..-1] to remove :id attribute
        end

        # Automatically injects foreign key into 'make' arguments.
        # Also sets Model.includes to search for related models before searching other models.
        # Ex: within(:math_undergrad_minor) searches for math classes before looking at other departments' classes.
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

            mk = self.method(:make)
            self.define_singleton_method(:make) do |*args| 
                args << nil until args.length == columns.length - 2 # Pad nils for optional fields. -2 => -1 for :id, -1 to leave room for foreign key
                mk.call(*args, found.id) 
            end
            @within_model = found
            yield
            @within_model = nil
            self.define_singleton_method :make, mk
        end

        # Helper method: get class name without namespaces
        def class_name
            self.to_s.split("::").last
        end

    end
end
