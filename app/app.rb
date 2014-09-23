require 'rubygems'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/assetpack'
require 'sequel'
require 'rack/csrf'

class TrackTracker < Sinatra::Base
    set :root, File.dirname(__FILE__) # You must set app root
    register Sinatra::AssetPack
    register Sinatra::Flash
    use Rack::MethodOverride
    use Rack::Session::Cookie, secret: ENV['SECRET_TOKEN']
    use Rack::Csrf, :raise => true

    assets do
        serve '/js',     from: 'assets/js'        # Default
        serve '/css',    from: 'assets/css'       # Default
        # serve '/images', from: 'app/images'    # Default

        js :app, '/js/app.js', [
          '/js/lib/*.js',
          '/js/*.js'
        ]

        css :app, '/css/app.css', [
          '/css/lib/*.css',
          '/css/*.css'
        ]

        js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
        css_compression :simple   # :simple | :sass | :yui | :sqwish
    end

	DB_URL = 'sqlite://test.db'

    # Site routes
    get '/' do
        @paths = (logged_in? ? current_user.paths : [])
        @selection_override = flash[:selection_override]
        erb :index
    end

    get '/embark' do
        @tracks = Track.all
        erb :"path/new"
    end

    get '/courses/:dept/:num' do |dept_abbr, number|
        dept = Department[abbreviation: dept_abbr]
        halt 404 unless dept
        @course = Course[department_id: dept.id, number: number]
        halt 404 unless @course
        erb :'course/show'
    end

    get '/calendar' do
        session[:calendar] = true
        redirect back
    end

    get '/requirements' do
        session[:calendar] = false
        redirect back
    end

    get '/login' do
        erb :'user/new'
    end

    get '/logout' do
        session[:user] = nil
        redirect to('/')
    end


    # Form/AJAX routes

    post '/login' do
        user = User[email: params[:email]]
        redirect '/?err=email_not_found' if user.nil?
        if user.authenticate(params[:password])
            session[:user] = user.id
            redirect '/'
        else 
            redirect '/login?err=invalid_password'
        end
    end

    post '/signup' do
        begin
            user = User.create email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation], year: params[:year].to_i, term_id: current_term.id
        rescue Sequel::ValidationFailed
            redirect '/?err=email_taken'
        end
        session[:user] = user.id
        redirect '/'
    end

    post '/paths' do
        if params[:tracks]
            path = Path.create name: params[:name], user_id: current_user.id
            params[:tracks].keys.each { |tid| Paths_Track.create track_id: tid, path_id: path.id }

            flash[:selection_override] = path.id
            redirect to('/')
        else
            flash[:error] = "Choose at least one major, minor, or track."
            redirect to('/embark')
        end
    end

    put '/paths/:id' do |pid|
        halt 400 unless pid and (@path = Path[pid])
        halt 403 unless @path.user == current_user
        @path.layout!
        flash[:selection_override] = @path.id
        redirect to('/')
    end

    post '/enrollments' do
        cid = params[:course]
        halt 400 unless cid and (course = Course[cid])
        paths = params[:paths]
        halt 400 unless paths and !paths.empty?
        paths = paths.map {|pid| Path[pid.to_i] }
        halt 403 unless paths.all? {|p| p.user == current_user }

        # TODO: assign a term and year intelligently based on current enrollments
        possible_terms = Term.enrollable.select {|t| course.terms.include?(t) }
        halt 406 if possible_terms.empty?
        now = Quarter.new(current_user.year, current_user.term)
        new_enrollments = paths.map do |p|
            try_quarter = now.dup
            try_quarter.next!(possible_terms) unless possible_terms.include?(try_quarter.term)
            try_quarter.next!(possible_terms) until Enrollment.where(path_id: p.id, year: try_quarter.year, term_id: try_quarter.term.id).map {|e| e.course.units_max }.reduce(0, :+) <= 20
            e = Enrollment.create(path_id: p.id, course_id: course.id, year: try_quarter.year, term_id: try_quarter.term.id) or halt 500
            [render_cell(e, path:p, closable:true), e.year, e.term.id]
        end
        status 200
        new_enrollments.to_json
    end

    put '/enrollments/:id/requirement' do |id|
        halt 400 unless id and (enrollment = Enrollment[id.to_i])
        halt 403 unless enrollment.path.user == current_user

        req_id = params[:requirement]
        requirement = nil
        halt 400 unless req_id.empty? or (requirement = Requirement[req_id.to_i])

        enrollment.requirement = requirement
        status(enrollment.save ? 200 : 500)
    end

    put '/enrollments/:id/term' do |id|
        halt 400 unless id and (enrollment = Enrollment[id.to_i])
        halt 403 unless enrollment.path.user == current_user

        halt 400 unless (term = Term.enrollable[params[:term].to_i - 1]) and (year = params[:year].to_i)

        enrollment.term = term
        enrollment.year = year
        status(enrollment.save ? 200 : 500)
        body Quarter.css_class(Quarter.new(enrollment.year, enrollment.term), Quarter.new(current_user.year, current_user.term))
    end

    delete '/enrollments/:id' do |id|
        halt 400 unless id and (enrollment = Enrollment[id.to_i])
        halt 403 unless enrollment.path.user == current_user

        status (enrollment.destroy ? 200 : 500)
    end

    get '/requirements.json/:id' do |req_id|
        Requirement[req_id.to_i].courses.map { |c| 
            dept = c.department.abbreviation
            num = c.number
            %Q(#{dept}#{num}: <a href="/courses/#{dept.downcase}/#{num.downcase}">#{pp c}</a> [#{pp_units c} units])
        }.to_json
    end

    # API routes
    get '/courses.json/?:dept?' do |dept|
        if dept
            dept = Department[abbreviation: dept] or Department.search(dept)
            courses = dept.courses if dept
        else
            courses = Course.all
        end
        (courses or []).map { |c|
            { id: c.id, text: pp(c.summary) }
        }.compact.to_json
    end

    get '/departments.json' do
        (Department.all.map do |d|
            { id: d.id, text: d.abbreviation }
        end).to_json
    end

end

require_relative 'init'
