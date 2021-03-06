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

U = User.create email:"DEMO", password:"guest", password_confirmation:"guest", year: 4, term_id: Term.search(:aut).id
PATHS = [
    tracks(Path.create(name: "Demo 1 (Try Me!)", user_id: U.id), "CS_UNDERGRAD_SYSTEMS", "CS_GRADUATE_SOFTWARE_THEORY_SINGLE", "MATH_UNDERGRAD_MINOR"),
]

[:cs, :math, :engr, :physics, :chem].each do |dept|
    define_method dept do |*args|
        puts "Enrolling DEMO account in #{dept} #{args.to_s}"
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
    cs '181W', 229, 264
    math 120
end

enroll :win, 4 do
    cs 140, 144, 154
end

enroll :spr, 4 do
    cs 155
end
