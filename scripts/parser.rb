require 'nokogiri'
require 'open-uri'

module ExploreCoursesParser

    class << self

        ABBR = /\([A-Z&]+\)/

        def scrape_departments_from(url)
            doc = Nokogiri::HTML(open(url))
            params = {}
            doc.css('li > a').each do |item|
                content = item.content
                next unless content =~ ABBR # Filter out non-departments. All departments have abbreviations.
                name, abbr = content.split(' (').map { |s| s.strip.chomp ')' }

                abbr = abbr.downcase.to_sym
                params[name] = abbr unless params.has_key?(name) || params.has_value?(abbr)
            end

            Seeds.seed_department do
                params.each do |name, abbr|
                    puts abbr
                    make name.dup, abbr unless Department[abbreviation: abbr.to_s]
                end
            end
        end

        def seed_from(url, output:".", with_offerings:false)
            doc = Nokogiri::HTML(open(url))
            dept = doc.css('#title > h1').first.content.split.last # HTML doc => "Results for CS" => "CS"
            dept = 'MS&E' if dept == 'MS' # bandaid
            File.open "#{output.chomp('/')}/parse.#{dept.downcase}.out", 'w' do |out|
                all_params = {}
                all_terms = {}
                doc.css('#printSearchResults > .searchResult').each do |result|
                    name = result.css('.courseTitle').first.content
                    number = result.css('.courseNumber').first.content.split.last.strip.chomp(':') # HTML node => "CS 106A:" => "106A"
                    desc = result.css('.courseDescription').first.content
                    attrs = result.css('.courseAttributes').first.content.split('|').map { |s|  # Extract attributes
                        s.split(':', 2).map(&:strip)
                    }.keep_if { |k, v| ["Terms", "Units"].include?(k) }.to_h # TODO: repeatable, GERs
                    terms = attrs["Terms"].split(', ') if attrs["Terms"]
                    units = attrs["Units"].split('-')

                    key = [name, number]
                    unless all_params.has_key?(key) # Ignore repeats
                        all_params[key] = [units.first, units.last, desc] 
                        all_terms[key] = terms
                    end
                end
                Seeds.seed_course dept do
                    all_params.each do |uniqs, extras|
                        puts uniqs.first
                        terms = all_terms[uniqs]
                        params = uniqs + extras

                        course = upmake(uniqs, extras)
                        course.includes terms if terms && with_offerings

                        # Output for reference. Omit description for length
                        params.pop
                        params = params.map { |p| "%q(#{p})" }.to_s.gsub('"', '')
                        out.puts "make(#{params}).includes #{(with_offerings and terms) or []}"
                    end
                end
            end
        end
    end
end
