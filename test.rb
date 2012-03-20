require 'bundler'
Bundler.require

#oauth info
app = ARGV[0]
secret = ARGV[1]

#We're cheating here a bit -- we're using a canned refresh token previously obtained by an oauth2 flow.
refresh_token = ARGV[2]

#see https://github.com/intridea/oauth2
client = OAuth2::Client.new(
  app,
  secret,
  site: 'https://accounts.google.com',
  token_url: '/o/oauth2/token',
  authorize_url: '/o/oauth2/auth', #won't need this, but here for completeness
  response_type: 'code',

  #you might need to modify this if your certs live somewhere else. or even just delete it.
  connection_opts: {
    ssl: { ca_path: "/etc/ssl/certs" }
  }
)

#construct the token manually
token = OAuth2::AccessToken.new(client, nil, refresh_token: refresh_token)

#refresh the token so that it gets a new #access_token
token = token.refresh!

#method for making actual requests
def make_request(token, verb, partial_url, content = nil, headers = {})
  url = "https://www.googleapis.com/calendar/v3/#{partial_url}"
  opts = 
    if content
      {
        headers: headers.merge({"Content-type" => "application/json"}),
        body: content.to_json
      }
    else {}
    end

  puts "Sending #{verb} to #{url}, body: #{opts[:body]}"
  
  begin
    response = token.request(verb, url, opts)
  rescue OAuth2::Error => err
    puts "Error: #{err.code}, Description: #{err.description}"
    puts "Response: #{err.response.body}"
    raise
  end
  unless response.status == 204
    #return the JSON hash
    Hashie::Mash.new(JSON(response.body))
  end   
end

puts "TASK: getting the list of calendars"
calendar_list = make_request token, :get, "users/me/calendarList"
calendar_list.items.each{|c| puts c.summary}

puts "TASK: creating a new calendar"
created = make_request token, :post, "calendars", {summary: "Hey, a calendar!"}
puts "created calendar #{created.id}"

uri_id = URI.escape(created.id)

puts "TASK: modifying its ACL"
make_request token, :post, "calendars/#{uri_id}/acl", {
  role: "freeBusyReader", 
  scope: {
    type: "default",
    value: "__public_principal__@public.calendar@google.com"
  }
}

puts "TASK: delete it"
make_request token, :delete, "calendars/#{uri_id}"