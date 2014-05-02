Sequel.migration do
    change do
        create_table :terms do
            primary_key :id
            String :name, unique: true, null: false
            String :abbreviation, unique: true, null: true
        end
    end
end
