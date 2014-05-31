require_relative '../app/models/init'

def tracks(path, *names)
    names.each do |name|
        Paths_Track.create track_id: Track.search(name).id, path_id: path.id
    end
    path
end

def enroll(term_abbr, year)
    @term = Term.search(term_abbr)
    @year = year
    yield
    @year = nil
    @term = nil
end

exit(1) if Path.count > 0

U = User.create email:"lmartel@stanford.edu", password:"test", password_confirmation:"test", year: 3, term_id: Term.search(:spr).id
PATHS = [
    tracks(Path.create(name:"Systems | Pure Theory", user_id: U.id), "CS_UNDERGRAD_SYSTEMS", "CS_GRADUATE_THEORETICAL_COMPUTER_SCIENCE_SINGLE", "MATH_UNDERGRAD_MINOR"),
    tracks(Path.create(name:"Systems | Theory", user_id: U.id), "CS_UNDERGRAD_SYSTEMS", "CS_GRADUATE_SOFTWARE_THEORY_SINGLE", "MATH_UNDERGRAD_MINOR"),
    tracks(Path.create(name:"Theory | Systems", user_id: U.id), "CS_UNDERGRAD_THEORY", "CS_GRADUATE_SYSTEMS_SINGLE", "MATH_UNDERGRAD_MINOR")
]

[:cs, :math, :engr, :physics, :chem].each do |dept|
    define_method dept do |*args|
        args.map {|n| Course.search("#{dept.to_s.upcase} #{n}") }.each do |c|
            PATHS.each do |path|
                Enrollment.create path_id: path.id, course_id: c.id, term_id: @term.id, year: @year
            end
        end
    end
end

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
end

enroll :aut, 2 do
    cs 148
end

enroll :win, 2 do
    cs 103, 108
end

enroll :spr, 2 do
    cs 109, 110, 143
end

enroll :aut, 3 do
    cs 161, 221, '249A'
    math 113
end

enroll :win, 3 do
    engr 40
end

enroll :spr, 3 do
    cs 166, 167, '193p'
    math 110
end

enroll :aut, 4 do
    cs 144, 229
end

enroll :win, 4 do
    cs 140, 154
end

enroll :spr, 4 do
    cs 155
    
    cs '181W', '181W'
    engr 62 # msne 111
end

enroll :aut, 5 do
    cs 242
end

enroll :win, 5 do
    cs 243
end