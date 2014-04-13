class Department < Sequel::Model
    one_to_many :tracks
    one_to_many :courses

    set_schema do 
        primary_key :id
        String :name, unique: true, null: false
    end
    
    case_insensitive_attr :name
end
