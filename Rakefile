def exec_ruby(script, *args)
  system("ruby", script, *args, out: $stdout, err: :out)
end

namespace :db do
  require_relative 'app/models/init' # opens DB connection, loads Sequel models

  desc "Opens ruby console with database connection"
  task :console do
    require 'irb'
    ARGV.clear
    IRB.start
  end

  desc "Initialize the database"
  task :init do
    DB.init
  end
  
  desc "Seed the database"
  task :seed do
    exec_ruby('scripts/seed_all.rb', 'scripts/out')
  end

  desc "Reset the database"
  task :reset do
    `rm test.db`
    # TODO figure out a way to reset the database from Sequel
  end
end

namespace :secret do
  desc "Generate a new CSRF secret token"
  task :generate do
    require "securerandom"
    puts SecureRandom.hex(64)  
  end
end

desc "Run the app on port 4567"
task :runserver do
  begin
    `rackup -p 4567`
  rescue Interrupt
    # Suppress "rake aborted" error on SIGINT
    sleep 0.5
  end
end