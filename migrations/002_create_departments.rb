Sequel.migration do
    change do
        create_table :departments do
            primary_key :id
            String :name, unique: true, null: false
            String :abbreviation, unique: true, null: false
        end
    end
end
