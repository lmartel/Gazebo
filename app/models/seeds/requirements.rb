module Seeds
    
    def self.seed_requirements
        with_helpers do
            make Requirement do 
            # TODO: .rejects [CS 157, Phil 151], [Math 51, Math 52, CME 100]
            # TODO: total X units for several requirements. 
            # Or, mark required vs elective classes within one requirement (extra boolean column in junction table?)

                cs_electives = [108, [121, 221], 124, 131, 142, 143, 144, 145, 147, 148, 149, 154, 155, 156, 
                    [157, PHIL[151]], 164, 166, 167, '205A', '205B', '210A', 222, '223A', '224M', '224N', '224S', '224U', 
                    '224W', '225A', '225B', 226, 227, '227B', 228, 229, '229A', '229T', '231A', 235, 240, '240H', 
                    241, 242, 243, 244, '244B', 245, 246, 247, 248, '249A', '249B', 254, 255, 258, 261, 262, 263, 265, 267, 
                    270, 271, 272, [173, '273A'], 274, 276, 277, 295, CME[108], EE['108B'], 282
                ]

                core :cs do
                    make("Mathematics Requirements", 4, 20).includes 103, 109, MATH[41, 42]
                    make("Mathematics Electives", 2, 6).includes 157, '205A', MATH[51, 5253, 104, 108, 109, 110, 113], PHIL[151], CME[100, 102, 104]
                    make("Science Requirements", 2, 8).includes PHYSICS[41, 43]
                    make("Science Elective", 1, 3).includes [ BIO[41, 42, 43, '44X', '44Y'], CEE[63, 64, 70], ENGR[31, 90], 
                        CHEM['31A', '31B', '31X', 33, 35, 36, 131, 135], EARTHSYS[10], GES['1A', '1B', '1C'], PHYSICS[45, 65]
                    ]
                    make("Technology in Society").includes [ BIOE[131], CLASSART[113], COMM['120W'], CS[181, '181W'], ENGR[130, 131, 145],
                        HUMBIO[174], MSNE[181, 193, '193W', 197], POLISCI['114S'], PUBLPOL[122, 194]
                    ]
                    make("Engineering Fundamentals Requirements", 2, 10).includes '106A', ENGR[40]
                    make("Engineering Fundamentals Elective", 1, 3).includes [ ENGR[10, 14, 15, 20, '25B', '25E', 30, 40, '40A', '40C', '40P',
                        50, '50E', '50M', 60, 62, '70A', '70B', '70X', 80, 90], MSNE[111]
                    ]
                    make("Computer Science Core", 3, 15).includes 107, 110, 161
                end

                within :cs_undergrad_systems do
                    track_b = [143, EE['108B']]
                    track_c = track_b + [144, 145, 149, 155, 240, 242, 243, 244, 245, EE[271, 282]]

                    make("Track Requirement A").includes 140
                    make("Track Requirement B").includes track_b
                    make("Track Requirement C", 2).includes track_c
                    make("Electives", 3).includes (track_c + cs_electives).uniq
                    make("Senior Project", 1, 3).includes 191, '191W', 194, '194W', '210B', 294
                end 

                within :math_undergrad_minor do
                    make("Math Minor", 6, 24).includes "STATS 116", "PHIL 151", "PHIL 152", lambda { |course|
                        n = course.number.to_i
                        course.department == Department.search!(:math) && n >= 51 && n != 100
                    }
                end
            end
        end
    end

    # Define MATH(41, 42) => ["MATH 41", "MATH 42"] etc for each department
    # Remove after the block returns to avoid cluttering namespace.
    def self.with_helpers
        departments = Department.map { |dept_obj| dept_obj.abbreviation.upcase.to_sym }
        departments.each do |dept|
            Seeds.const_set dept, lambda { |*course_numbers|
                course_numbers.map { |num| "#{dept} #{num}" }
            }
        end

        yield

        departments.each do |dept|
            Seeds.class_eval { remove_const dept }
        end
    end
end
