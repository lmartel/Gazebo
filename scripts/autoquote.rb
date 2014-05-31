# A quick script to put quotes around courses with compound 
# course numbers (eg, '181W') while leaving integers unquoted.

# from https://stackoverflow.com/questions/13839940/ruby-gets-that-works-over-multiple-lines
$/ = "\n\n" # gets waits until two consecutive newlines are encountered

def process(list)
    puts '[' + list.split(/[,;]/).map { |course|
        course = course.upcase.strip
        (course =~ /\D/) ? "'#{course}'" : course
    }.join(', ') + ']'
end

if ARGV.length > 0
    list = ARGV[0]
    process list
else 
    begin
        loop do
            list = gets.chomp
            process list
        end
    rescue Exception => e
        exit 0
    end
end