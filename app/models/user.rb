class User < Sequel::Model
    one_to_many :paths

    plugin :secure_password
end
