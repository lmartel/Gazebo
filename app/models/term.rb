class Term < Sequel::Model
    seedable
    many_to_many :courses, join_table: :courses_terms

    set_schema do
        primary_key :id

        String :name, unique: true, null: false
        String :abbreviation, unique: true, null: true
    end

    case_insensitive_attrs :name, :abbreviation
end
