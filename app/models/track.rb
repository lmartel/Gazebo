class Track < Sequel::Model
    seedable
    many_to_one :department
    one_to_many :requirements

    set_schema do
        primary_key :id
        String :name, unique: true, null: false

        foreign_key :department_id, :departments
    end

    case_insensitive_attr :name
end
