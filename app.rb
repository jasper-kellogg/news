require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "2ad86ce7b338634f00a66ad12f6fa684"

get "/" do
  view "ask"
end

get "/news" do 
    results = Geocoder.search(params["location"])
    @city = params["location"]
    lat_lng = results.first.coordinates
    lat = lat_lng[0]
    lng = lat_lng[1]
    @forecast = ForecastIO.forecast(lat,lng).to_hash
    @current_temperature = @forecast["currently"]["temperature"]
    @current_conditions = @forecast["currently"]["summary"]

        # Declare arrays for forecast data
    @forecast_temperature = Array.new
    @forecast_summary = Array.new

    # For loop to create arrays for weather API
    i = 0
    for day in @forecast["daily"]["data"] do
        @forecast_temperature[i] = day["temperatureHigh"]
        @forecast_summary[i] = day["summary"]
        i = i+1
    end

url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=a1f79dbfbc224d388d42ae9b186ab76b"
news = HTTParty.get(url).parsed_response.to_hash

@headline = Array.new
@description = Array.new
@url = Array.new

for content in news["articles"]
@headline << content["title"]
@description << content["description"]
@url << content["url"]
end

view "news"
end