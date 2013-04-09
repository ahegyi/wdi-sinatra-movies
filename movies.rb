require 'sinatra'
# "continuous deployment", no need to restart server
require 'sinatra/reloader'

require 'pry'

gem 'binding_of_caller'
require 'binding_of_caller'
require 'better_errors'

require 'open-uri'
require 'uri'
require 'json'


# Configure is only called once
configure :development do
  register Sinatra::Reloader
end

configure do
  OMDB_BASE = "http://www.omdbapi.com/"
end

# Before is called once per request
before do
  @app_name = "Movistar*"
  #Sets the default page title
  @page_title = @app_name
end

get '/' do
  @page_title += ": Home"

  erb :home
end

get '/search' do
  @q = params[:q]
  @page_title += ": Search for '#{@q}'"

  @type = params[:button]

  file = open(OMDB_BASE + "?s=" + URI.escape(@q))
  @results = JSON.load(file.read)["Search"] || []

  if @results.size == 1 || (@type == "lucky" && @results.size > 0)
    redirect "/movies?id=#{@results.first["imdbID"]}"
  end

  # Old fashioned way of doing things...
  # @api_result = JSON.load(file.read)
  # if @api_result.keys.include?("Search")
  #   @results = @api_result["Search"]
  # else
  #   @results = []
  # end

  erb :serp
end

get '/movies' do
  @id = params[:id]
  @q = params[:q] || ""

  file = open(OMDB_BASE + "?i=" + URI.escape(@id) + "&tomatoes=true")
  @result = JSON.load(file.read)

  @page_title += ": #{@result["Title"]}"
  @actors = @result["Actors"].split(", ")
  @directors = @result["Director"].split(", ")

  related = open(OMDB_BASE + "?s=" + URI.escape(@result["Title"]))
  @results = JSON.load(related.read)["Search"] || []
  @results.reject!{|movie| movie["Title"] == @result["Title"]}

  erb :detail
end