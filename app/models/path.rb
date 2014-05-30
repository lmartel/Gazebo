class Path < Sequel::Model
    many_to_one :user
    many_to_many :tracks
    many_to_many :courses, join_table: :paths_courses

    def requirements_by_track
        tracks.map {|tr|
            reqs = []
            reqs.concat tr.department.core_requirements if tr.name.include?('UNDERGRAD')
            reqs.concat tr.requirements
            [tr, reqs]
        }.to_h
    end

    def requirements(course=nil)
        all = requirements_by_track.values.flatten
        course ? all.select { |req| req.courses.include?(course) } : all
    end

    def requirements_by_priority
        requirements.sort_by do |req|
            possibilities = req.courses.count
            [1 - (req.min_count.to_f / possibilities), possibilities]
        end
    end

    def enrollments(req=nil)
        (req ? Enrollment.where(path_id: id, requirement_id: req.id) : Enrollment.where(path_id: id)).to_a
    end

    def unassigned_enrollments
        Enrollment.where(path_id: id, requirement_id: nil).to_a
    end

    def unassigned_requirements
        requirements_by_priority.select do |req|
            existing_enrollments = Enrollment.where(path_id: id, requirement_id: req.id) 
            units_enrolled = existing_enrollments.map {|enr| enr.course.units_max }.reduce(:+)
            existing_enrollments.count < req.min_count || units_enrolled < req.min_units
        end
    end

    def layout!
        Enrollment.where(path_id: id).each do |enr|
            enr.requirement = nil
            enr.save
        end

        count = -1
        loop do
            reqs = unassigned_requirements
            nextCount = unassigned_enrollments.count
            break if count == nextCount
            count = nextCount
            unassigned_enrollments.map { |e| 
                viable = reqs.select {|req| req.courses.include?(e.course) }
                [e, viable]
            }.sort_by { |a|
                a.last.count
            }.each { |e, viable|
                if viable.length > 0
                    e.requirement = viable.first
                    e.save
                    break
                end
            }
        end

        # Enrollment.where(path_id: id).each do |e|
        #     puts "#{e.course.name} => #{e.requirement and e.requirement.name}"
        # end

    end
end
