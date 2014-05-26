Sequel.migration do
    change do
        create_table :paths do
            primary_key :id
            String :name, unique: true, null: false

            foreign_key :user_id, :users
        end

        create_table :paths_tracks do
            primary_key :id

            foreign_key :path_id, :paths
            foreign_key :track_id, :tracks
        end

        create_table :paths_courses do
            primary_key :id
            Integer :year, null: false
            
            foreign_key :term_id, :terms
            foreign_key :requirement_id, :requirements

            foreign_key :path_id, :paths
            foreign_key :course_id, :courses
        end
    end
end
