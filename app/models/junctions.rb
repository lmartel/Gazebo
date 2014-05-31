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
    many_to_one :term
    many_to_one :requirement

    def validate
        super
        errors.add(:term_id, 'must be a valid term') unless term.nil? or term.can_enroll?
        errors.add(:year, 'must be positive and reasonable') unless year > 0 && year < 9
    end
end
Enrollment = Paths_Course
