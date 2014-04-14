require_relative '../app/models/init'
require_relative 'parser'

[Term, Department, Track].each do |klass|
    klass.seed
end

def fetch(url)
    if ARGV.length > 0
        ExploreCoursesParser.seed_from url, output:ARGV[0] 
    else 
        ExploreCoursesParser.seed_from url
    end
end

# CS
fetch "http://explorecourses.stanford.edu/print?filter-coursestatus-Active=on&filter-catalognumber-CS=on&filter-departmentcode-CS=on&filter-catalognumber-CS=on&q=CS&descriptions=on"
# Math
fetch "http://explorecourses.stanford.edu/print?filter-catalognumber-MATH=on&filter-coursestatus-Active=on&filter-departmentcode-MATH=on&filter-catalognumber-MATH=on&q=MATH&descriptions=on"
# EE
fetch "http://explorecourses.stanford.edu/print?filter-coursestatus-Active=on&filter-departmentcode-EE=on&filter-catalognumber-EE=on&filter-catalognumber-EE=on&q=EE&descriptions=on"

[Course, Requirement].each do |klass| 
    klass.seed
end
