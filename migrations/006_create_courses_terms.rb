Sequel.migration do
    change do
        create_table :courses_terms do
            primary_key :id

            foreign_key :course_id, :courses
            foreign_key :term_id, :terms
        end
    end
end
