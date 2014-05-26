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

    get '/courses.json' do
        dept = params[:department]
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

    get '/' do
        @paths = (logged_in? ? current_user.paths : [])
        erb :index
    end

    get '/embark' do
        @tracks = Track.all
        erb :"path/new"
    end

    post '/embark' do
        if params[:tracks]
            path = Path.new name: params[:name], user_id: current_user.id
            path.tracks.concat params[:tracks].keys.map { |id| Track[id] }
            path.save
            redirect to('/')
        else
            flash[:error] = "Choose at least one major, minor, or track."
            redirect to('/embark')
        end
    end

end

require_relative 'init'
