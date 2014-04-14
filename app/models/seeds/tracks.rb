module Seeds
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
end