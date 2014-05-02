# Junction tables for many-to-many relations

class Courses_Term < Sequel::Model
    many_to_one :course
    many_to_one :term
end

class Departments_Requirement < Sequel::Model
    many_to_one :department
    many_to_one :requirement
end

class Requirements_Course < Sequel::Model
    many_to_one :requirement
    many_to_one :course
end


class Paths_Track < Sequel::Model
    many_to_one :path
    many_to_one :track
end

class Paths_Course < Sequel::Model
    many_to_one :path
    many_to_one :course
end
