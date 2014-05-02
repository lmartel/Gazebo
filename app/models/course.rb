class Course < Sequel::Model
    seedable with_junction: :term
    many_to_many :terms
    many_to_many :requirements, join_table: :requirements_courses
    many_to_one :department
        
    case_insensitive_attrs :name, :number

    def full_name
        "#{name} #{number}"
    end

    class << self

        def search(value, **args)
            if value.kind_of?(String) && value.include?(' ')
                dept, number = value.split 
                dept = Department.search(dept)
                match = self[department_id: dept.id, number: number]
                return match if match
            end
            super(value, **args)
        end
    end

end
