class Department < Sequel::Model
    seedable
    one_to_many :tracks
    one_to_many :courses
    many_to_many :core_requirements, class: :Requirement, right_key: :requirement_id, join_table: :departments_requirements

    set_schema do 
        primary_key :id
        String :name, unique: true, null: false
        String :abbreviation, unique: true, null: false
    end
    
    case_insensitive_attrs :name, :abbreviation

    def core_courses
        core_requirements.flat_map { |req| req.courses }
    end
end
