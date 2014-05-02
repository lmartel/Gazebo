class Term < Sequel::Model
    seedable
    many_to_many :courses, join_table: :courses_terms

    case_insensitive_attrs :name, :abbreviation

    class << self

        def search(value, **args)
            results = super(value, **args)
            results ? results : self[name: "other"]
        end
    end
end
