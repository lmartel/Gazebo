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
end
