module Seedable

    MODELS = []

    def self.included(base)
        base.extend(ClassMethods)
        Seedable::MODELS << base
    end

    def self.junction(klass, partner_name)
        partner_name = partner_name.to_s.capitalize
        klass.class_eval do
            define_method :includes do |*args|
                partner = Object.const_get(partner_name)
                junction = Object.const_get("#{klass.class_name}_#{partner_name}")
                args.each do |arg|
                    puts arg
                    puts partner
                    puts junction
                    junction.create "#{klass.class_name.downcase}_id" => self.id, "#{partner_name.downcase}_id" => partner.search!(arg).id
                end
            end
        end
    end

    module ClassMethods

        def seed
            name = class_name.downcase
            Seeds.send "seed_#{name}s"
            dump
        end

        def make(*args)
            puts columns[1..-1].zip(args).to_h
            create columns[1..-1].zip(args).to_h # [1..-1] to remove :id attribute
            # self # allow chaining with junction .includes
        end

        def within(name)
            name = name.to_s
            found = MODELS.map { |klass| klass[name: name] if klass.table_exists? }.compact
            raise "[Seeds::make::in] Error: model '#{name}' does not exist." if found.empty?
            raise "[Seeds::make::in] Error: multiple models named '#{name}' found: #{found}" if found.length > 1
            found = found.first

            # Inject foreign key into 'make' arguments
            mk = self.method(:make)
            self.define_singleton_method(:make) do |*args| 
                args << nil until args.length == columns.length - 2 # Pad nils for optional fields. -2 => -1 for :id, -1 to leave room for foreign key
                mk.call(*args, found.id) 
            end
            yield
            self.define_singleton_method :make, mk
        end

        # Helper method: get class name without namespaces
        def class_name
            self.to_s.split("::").last
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
                make :undergrad_theory
                make :undergrad_systems
                make :graduate_software_theory_single
                make :graduate_software_theory_primary
                make :graduate_theoretical_computer_science_secondary
            end
        end
    end

    def self.seed_courses
        make Course do
            within :cs do
                make "Operating Systems", 140, 3, 4
                make "Compilers", 143
            end
        end
    end

    def self.seed_requirements
        make Requirement do
            within :undergrad_systems do
                make("Track Requirement A").includes 140, "143"
            end
        end
    end
end
