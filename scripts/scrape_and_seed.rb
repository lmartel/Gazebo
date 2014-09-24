require_relative '../app/models/init'
require_relative 'parser'

def fetch(url, with_offerings: false)
    if ARGV.length > 0
        ExploreCoursesParser.seed_from url, output:ARGV[0], with_offerings: with_offerings
    else 
        ExploreCoursesParser.seed_from url, with_offerings: with_offerings
        puts "seeding_from...???"
    end
end

def url_for_department(dept, year)
    abbr = dept.abbreviation.upcase
    abbr = 'MS%26E' if abbr == "MSNE" # ugh
    year = "#{(year - 1)}#{year}" # Ex. 2012 => 20112012
    "http://explorecourses.stanford.edu/print?q=#{abbr}&filter-coursestatus-Active=on&descriptions=on&&academicYear=#{year}"
end

THIS_YEAR = 2015

def main
    ExploreCoursesParser.scrape_departments_from "http://explorecourses.stanford.edu/browse"
    Department.each do |dept|
        (2012..THIS_YEAR).each do |year|
            fetch url_for_department(dept, year), with_offerings: year == THIS_YEAR
        end
    end
end

main
