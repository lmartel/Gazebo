class Requirement < Sequel::Model
    seedable with_junction: :course
    many_to_many :courses
    many_to_one :track

    set_schema do
        primary_key :id
        String :name, unique: true, null: false

        foreign_key :track_id, :tracks
    end

    case_insensitive_attr :name
end
