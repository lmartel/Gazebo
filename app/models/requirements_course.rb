# Junction table for many-to-many requirements <=> courses
class Requirements_Course < Sequel::Model
    many_to_one :requirement
    many_to_one :course
end
