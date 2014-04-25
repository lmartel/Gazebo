class Term < Sequel::Model
    seedable
    many_to_many :courses, join_table: :courses_terms

    set_schema do
        primary_key :id

        String :name, unique: true, null: false
        String :abbreviation, unique: true, null: true
    end

    case_insensitive_attrs :name, :abbreviation

    class << self

        def search(value, **args)
            results = super(value, **args)
            results ? results : self[name: "other"]
        end
    end
end
