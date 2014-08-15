class User < Sequel::Model
    one_to_many :paths
    many_to_one :term

    plugin :secure_password

    def future?(enrollment)
        enrollment.term.nil? || (Helpers::Quarter.new(year, term) <= Helpers::Quarter.new(enrollment.year, enrollment.term))
    end

end
