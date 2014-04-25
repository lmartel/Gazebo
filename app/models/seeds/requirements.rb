module Seeds
    
    def self.seed_requirements
        make Requirement do
            within :cs_undergrad_systems do
                make("Track Requirement A").includes 140
                make("Track Requirement B").includes 143, "EE 108B"
            end

            within :math_undergrad_minor do
                make("The Minor", 6, 24)
                make("Math 51").includes 51, "51H"
                make("Math 52").includes 52, "52H"
                make("Math 53").includes 53, "53H"
            end
        end
    end
end
