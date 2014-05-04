module Seeds

    def self.seed_courses
        make Course do
            # Courses seeded by parser; manual seeds for special cases only.
            within :math do
                make("MATH 52 and MATH 53", "5253", 10, 10, "See Math 52 and Math 53")
            end
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