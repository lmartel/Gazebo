class Path < Sequel::Model
    many_to_one :user
    many_to_many :tracks
    many_to_many :courses
end
