module Seeds
    def self.seed_tracks
        make Track do
            within :cs do
                make :cs_undergrad_theory, 'http://cs.stanford.edu/degrees/undergrad/ProgramSheets/CS_Theory_1415PS.pdf'
                make :cs_undergrad_systems, 'http://cs.stanford.edu/degrees/undergrad/ProgramSheets/CS_Systems_1415PS.pdf'
                make :cs_undergrad_information, 'http://cs.stanford.edu/degrees/undergrad/ProgramSheets/CS_Info_1415PS.pdf'
                make :cs_undergrad_artificial_intelligence, 'http://cs.stanford.edu/degrees/undergrad/ProgramSheets/CS_AI_1415PS.pdf'
                
                make :cs_graduate_software_theory_single, 'http://cs.stanford.edu/degrees/mscs/programsheets/14-15/MSCS-1415-Software-Single.pdf', 45
                make :cs_graduate_theoretical_computer_science_single, 'http://cs.stanford.edu/degrees/mscs/programsheets/14-15/MSCS-1415-Theory-Single.pdf', 45
                make :cs_graduate_systems_single, 'http://cs.stanford.edu/degrees/mscs/programsheets/14-15/MSCS-1415-Systems-Single.pdf', 45

                # make :cs_graduate_artificial_intelligence_single
                # make :cs_graduate_computer_security_single

                make :cs_graduate_software_theory_primary, 'http://cs.stanford.edu/degrees/mscs/programsheets/14-15/MSCS-1415-Software-Dual.pdf', 30
                make :cs_graduate_theoretical_computer_science_primary, 'http://cs.stanford.edu/degrees/mscs/programsheets/14-15/MSCS-1415-Theory-Dual.pdf', 30
                make :cs_graduate_systems_primary, 'http://cs.stanford.edu/degrees/mscs/programsheets/14-15/MSCS-1415-Systems-Dual.pdf', 30

                make :cs_graduate_theoretical_computer_science_secondary, 'http://cs.stanford.edu/degrees/mscs/programsheets/SecondaryDepthReqs1415.pdf', 15
            end

            within :math do
                make :math_undergrad_minor, 'http://exploredegrees.stanford.edu/schoolofhumanitiesandsciences/mathematics/#minortext', 24
            end
        end
    end
end
