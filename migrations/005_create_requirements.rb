Sequel.migration do
    change do
        create_table :requirements do
            primary_key :id
            String :name, null: false
            Integer :min_count, default: 1, null: false
            Integer :min_units, default: 0, null: false

            foreign_key :track_id, :tracks
            unique [:name, :track_id]
        end
    end
end
