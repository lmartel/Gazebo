# Junction table for many-to-many courses <=> terms
class Courses_Term < Sequel::Model
    many_to_one :course
    many_to_one :term
end
