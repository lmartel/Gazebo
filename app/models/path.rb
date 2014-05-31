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

    def requirements(model=nil)
        all = requirements_by_track.values.flatten
        return all unless model
        case model
        when Course
            all.select { |req| req.courses.include?(model) }
        else
            raise "[Path::requirements] unsupported class"
        end
    end

    def requirements_by_priority
        requirements.sort_by do |req|
            possibilities = req.courses.count
            ratio = req.min_count.to_f / possibilities
            ratio = 0 if ratio.nan?
            [1 - ratio, possibilities]
        end
    end

    def enrollments(model=nil)
        all = Enrollment.where(path_id: id)
        return all.to_a unless model
        case model
        when Requirement
            all.where(requirement_id: model.id).to_a
        when Track
            all.to_a.select do |enr| 
                req = enr.requirement
                req && req.track_id == model.id
            end
        else
            raise "[Path::enrollments] unsupported class"
        end
    end

    def unassigned_enrollments
        Enrollment.where(path_id: id, requirement_id: nil).to_a
    end

    def unassigned_requirements
        requirements_by_priority.select do |req|
            existing_enrollments = Enrollment.where(path_id: id, requirement_id: req.id) 
            units_enrolled = existing_enrollments.map {|enr| enr.course.units_max }.reduce(0, :+)
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
                # We find requirements that can be filled by the course, and that do not already have a copy of the same course assigned
                viable = reqs.select { |req| 
                    req.courses.include?(e.course) && !enrollments(req).map{|old_e| old_e.course}.include?(e.course) 
                }.sort_by { |req| req.min_count }
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
