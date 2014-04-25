class Requirement < Sequel::Model
    seedable with_junction: :course
    many_to_many :courses, join_table: :requirements_courses
    many_to_one :track

    set_schema do
        primary_key :id
        String :name, null: false
        Integer :min_count, default: 1
        Integer :min_units, default: 0

        foreign_key :track_id, :tracks
        unique [:name, :track_id]
    end

    case_insensitive_attr :name
end
