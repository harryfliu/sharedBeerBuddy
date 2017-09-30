require "json"
require "http"
require "optparse"


# Place holders for Yelp Fusion's OAuth 2.0 credentials. Grab them
# from https://www.yelp.com/developers/v3/manage_app
CLIENT_ID = 'Sge8Bu-UokjPscJR1Xd9yw'
CLIENT_SECRET = 'vI44X2b1JnhCFQEPUfEAmHKL4HUx8BjV2M7crwqtEsaEuTQaIHrhfnGOqU8pZT5z'


# Constants, do not change these
API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path
TOKEN_PATH = "/oauth2/token"
GRANT_TYPE = "client_credentials"


DEFAULT_BUSINESS_ID = "yelp-san-francisco"
DEFAULT_TERM = "dinner"
DEFAULT_LOCATION = "San Francisco, CA"
SEARCH_LIMIT = 10
SORT_PARAM = "rating"
PRICE_PARAM = "1, 2"
MILES_PARAM = 25000 # may have to have a meters to miles converter built in


# Make a request to the Fusion API token endpoint to get the access token.
# 
# host - the API's host
# path - the oauth2 token path
#
# Examples
#
#   bearer_token
#   # => "Bearer some_fake_access_token"
#
# Returns your access token
def bearer_token
  # Put the url together
  url = "#{API_HOST}#{TOKEN_PATH}"

  raise "Please set your CLIENT_ID" if CLIENT_ID.nil?
  raise "Please set your CLIENT_SECRET" if CLIENT_SECRET.nil?

  # Build our params hash
  params = {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    grant_type: GRANT_TYPE
  }

  response = HTTP.post(url, params: params)
  parsed = response.parse

  "#{parsed['token_type']} #{parsed['access_token']}"
end


# Make a request to the Fusion search endpoint. Full documentation is online at:
# https://www.yelp.com/developers/documentation/v3/business_search
#
# term - search term used to find businesses
# location - what geographic location the search should happen
#
# Examples
#
#   search("burrito", "san francisco")
#   # => {
#          "total": 1000000,
#          "businesses": [
#            "name": "El Farolito"
#            ...
#          ]
#        }
#
#   search("sea food", "Seattle")
#   # => {
#          "total": 1432,
#          "businesses": [
#            "name": "Taylor Shellfish Farms"
#            ...
#          ]
#        }
#
# Returns a parsed json object of the request
def search(term, location)
  url = "#{API_HOST}#{SEARCH_PATH}"
  params = {
    term: term,
    location: location,
    limit: SEARCH_LIMIT,
    sort_by: SORT_PARAM,
    price: PRICE_PARAM,
    open_now: true,
    radius: MILES_PARAM
  }

  response = HTTP.auth(bearer_token).get(url, params: params)
  response.parse
end


# Look up a business by a given business id. Full documentation is online at:
# https://www.yelp.com/developers/documentation/v3/business
# 
# business_id - a string business id
#
# Examples
# 
#   business("yelp-san-francisco")
#   # => {
#          "name": "Yelp",
#          "id": "yelp-san-francisco"
#          ...
#        }
#
# Returns a parsed json object of the request
def business(business_id)
  url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}"

  response = HTTP.auth(bearer_token).get(url)
  response.parse
end


options = {}
OptionParser.new do |opts|
  opts.banner = "Example usage: ruby sample.rb (search|lookup) [options]"

  opts.on("-tTERM", "--term=TERM", "Search term (for search)") do |term|
    options[:term] = term
  end

  opts.on("-lLOCATION", "--location=LOCATION", "Search location (for search)") do |location|
    options[:location] = location
  end

  opts.on("-bBUSINESS_ID", "--business-id=BUSINESS_ID", "Business id (for lookup)") do |id|
    options[:business_id] = id
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!


command = ARGV
print "Enter the filename you want to export data to (make sure you're in same directory as file): "
filename = $stdin.gets.chomp
puts "Opening file."
file = open(filename, 'w')
puts "Erasing file to prepare for new write..."
file.truncate(0)

case command.first
when "search"
  term = options.fetch(:term, DEFAULT_TERM)
  location = options.fetch(:location, DEFAULT_LOCATION)

  raise "business_id is not a valid parameter for searching" if options.key?(:business_id)

  response = search(term, location)

  file.write("Found #{response["total"]} businesses. Listing up to #{SEARCH_LIMIT}: \n\n")
  response["businesses"].each {|biz| 
    file.write("#{biz["name"]}  --  #{biz["location"]["display_address"]}  --  #{biz["display_phone"]} \n") 
  }

  final_destination = Array.new
  response["businesses"].delete_if {|biz, value| biz["rating"] < 3.5 }
  file.write("\nThis is the number of suitable destinations left. #{response["businesses"].length}")
  final_destination = response["businesses"].to_a.sample
  file.write("\n#{final_destination["name"]}\n")

when "lookup"
  business_id = options.fetch(:business_id, DEFAULT_BUSINESS_ID)


  raise "term is not a valid parameter for lookup" if options.key?(:term)
  raise "location is not a valid parameter for lookup" if options.key?(:lookup)

  response = business(business_id)

  puts "Found business with id #{business_id}:"
  puts JSON.pretty_generate(response)
else
  puts "Please specify a command: search or lookup"
end
