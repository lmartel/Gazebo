require_relative '../app/models/init'

exit(1) if Path.count > 0

U = User.create email:"lmartel@stanford.edu", password:"test", password_confirmation:"test", year: 3, term_id: Term.search(:spr).id
P = Path.create name:"Test", user_id: U.id
P2 = Path.create name:"Test2", user_id: U.id

def track(path, name)
    Paths_Track.create track_id: Track.search(name).id, path_id: path.id
end

def enroll(term_abbr, year)
    @term = Term.search(term_abbr)
    @year = year
    yield
    @year = nil
    @term = nil
end

[:cs, :math, :engr, :physics, :chem].each do |dept|
    define_method dept do |*args|
        args.map {|n| Course.search("#{dept.to_s.upcase} #{n}") }.each do |c|
            Enrollment.create path_id: P.id, course_id: c.id, term_id: @term.id, year: @year
            Enrollment.create path_id: P2.id, course_id: c.id, term_id: @term.id, year: @year
        end
    end
end

track P, "CS_UNDERGRAD_SYSTEMS"
track P, "CS_GRADUATE_SOFTWARE_THEORY_SINGLE"
track P, "MATH_UNDERGRAD_MINOR"

track P2, "CS_UNDERGRAD_SYSTEMS"
track P2, "MATH_UNDERGRAD_MINOR"

enroll :aut, 1 do
    cs '106A'
    math 41, 42
    physics 41, 43
    chem '31A'
end

enroll :win, 1 do
    cs '106B'
    math 51
    math 51
end

enroll :spr, 1 do
    cs 107
    cs 107
end

enroll :aut, 2 do
    cs 148
end

enroll :win, 2 do
    cs 103, 108
    cs 103
end

enroll :spr, 2 do
    cs 109, 110, 143
    cs 109, 110
end

enroll :aut, 3 do
    cs 161, 221, '249A'
    cs 161
    math 113
end

enroll :win, 3 do
    engr 40
end

enroll :spr, 3 do
    cs 166, 167, '193p'
    math 110
end
