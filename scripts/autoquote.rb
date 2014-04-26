# A quick script to put quotes around courses with compound 
# course numbers (eg, '181W') while leaving integers unquoted.

exit 1 if ARGV.empty? or ARGV[0].nil?
list = ARGV[0]
puts '[' + list.split(/[,;]/).map { |course|
    course = course.upcase.strip
    (course =~ /\D/) ? "'#{course}'" : course
}.join(', ') + ']'
