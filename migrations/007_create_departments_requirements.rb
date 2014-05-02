Sequel.migration do
    change do
        create_table :departments_requirements do
            primary_key :id

            foreign_key :department_id, :departments
            foreign_key :requirement_id, :requirements
        end
    end
end
