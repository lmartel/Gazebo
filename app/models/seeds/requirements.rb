module Seeds

    def self.seed_cs_track(track, a:[], b:[], c:[], e:[])
        make Requirement do
            within track do
                require_core
                make("Track Requirement A").includes a
                make("Track Requirement B").includes b
                make("Track Requirement C", 2).includes (b + c).uniq
                make("Electives", 3).includes (CS_ELECTIVES + b + c + e).uniq
            end
        end
    end
    
    def self.seed_requirements
        with_helpers do

            seed_cs_track :cs_undergrad_systems,
                         a: [140],
                         b: [143, EE['108B']],
                         c: [144, 145, 149, 155, 240, 242, 243, 244, 245, EE[271, 282]],
                         e: ['240E', '244C', '244E', ['315A', 316], '315B', 341, 343, 344, '344E', 345, 346, 
                                347, 349, '448', EE['382C', '384A', '384C', '384S', '384X']
                            ]


            # TODO 359, 369 with permission
            seed_cs_track :cs_undergrad_theory,
                         a: [154],
                         b: [164, 167, 255, 258, 261, 265, 268, '361A', '361B'],
                         c: [143, 155, [157, PHIL[151]], 166, '205A', 228, 242, 254, 259, 262, 267, 354, 355, 
                                357, 358, 359, '364A', '364B', 366, 367, 369, 374, MSNE[310]
                            ],
                         e: [CME[302, 305], PHIL[152]]

            make Requirement do 
            # TODO: .rejects [CS 157, Phil 151], [Math 51, Math 52, CME 100]
            # TODO: total X units for several requirements. 
            # Or, mark required vs elective classes within one requirement (extra boolean column in junction table?)

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
                    make("Engineering Fundamentals Requirements", 2, 10).includes '106B', ENGR[40]
                    make("Engineering Fundamentals Elective", 1, 3).includes [ ENGR[10, 14, 15, 20, '25B', '25E', 30, 40, '40A', '40C', '40P',
                        50, '50E', '50M', 60, 62, '70A', '70B', '70X', 80, 90], MSNE[111]
                    ]
                    make("Computer Science Core", 3, 15).includes 107, 110, 161
                    
                    make("Senior Project", 1, 3).includes 191, '191W', 194, '194W', '210B', 294
                end

                within :math_undergrad_minor do
                    make("Math Minor", 6, 24).includes "STATS 116", "PHIL 151", "PHIL 152", lambda { |course|
                        n = course.number.to_i
                        course.department == Department.search!(:math) && n >= 51 && n != 100
                    }
                end

                within :cs_graduate_software_theory_single do
                    make("Foundations", 4).includes 103, 107, 110, 161
                    make("Probability", 1).includes 109, STATS[116], CME[106], MSNE[220]

                    make("Significant Implementation").includes 140, 143, 144, 145, 148, '210B', 221, 243, 248, 347

                    a = [242, 243]
                    b = [241, 258, 259]
                    c = [244, 245, 295, 341, 343, 345]
                    d = [255, 261, 268, 355, '361A', '361B', 365]
                    make("Requirement A", 2).includes a
                    make("Requirement B").includes b
                    make("Requirement C").includes c
                    make("Requirement D").includes d
                    make("Requirement E", 2).includes (a+b+c+d+[346, 393, 395, 399])
                end
            end
        end
    end

    # Define MATH(41, 42) => ["MATH 41", "MATH 42"] etc for each department
    # Remove after the block returns to avoid cluttering namespace.
    def self.with_helpers
        departments = Department.map do |dept_obj| 
            dept_obj.abbreviation.upcase 
        end
        departments.each do |dept|
            Seeds.const_set dept.gsub('&', 'N'), lambda { |*course_numbers|
                course_numbers.map { |num| "#{dept} #{num}" }
            }
        end
        Seeds.const_set :CS_ELECTIVES, [
            108, [121, 221], 124, 131, 142, 143, 144, 145, 147, 148, 149, 154, 155, 156, 
            [157, PHIL[151]], 164, 166, 167, '205A', '205B', '210A', 222, '223A', '224M', '224N', '224S', '224U', 
            '224W', '225A', '225B', 226, 227, '227B', 228, 229, '229A', '229T', '231A', 235, 240, '240H', 
            241, 242, 243, 244, '244B', 245, 246, 247, 248, '249A', '249B', 254, 255, 258, 261, 262, 263, 265, 267, 
            270, 271, 272, [173, '273A'], 274, 276, 277, 295, CME[108], EE['108B'], 282
        ]

        yield

        Seeds.class_eval { remove_const :CS_ELECTIVES }
        departments.each do |dept|
            Seeds.class_eval { remove_const dept.gsub('&', 'N') }
            Department.search(dept).core_requirements.each do |r|
                # r.delete # Department requirements no longer needed; have been copied to tracks where appropriate
            end
        end
    end
end
