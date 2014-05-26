class Requirement < Sequel::Model
    seedable with_junction: :course
    many_to_many :courses, join_table: :requirements_courses
    many_to_one :track

    case_insensitive_attr :name

    def before_save
        self.min_count ||= 1
        self.min_units ||= 0
        super
    end

    class << self

        def require_core
            # create name: "Department Requirements", track_id: @within_model.id # TODO: improve this. Currently just reads name of track.
        end

        # Make department <==> requirement junction when new requirement is made.
        # Also serves as a Model.within(dept), minus foreign key injection
        def core(d)
            dept = Department.search!(d)
            raise "[Requirement.core] Error: core already declared for department #{dept.name}" unless dept.core_requirements.empty?
            requirement = make "#{dept.abbreviation}"
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
