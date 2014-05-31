Sequel.migration do
    change do
        create_table :tracks do
            primary_key :id
            String :name, unique: true, null: false
            Integer :units_min

            foreign_key :department_id, :departments
        end
    end
end