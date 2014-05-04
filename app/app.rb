require 'rubygems'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sequel'

class TrackTracker < Sinatra::Base
    set :root, File.dirname(__FILE__) # You must set app root
    register Sinatra::AssetPack

    assets {
        serve '/js',     from: 'assets/js'        # Default
        serve '/css',    from: 'assets/css'       # Default
        # serve '/images', from: 'app/images'    # Default

        js :app, '/js/app.js', [
          '/js/*.js',
        ]

        css :app, '/css/app.css', [
          '/css/*.css'
        ]

        js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
        css_compression :simple   # :simple | :sass | :yui | :sqwish
    }

	DB_URL = 'sqlite://test.db'

	get '/' do
        @tracks = Track.all
        # @courses = Course.all.map { |c| c.summary }
		erb :index
	end

    get '/courses.json' do
        dept_id = params[:department]
        (dept_id ? Department[dept_id].courses : Course.all).map { |c|
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
