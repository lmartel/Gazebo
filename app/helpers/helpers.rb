module Helpers
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
        when Department
            s = model.name
        else
            s = nil
        end
        s.split(/_| /).map { |word| word.downcase.capitalize }.join(' ')
    end
end
