module Seeds
    def self.seed_tracks
        make Track do
            within :cs do
                make :cs_undergrad_theory
                make :cs_undergrad_systems
                make :cs_graduate_software_theory_single
                make :cs_graduate_software_theory_primary
                make :cs_graduate_theoretical_computer_science_secondary
            end

            within :math do
                make :math_undergrad_minor
            end
        end
    end
end