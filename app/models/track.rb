class Track < Sequel::Model
    seedable
    many_to_one :department
    one_to_many :requirements

    case_insensitive_attr :name
end
