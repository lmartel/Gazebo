class Department < Sequel::Model
    seedable
    one_to_many :tracks
    one_to_many :courses

    set_schema do 
        primary_key :id
        String :name, unique: true, null: false
        String :abbreviation, unique: true, null: false
    end
    
    case_insensitive_attrs :name, :abbreviation
end
