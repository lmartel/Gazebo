class Department < Sequel::Model
    seedable
    one_to_many :tracks
    one_to_many :courses
    many_to_many :core_requirements, class: :Requirement, right_key: :requirement_id, join_table: :departments_requirements

    case_insensitive_attrs :name, :abbreviation

    def core_courses
        core_requirements.flat_map { |req| req.courses }
    end
end
