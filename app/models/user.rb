class User < Sequel::Model
    one_to_many :paths
    many_to_one :term

    plugin :secure_password
end
