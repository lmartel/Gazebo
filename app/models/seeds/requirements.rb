module Seeds

    def self.seed_cs_track(track, a:nil, b:nil, c:nil, e:nil, counts:{}, &block)
        make Requirement do
            within track do
                require_core
                make("Track Requirement A", counts[:a] || 1).includes a if a
                make("Track Requirement B", counts[:b] || 1).includes b if b
                make("Track Requirement C", counts[:c] || 1).includes (b + c).uniq if c
                make("Electives", counts[:e] || 3).includes (b + c + e + CS_ELECTIVES).uniq if e
                instance_eval &block if block_given?
            end
        end
    end

    def self.seed_cs_masters(track, breadth:nil, &block)
        make Requirement do
            single = (track.to_s + '_single').to_sym
            within single do
                make("Foundations (can waive)", 4).includes 103, 107, 110, 161
                make("Probability (can waive)", 1).includes 109, STATS[116], CME[106], MSNE[220]
                make("Significant Implementation (can waive)").includes 140, 143, 144, 145, 148, '210B', 221, 243, 248, 347
                
                make("Breadth", 3).includes breadth
                instance_eval &block if block_given?

                make("Electives", 3).includes lambda { |course| # TODO: "advisor approval" technical classes > 100?
                    n = course.number.to_i
                    abbr = course.department.abbreviation
                    (abbr == 'CS' && n > 110 && ![196, 198].include?(n)) || (abbr == 'MATH' && n >= 100)
                }
            end

            primary = (track.to_s + '_primary').to_sym
            within primary do
                make("Foundations (can waive)", 4).includes 103, 107, 110, 161
                make("Probability (can waive)", 1).includes 109, STATS[116], CME[106], MSNE[220]
                make("Significant Implementation (can waive)").includes 140, 143, 144, 145, 148, '210B', 221, 243, 248, 347
                
                instance_eval &block if block_given?
                r = Requirement.last
                r.min_count -= 2
                r.save

                make("Electives", 3).includes lambda { |course| # TODO: "advisor approval" technical classes > 100?
                    n = course.number.to_i
                    abbr = course.department.abbreviation
                    (abbr == 'CS' && n > 110 && ![196, 198].include?(n)) || (abbr == 'MATH' && n >= 100)
                }
            end
        end
    end
    
    def self.seed_requirements
        with_helpers do

            seed_cs_track :cs_undergrad_systems,
                a: [140],
                b: [143, EE[180]],
                c: [144, 145, 149, 155, 240, 242, 243, 244, 245, EE[271, 282]],
                e: ['240E', '244C', '244E', ['315A', 316], '315B', 341, 343, 344, '344E', 345, 346, 
                    347, 349, '448', EE['382C', '384A', '384C', '384S', '384X']
                ],
                counts: {a:1, b:1, c:2, e:3}


            # TODO 359, 369 with permission
            seed_cs_track :cs_undergrad_theory,
                a: [154],
                b: [164, 167, 255, 258, 261, 265, 268, '361A', '361B'],
                c: [143, 155, [157, PHIL[151]], 166, '205A', 228, 242, 254, 259, 262, 267, 354, 355, 
                    357, 358, 359, '364A', '364B', 366, 367, 369, 374, MSNE[310]
                ],
                e: [CME[302, 305], PHIL[152]],
                counts: {a:1, b:1, c:2, e:3}

            seed_cs_track :cs_undergrad_artificial_intelligence,
                a: [221],
                b: ['223A', '224M', '224N', 226, 227, 228, 229, [131, '231A']],
                c: [124, '205A', 222, '224S', '224U', '224W', '225A', '225B', '227B', 
                    '231A', '231B', 262, 276, 277, 279, 321, '326A', '327A', '329', 
                    331, 374, '379', 'EE 263', '376A', 'ENGR 205', 
                    'ENGR 209A', 'MS&E 251', 339, 351, 'STATS 315A', '315B'
                ],
                e: [275, 278, ['334A', 'EE 364A'], 'EE 364B', 'ECON 286', 'MS&E 252', 
                    352, 355, 'PHIL 152', 'PSYCH 202', '204A', '204B', 'STATS 200', 202, 205
                ],
                counts: {a:1, b:2, c:1, e:3}

            seed_cs_track(:cs_undergrad_information,
                a: [124, 145],
                counts: {a:2}
            ) do
                b1 = ['224N', '224S', 229, '229A']
                b2 = [140, 142, 245, 246, 341, 345, 346, 347]
                b3 = [262, 270, 274]
                b4 = ['224W', 276, '364B']

                make("Track Requirement B [2/4 required]", 0)
                make("Track Requirement B (I)").includes b1
                make("Track Requirement B (II)").includes b2
                make("Track Requirement B (III)").includes b3
                make("Track Requirement B (IV)").includes b4
                make("Electives", 3).includes (b1 + b2 + b3 + b4 + CS_ELECTIVES).uniq
            end

            seed_cs_masters(:cs_graduate_software_theory,
                breadth: [[121, 221], 124, 140, 147, 148, 149, 154, 155, 
                    157, 164, '205A', 222, '223A', '224M', '224N', '224S', '224U', '224W', 
                    226, 227, '227B', 228, 229, '229A', '231A', 240, '240E', '244B', '244E', 
                    246, '249A', 262, 270, [173, '273A'], 274, 276, 279, 'CME 108', 302, EE[180, 282]
                ]
            ) do
                
                a = [242, 243]
                b = [244, 245, 295, 341, 343, 345]
                c = [255, 261, 264, 265, 266, 267, 268, 355, '361A', '361B', 367]
                
                make("Requirement A", 2).includes a
                make("Requirement B").includes b
                make("Requirement C").includes c
                make("Requirement D", 5).includes (a+b+c+[258, 259, 346, 362, 393, 395, 399])
            end

            seed_cs_masters(:cs_graduate_theoretical_computer_science,
                breadth: [[121, 221], 124, 140, 143, [144, 'EE 284'], 145, 147, 
                    148, 149, 154, 155, 157, 164, '205A', 222, '223A', '224M', '224N', '224S', '224U', 
                    '224W', 226, 227, '227B', 229, '229A', '231A', 240, '240E', 242, 243, 244, '244B', 
                    '244E', '249A', 270, [173, '273A'], 274, 276, 279, 'CME 108', 302, EE[180, 282]
                ]
            ) do

                a = [261, '361A', '361B']
                b = [228, 241, 246, 254, 255, 258, 259, 262, 265, 267, 268, ['334A', 'EE 364A'], 
                    341, 345, 355, 357, 358, 359, '361A', '361B', 362, '364A', '364B', 366, 
                    367, 369, 374, 393, 395, 399, 468
                ]

                make("Requirement A", 1).includes a
                make("Requirement B", 8).includes (a+b).uniq
            end

            seed_cs_masters(:cs_graduate_systems,
                breadth: [[121, 221], 124, 147, 154, 155, 157, 164, 
                    '205A', 222, '223A', '224M', '224N', '224S', '224U', '224W', 226, 227, 
                    '227B', 228, 229, '229A', '231A', 258, 261, 265, 267, 268, [173, '273A'], 
                    274, 279, CME[108, 302]
                ]
            ) do

                a1 = [140, 144]
                a2 = [240, 242]
                b = [243, 244, 245, 248, '348B', EE[271, 282]]
                c = ['240E', '244B', '244C', '244E', 246, '249A', '249B', 255, 259, 262, 
                    270, 271, 272, 276, 295, ['315A', 316], '315B', 340, 341, 343, 344, 
                    345, 346, 347, '348A', 349, 374, 448, 393, 395, 399, 478, 
                    EE[273, '382C', '384A', '384C', '384M', '384S', '384X']
                ]

                make("Requirement A", 0)
                make("Requirement A (can waive)", 2).includes a1
                make("Requirement A (can't waive)", 2).includes a2
                make("Requirement B", 3).includes b
                make("Requirement C", 4).includes (a1 + a2 + b + c).uniq
            end

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
                    make("Technology in Society").includes [ BIOE[131], COMM['120W'], CS[181, '181W'], ENGR[130, 131, 145],
                        HUMBIO[174], MSNE[181, 193, 197], POLISCI['114S'], PUBLPOL[122, 194]
                    ]
                    make("Engineering Fundamentals Requirements", 2, 10).includes '106B', ENGR[40]
                    make("Engineering Fundamentals Elective", 1, 3).includes [ ENGR[10, 14, 15, 20, '25B', '25E', 30, 40, '40A', '40P',
                        50, '50E', '50M', 60, 62, '70A', '70B', '70X', 80, 90], MSNE[111]
                    ]
                    make("Computer Science Core", 3, 15).includes 107, 110, 161
                    
                    make("Senior Project", 1, 3).includes 191, '191W', 194, '194W', '210B', 294
                    make("WIM", 1).includes '181W', '191W', '194W', '210B'
                end

                within :cs_graduate_theoretical_computer_science_secondary do
                    # make("Requirement A (can waive)").includes
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
            '224W', '225A', '225B', 226, 227, '227B', 228, 229, '229A', '229T', '231A', 235, 240,
            241, 242, 243, 244, '244B', 245, 246, 247, 248, '249A', '249B', 254, 255, 258, 261, 262, 263, 265, 267, 
            270, 271, 272, [173, '273A'], 274, 276, 277, 295, CME[108], EE[180, 282]
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
