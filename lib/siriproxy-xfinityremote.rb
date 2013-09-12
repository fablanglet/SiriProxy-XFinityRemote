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
	attr_accessor :user
	attr_accessor :password
	attr_accessor :client
	
  def initialize(config = {})
    #if you have custom configuration options, process them here!
    @user = config["user"]
    @password = config["password"]
	self.client = Connection.new(@user, @password)
  end

  #Change channel by number
  listen_for /Chaîne numéro ([0-9,]*[0-9])/i do |number|
	result = self.client.changeChannelByNumber(number)
	if (result != '200')
		say "Erreur"
		self.client = Connection.new(@user, @password)	
		request_completed 
	end
	say "Chaîne #{number} changé"
    request_completed 
  end
  #Change channel by number
  listen_for /Channel number ([0-9,]*[0-9])/i do |number|
	result = self.client.changeChannelByNumber(number)
	if (result != '200')
		say "Eror"
		self.client = Connection.new(@user, @password)	
		request_completed 
	end
	say "Channel #{number} changed"
    request_completed
  end
  #Change channel by name - Experimental need to optimize
  listen_for /Channel ([a-zA-Z0-9]*(?:\sHD)?)/i do |name|
	result = self.client.changeChannelByName(name)
	if (result != '200')
		say "Error"
		self.client = Connection.new(@user, @password)
		request_completed 
	end
	
	say "Now, You are watching #{name}"
    request_completed
  end
  #Change channel by name
  listen_for /Chaîne ([a-zA-Z0-9]*(?:\sHD)?)/i do |name|
	result = self.client.changeChannelByName(name)
	if (result != '200')
		say "Erreur"
		self.client = Connection.new(@user, @password)	
		request_completed 
	end
	say "Tu regardes #{name}"
    request_completed
  end
end
