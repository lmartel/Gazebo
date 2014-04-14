module Seeds
   
    def self.seed_terms
        make Term do
            make :autumn, :aut
            make :winter, :win
            make :spring, :spr
            make :summer, :sum

            # And some stupid ones
            make "not given this year"
            make "not given next year"
            make "offered occasionally"
            make "alternate years"
            make "given next year"
            make "by arrangement"
        end
    end
end
