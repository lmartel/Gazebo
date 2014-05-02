Sequel.migration do
    change do
        create_table :requirements_courses do
            primary_key :id

            foreign_key :requirement_id, :requirements
            foreign_key :course_id, :courses
        end
    end
end
