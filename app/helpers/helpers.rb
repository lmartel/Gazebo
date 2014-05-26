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

    def render_cell(course)
        @unique_cell_id ||= 0
        @unique_cell_id += 1
        if course
            '<span id="cell' + @unique_cell_id.to_s + '" class="path-cell filled" data-can-fill="' + @path.requirements(course).map{|r| r.id }.to_s + '">' + course.department.abbreviation + ' ' + course.number + '</span>'
        else
            '<span id="cell' + @unique_cell_id.to_s + '" class="path-cell unfilled" data-content="TODO"></span>'
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
