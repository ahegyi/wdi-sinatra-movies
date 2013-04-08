require 'sinatra/base'
# "continuous deployment", no need to restart server
require 'sinatra/reloader'

gem 'binding_of_caller'
require 'binding_of_caller'
require 'better_errors'

require 'open-uri'
require 'uri'
require 'json'

# require 'pry'
# # sinatra/reloader conflicts with later versions of sinatra
# gem 'sinatra', '1.3.0'
# require 'sinatra'

# # require 'sinatra/support/numeric'
# require 'sqlite3'

# require 'time'

class Movies < Sinatra::Base

  # Configure is only called once
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    OMDB_BASE = "http://www.omdbapi.com/"
  end

  # Before is called once per request
  before do
    @app_name = "Movies App"
    #Sets the default page title
    @page_title = @app_name
  end

  get '/' do
    @page_title += ": Home"

    erb :home
  end

  get '/search' do
    @q = params[:q]
    @type = params[:button]

    file = open(OMDB_BASE + "?s=" + URI.escape(@q))
    @api_result = JSON.load(file.read)

    if @api_result.keys.include?("Search")
      @results = @api_result["Search"]
    else
      @results = []
    end

    erb :results
  end

  get '/movies' do
    @id = params[:id]
    file = open(OMDB_BASE + "?i=" + URI.escape(@id))
    @result = JSON.load(file.read)

    @actors = @result["Actors"].split(", ")
    @directors = @result["Director"].split(", ")

    erb :detail
  end

  run!
end