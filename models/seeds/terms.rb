module Seeds
   
    def self.seed_terms
        make Term do
            make :autumn, :aut
            make :winter, :win
            make :spring, :spr
            make :summer, :sum

            make :other # catch-all for misc stupid things the prof writes in the "Terms offered" section

            # Some common stupid things
            make "not given this year"
            make "not given next year"
            make "offered occasionally"
            make "alternate years"
            make "given next year"
            make "by arrangement"
        end
    end
end
