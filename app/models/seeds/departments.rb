module Seeds

    def self.seed_departments
        make Department do
            # Departments seeded by parser
        end
    end

    def self.seed_department(&block)
        make Department do
            instance_eval(&block)
        end
    end
end
