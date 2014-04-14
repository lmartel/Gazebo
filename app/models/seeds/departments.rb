module Seeds

    def self.seed_departments
        make Department do
            make "Computer Science", :cs
            make "Electrical Engineering", :ee
            make "Math", :math
        end
    end
end
