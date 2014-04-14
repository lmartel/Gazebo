module Seeds

    def self.seed_courses
        make Course do
            # Courses seeded by parser; no manual seeds.
        end
    end

    def self.seed_course(dept, &block)
        make Course do
            within dept do
                instance_eval(&block)
            end
        end
    end
end