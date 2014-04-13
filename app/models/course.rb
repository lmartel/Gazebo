class Course < Sequel::Model
    seedable with_junction: :requirement
    many_to_many :requirements
    many_to_one :department

    set_schema do
        primary_key :id
        String :name, unique: true, null: false
        String :number, unique: true, null: false
        Integer :units_min
        Integer :units_max

        foreign_key :department_id, :departments
    end

    case_insensitive_attrs :name, :number
end
