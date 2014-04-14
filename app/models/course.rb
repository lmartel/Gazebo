class Course < Sequel::Model
    seedable with_junction: :term
    many_to_many :terms
    many_to_many :requirements, join_table: :requirements_courses
    many_to_one :department

    set_schema do
        primary_key :id
        String :name, null: false
        String :number, null: false
        Integer :units_min, null: false
        Integer :units_max, null: false
        String :description

        foreign_key :department_id, :departments
        unique [:name, :number, :department_id]
    end

    def full_name
        "#{name} #{number}"
    end

    class << self

        def search(value, try_with:nil)
            if value.kind_of?(String) && value.include?(' ')
                dept, number = value.split 
                dept = Department.search(dept)
                match = self[department_id: dept.id, number: number]
                return match if match
            end
            super(value, try_with:try_with)
        end
    end

    case_insensitive_attrs :name, :number
end
