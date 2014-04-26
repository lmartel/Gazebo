class Requirement < Sequel::Model
    seedable with_junction: :course
    many_to_many :courses, join_table: :requirements_courses
    many_to_one :track

    set_schema do
        primary_key :id
        String :name, null: false
        Integer :min_count, default: 1
        Integer :min_units, default: 0

        foreign_key :track_id, :tracks
        unique [:name, :track_id]
    end

    case_insensitive_attr :name

    class << self

        # Make department <==> requirement junction when new requirement is made.
        # Also serves as a Model.within(dept), minus foreign key injection
        def core(d)
            dept = Department.search!(d)
            raise "[Requirement.core] Error: core already declared for department #{dept.name}" unless dept.core_requirements.empty?
            # requirement = make "#{dept.name} core", *args
            # make junctions

            mk = self.method(:make)
            self.define_singleton_method(:make) do |*args| 
                req = mk.call(*args)
                Departments_Requirement.create(department_id: dept.id, requirement_id: req.id)
                req
            end

            @within_model = dept
            yield
            @within_model = nil

            self.define_singleton_method :make, mk
        end
    end
end
