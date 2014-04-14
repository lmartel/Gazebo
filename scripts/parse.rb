require 'nokogiri'
require 'open-uri'
require_relative '../app/models/init'

puts "Usage: ruby parse.rb ExploreCoursesPrintableUrl" and exit 1 unless ARGV.length == 1
URL = ARGV[0]

doc = Nokogiri::HTML(open(URL))
dept = doc.css('#title > h1').first.content.split.last # HTML doc => "Results for CS" => "CS"
File.open "parse.#{dept.downcase}.out", 'w' do |out|
    doc.css('#printSearchResults > .searchResult').each do |result|
        name = result.css('.courseTitle').first.content
        number = result.css('.courseNumber').first.content.split(dept).last.strip.chomp(':') # HTML node => "CS 106A:" => "106A"
        attrs = result.css('.courseAttributes').first.content.split('|').map { |s|  # Extract attributes
            s.split(':', 2).map(&:strip)
        }.keep_if { |k, v| ["Terms", "Units"].include?(k) }.to_h # TODO: repeatable, GERs
        terms = attrs["Terms"].split(', ')
        units = attrs["Units"].split('-')
        out.puts "make(%q(#{name}), '#{number}', #{units.first}, #{units.last}).includes #{terms}"
    end
end
