# Junction table for many-to-many departments <=> requirements
class Departments_Requirement < Sequel::Model
    many_to_one :department
    many_to_one :requirement

    set_schema do
        primary_key :id

        foreign_key :department_id, :departments
        foreign_key :requirement_id, :requirements
    end
end
