class Term < Sequel::Model
    seedable
    many_to_many :courses, join_table: :courses_terms

    case_insensitive_attrs :name, :abbreviation

    def can_enroll?
        Term.enrollable.include? self
    end

    class << self

        def enrollable
            ["AUT", "WIN", "SPR", "SUM"].map {|abbr| self[abbreviation: abbr] }
        end

        def search(value, **args)
            results = super(value, **args)
            results ? results : self[name: "other"]
        end
    end
end
