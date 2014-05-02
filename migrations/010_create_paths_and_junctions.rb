Sequel.migration do
    change do
        create_table :paths do
            primary_key :id

            foreign_key :user_id, :users
        end

        create_table :paths_tracks do
            primary_key :id

            foreign_key :path_id, :paths
            foreign_key :track_id, :tracks
        end

        create_table :paths_courses do
            primary_key :id

            foreign_key :path_id, :paths
            foreign_key :track_id, :tracks
        end
    end
end
