require 'cora'
require 'siri_objects'
require 'pp'
require "net/http"
require "uri"
require "json"
require_relative 'connection.rb'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "test siri proxy" and responds
# with a message about the proxy being up and running (along with a couple other core features). This
# is good base code for other plugins.
#
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::XFinityRemote < SiriProxy::Plugin
  def initialize(config)
    #if you have custom configuration options, process them here!
	@client = Connection.new()
  end

  #get the user's location and display it in the logs
  #filters are still in their early stages. Their interface may be modified
  filter "SetRequestOrigin", direction: :from_iphone do |object|
    puts "[Info - User Location] lat: #{object["properties"]["latitude"]}, long: #{object["properties"]["longitude"]}"

    #Note about returns from filters:
    # - Return false to stop the object from being forwarded
    # - Return a Hash to substitute or update the object
    # - Return nil (or anything not a Hash or false) to have the object forwarded (along with any
    #    modifications made to it)
  end

  
  listen_for /loreana/i do
    say "Je t'aime!" #say something to the user!
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  #demonstrate capturing data from the user (e.x. "Siri proxy number 15")
  listen_for /Chaîne numéro ([0-9,]*[0-9])/i do |number|
	result = @client.changeChannelByNumber(number)
	if (result != '200')
		say "Erreur"
		@client = Connection.new()	
		request_completed 
	end
	say "Chaîne #{number} changé"
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  listen_for /Channel number ([0-9,]*[0-9])/i do |number|
	say "Channel #{number} changed"
	result = @client.changeChannelByNumber(number)
	if (result != '200')
		say "Erreur"
		@client = Connection.new()	
		request_completed 
	end
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  listen_for /Channel ([a-zA-Z0-9]*[a-zA-Z0-9]*[a-zA-Z0-9]*[a-zA-Z0-9])/i do |name|
	result = @client.changeChannelByName(name)
	if (result != '200')
		say "Erreur"
		@client = Connection.new()	
		request_completed 
	end
	
	say "Now, You are watching #{name}"
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
  
  listen_for /Chaîne ([a-zA-Z0-9]*[a-zA-Z0-9]*[a-zA-Z0-9]*[a-zA-Z0-9])/i do |name|
	result = @client.changeChannelByName(name)
	if (result != '200')
		say "Erreur"
		@client = Connection.new()	
		request_completed 
	end
	say "Tu regardes #{name}"
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
end
