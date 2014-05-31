Sequel.migration do
    change do
        create_table :users do
            primary_key :id

            Integer :year, null: false
            foreign_key :term_id, :terms, null: false

            String :email, unique: true, null: false
            String :password_digest, null: false
        end
    end
end
