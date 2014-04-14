# Junction table for many-to-many courses <=> terms
class Courses_Term < Sequel::Model
    many_to_one :course
    many_to_one :term

    set_schema do
        primary_key :id

        foreign_key :course_id, :courses
        foreign_key :term_id, :terms
    end
end
