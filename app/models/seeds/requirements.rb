module Seeds
    
    def self.seed_requirements
        make Requirement do
            within :undergrad_systems do
                make("Track Requirement A").includes 140
                make("Track Requirement B").includes 143, "EE 108B"
            end
        end
    end
end
