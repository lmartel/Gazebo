module Helpers

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

    def select_first(namespace)
        @selected_dom_elements ||= {}
        return "" if @selected_dom_elements[namespace] 
        @selected_dom_elements[namespace] = true
        "active"
    end

    def render_cell(enrollment)
        @unique_cell_id ||= 0
        @unique_cell_id += 1
        if enrollment
            course = enrollment.course
            return %Q(<span id="cell#{@unique_cell_id}" class="path-cell filled" data-enrollment="#{enrollment.id}" data-can-fill="#{@path.requirements(course).map{|r| r.id }}">#{course.department.abbreviation} #{course.number}</span>)
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
