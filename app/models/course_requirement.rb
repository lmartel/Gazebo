# Junction table for many-to-many courses <=> requirements
class Course_Requirement < Sequel::Model
    many_to_one :course
    many_to_one :requirement

    set_schema do
        primary_key :id

        foreign_key :course_id, :courses
        foreign_key :requirement_id, :requirements
    end
end
Requirement_Course = Course_Requirement
