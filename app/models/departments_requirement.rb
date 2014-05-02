# Junction table for many-to-many departments <=> requirements
class Departments_Requirement < Sequel::Model
    many_to_one :department
    many_to_one :requirement
end
