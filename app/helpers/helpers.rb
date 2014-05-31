module Helpers

    class Quarter
        include Comparable
        attr_accessor :year, :term

        def initialize(year, term)
            @year = year
            @term = term
        end

        def next(terms = nil)
            dup.next!(terms)
        end

        def next!(terms = nil)
            terms = [terms] if terms and !terms.kind_of? Array
            case @term.abbreviation
            when 'AUT'
                @term = Term[abbreviation: 'WIN']
            when 'WIN'
                @term = Term[abbreviation: 'SPR']
            when 'SPR'
                @term = Term[abbreviation: 'SUM']
            when 'SUM'
                @year += 1
                @term = Term[abbreviation: 'AUT']
            end
            next!(terms) if terms and !terms.include?(@term)
            self
        end

        def <=>(another_quarter)
            return -1 if self.year < another_quarter.year
            return 1 if self.year > another_quarter.year
            terms = Term.enrollable
            terms.index(self.term) <=> terms.index(another_quarter.term)
        end

    end

    def titleize(str)
        str.split(' ').map { |word| word.downcase.capitalize }.join(' ')
    end

    def pp(model)
        case model
        when Track
            s = model.name
            fst = /^[A-Z]+/
            abbr = fst.match s
            if abbr
                dept = Department.search abbr[0]
                s.sub! fst, (dept.name + ':') if dept
            end
            titleize s.gsub('_', ' ')
        when Course::Summary
            model.department + ' ' + model.number + ': ' + model.name
        when Department
            model.name
        else
            model.name
        end
    end

    def pp_units(c)
        return c.units_min.to_s if c.units_min == c.units_max
        "#{c.units_min}-#{c.units_max}"
    end

    def select_first(namespace, override: nil)
        @selected_dom_elements ||= {}
        if override && @selection_override
            active = (override == @selection_override)
        else
            active = !@selected_dom_elements[namespace] 
            @selected_dom_elements[namespace] = true
        end
        active ? "active" : ""
    end

    def render_cell(enrollment, path: @path, closable:false)
        @unique_cell_id ||= 0
        @unique_cell_id += 1
        if enrollment
            course = enrollment.course
            future = enrollment.term.nil? || (Quarter.new(path.user.year, path.user.term) <= Quarter.new(enrollment.year, enrollment.term))
            html = %Q{<span id="cell#{@unique_cell_id}" class="path-cell filled#{future ? ' future' : ' NOTFUTURE'}" data-enrollment="#{enrollment.id}" data-can-fill="#{path.requirements(course).map{|r| r.id }}">}
            html << %Q{#{course.department.abbreviation} #{course.number}}
            html << %Q{<button type="button" class="close delete-enrollment"></button>} if closable
            html << %Q{</span>}
            html
        else
            %Q(<span id="cell#{@unique_cell_id}" class="path-cell unfilled" data-content="TODO"></span>)
        end
    end

    def sort(a)
        return a if a.empty?
        
        if a.first.kind_of? Enrollment
            a.sort_by {|e| [e.course.department.abbreviation, e.course.number.to_i] }
        else
            raise "[Sinatra::Helpers] sort() not yet implemented for this class"
        end
    end

    def logged_in?
        # !session[:user].nil?
        true
    end

    def current_user
        # session[:user]
        User.first # TODO account system
    end

    def csrf_token
        Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
        Rack::Csrf.csrf_tag(env)
    end
end
