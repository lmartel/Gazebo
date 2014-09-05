require_relative '../app/models/init'
require_relative 'parser'

def fetch(url)
    if ARGV.length > 0
        ExploreCoursesParser.seed_from url, output:ARGV[0] 
    else 
        ExploreCoursesParser.seed_from url
    end
end

def url_for_department(dept)
    abbr = dept.abbreviation.upcase
    abbr = 'MS%26E' if abbr == "MSNE" # ugh
    "http://explorecourses.stanford.edu/print?q=#{abbr}&filter-coursestatus-Active=on&descriptions=on"
end

def main
    ExploreCoursesParser.scrape_departments_from "http://explorecourses.stanford.edu/browse"
    Department.each { |dept| fetch url_for_department(dept) }
end

main
