# Junction table for many-to-many requirements <=> courses
class Requirements_Course < Sequel::Model
    many_to_one :requirement
    many_to_one :course

    set_schema do
        primary_key :id

        foreign_key :requirement_id, :requirements
        foreign_key :course_id, :courses
    end
end
