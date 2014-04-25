require 'nokogiri'
require 'open-uri'

module ExploreCoursesParser

    class << self

        def seed_from(url, output:".")
            doc = Nokogiri::HTML(open(url))
            dept = doc.css('#title > h1').first.content.split.last # HTML doc => "Results for CS" => "CS"
            File.open "#{output.chomp('/')}/parse.#{dept.downcase}.out", 'w' do |out|
                doc.css('#printSearchResults > .searchResult').each do |result|
                    name = result.css('.courseTitle').first.content
                    number = result.css('.courseNumber').first.content.split(dept).last.strip.chomp(':') # HTML node => "CS 106A:" => "106A"
                    desc = result.css('.courseDescription').first.content
                    attrs = result.css('.courseAttributes').first.content.split('|').map { |s|  # Extract attributes
                        s.split(':', 2).map(&:strip)
                    }.keep_if { |k, v| ["Terms", "Units"].include?(k) }.to_h # TODO: repeatable, GERs
                    terms = attrs["Terms"].split(', ') if attrs["Terms"]
                    units = attrs["Units"].split('-')

                    Seeds.seed_course dept do
                        course = make(name, number, units.first, units.last, desc)
                        course.includes terms if terms
                    end
                    out.puts "make(%q(#{name}), '#{number}', #{units.first}, #{units.last}).includes #{terms}" # Output for reference with description omitted
                end
            end
        end
    end
end