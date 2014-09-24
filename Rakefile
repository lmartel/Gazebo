def exec_ruby(script, *args) # Execute ruby script with live stdout
  system("ruby", script, *args, out: $stdout, err: :out)
end

namespace :db do
  require_relative 'app/models/init' # opens DB connection, loads Sequel models
  Sequel.extension :migration

  desc "Opens ruby console with database connection"
  task :console do
    require 'irb'
    ARGV.clear
    IRB.start
  end

  desc "Seed database, scraping departments and classes from ExploreCourses"
  task :seed do
    `rm scripts/out/*`
    Term.seed unless Term.count > 0
    exec_ruby('scripts/scrape_and_seed.rb', 'scripts/out')
    [Department, Track, Course, Requirement].each { |klass| klass.seed }
    exec_ruby('scripts/seed_test_data.rb')
  end

  desc "Clear and re-seed requirements and tracks, without re-scraping departments and courses."
  task :reseed do
    Term.seed unless Term.count > 0
    [Departments_Requirement, Requirements_Course, Paths_Track, Paths_Course, Requirement, Track, Path, User].each do |klass| 
        klass.each { |m| m.delete }
    end
    [Track, Requirement].each do |klass| 
        klass.seed
    end
    exec_ruby('scripts/seed_test_data.rb')
  end

  desc "Update departments and courses, refreshing terms offered"
  task :rescrape do
    `rm scripts/out/*`
    Courses_Term.each { |m| m.delete }
    exec_ruby('scripts/scrape_and_seed.rb', 'scripts/out')
  end

  desc "Prints current schema version"
  task :version do    
    version = if DB.tables.include?(:schema_info)
      DB[:schema_info].first[:version]
    end || 0
 
    puts "Schema Version: #{version}"
  end
 
  desc "Perform migration up to latest migration available"
  task :migrate do
    Sequel::Migrator.run(DB, "migrations")
    Rake::Task['db:version'].execute
  end
    
  desc "Perform rollback to specified target or full rollback as default"
  task :rollback, :target do |t, args|
    args.with_defaults(:target => 0)
 
    Sequel::Migrator.run(DB, "migrations", :target => args[:target].to_i)
    Rake::Task['db:version'].execute
  end
 
  desc "Perform migration reset (full rollback and migration)"
  task :reset do
    Sequel::Migrator.run(DB, "migrations", :target => 0)
    Sequel::Migrator.run(DB, "migrations")
    Rake::Task['db:version'].execute
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
