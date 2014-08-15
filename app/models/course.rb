require 'json'

class Course < Sequel::Model
    seedable with_junction: :term
    many_to_many :terms
    many_to_many :requirements, join_table: :requirements_courses
    many_to_one :department
        
    case_insensitive_attr :number

    def full_name
        "#{name} #{number}"
    end

    def summary
        Summary.new(self)
    end

    def offered
        Term.enrollable & terms
    end

    class << self

        def search(value, **args)
            if value.kind_of?(String) && value.include?(' ')
                dept, number = value.split 
                dept = Department.search(dept)
                match = self[department_id: dept.id, number: number] if dept
                return match if match
            end
            super(value, **args)
        end
    end

    class Summary
        attr_reader :name, :number, :units, :department

        def initialize(course)
            @id = course.id
            @name = course.name
            @number = course.number
            @units = course.units_max > course.units_min ? (course.units_min..course.units_max) : course.units_max
            @department = course.department.abbreviation
        end

        def to_json(options = nil)
            instance_variables.select { |k| k != :@id }.map { |k| [k[1..-1], instance_variable_get(k).to_s] }.to_h.to_json
        end

    end

end
