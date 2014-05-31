module Seeds
    def self.seed_tracks
        make Track do
            within :cs do
                make :cs_undergrad_theory
                make :cs_undergrad_systems
                make :cs_undergrad_information
                make :cs_undergrad_artificial_intelligence
                
                make :cs_graduate_software_theory_single, 45
                make :cs_graduate_theoretical_computer_science_single, 45
                make :cs_graduate_systems_single, 45

                # make :cs_graduate_artificial_intelligence_single
                # make :cs_graduate_computer_security_single

                make :cs_graduate_software_theory_primary, 30
                make :cs_graduate_theoretical_computer_science_primary, 30
                make :cs_graduate_systems_primary, 30

                make :cs_graduate_theoretical_computer_science_secondary, 15
            end

            within :math do
                make :math_undergrad_minor, 24
            end
        end
    end
end
