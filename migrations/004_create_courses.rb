Sequel.migration do
    change do
        create_table :courses do
            primary_key :id
            String :name, null: false
            String :number, null: false
            Integer :units_min, null: false
            Integer :units_max, null: false
            String :description

            foreign_key :department_id, :departments
            unique [:name, :number, :department_id]
        end
    end    
end
