#!/usr/bin/env ruby
require "net/http"
require "uri"
require "json"

class Connection	
	attr_accessor :cookie,:profilToken,:deviceKey,:channelList
	def initialize()
		self.cookie = auth()

		self.profilToken = getProfilToken(self.cookie )
		profileInfo = getProfileInfo(self.cookie , self.profilToken)
		self.deviceKey = profileInfo['UnifiedVal']['udf']['devices'][0]['rtune']['deviceKey']
		
		favoriteChannel = profileInfo['UnifiedVal']['uisTvPrefs']['favoriteChannels']['callSigns']
		channel = getChannelList(self.cookie)
		self.channelList = getfavoriteChannelNumber(favoriteChannel, channel)
	end
	
	def changeChannelByName(name)
		channel = findChannelNumber(name, self.channelList) 
		if (channel)
			token = getToken(self.cookie)
			return changeChannel(self.cookie , self.deviceKey, token, channel[0])
		else
			return 'Non trouvé'
		end
	end
	
	def changeChannelByNumber(number)
		token = getToken(self.cookie)
		return changeChannel(self.cookie, self.deviceKey , token, number)
	end
	
	def auth()
		http = Net::HTTP.new('login.comcast.net', 443)
		http.use_ssl = true
		path = '/login'

		# GET request -> so the host can set his cookies
		resp, data = http.get(path, nil)
		cookie = resp.response['set-cookie'].split('; ')[0]

		# POST request -> logging in
		data = 'user=&passwd='
		headers = {
		  'Cookie' => cookie,
		  'Referer' => 'https://login.comcast.net/login',
		  'Content-Type' => 'application/x-www-form-urlencoded'
		}

		resp, data = http.post(path, data, headers)
		#puts 'Code = ' + resp.code
		#puts 'Message = ' + resp.message
		#resp.each {|key, val| puts key + ' = ' + val}
		return resp.get_fields('set-cookie')
	end

	#'--------- GetProfil key -------------------'
	def getProfilToken(cookies)
		for i in 0..cookies.length
			if cookies[i] != nil 
				if cookies[i].index('tls_s_ticket') != nil 
					profilToken = cookies[i].gsub('tls_s_ticket=', '')[0,31]
					#puts profilToken
					break
				end
			end
		end
		return profilToken
	end

	#'--------------Get Device Key  ----------------------'
	def getDeviceKey(cookies, profilToken)
		uriDeviceKey = URI('http://xfinitytv.comcast.net/xtv/authkey/user?p='+ profilToken)
		http2 = Net::HTTP.new(uriDeviceKey.host, uriDeviceKey.port)
		req = Net::HTTP::Get.new(uriDeviceKey)
		req['Cookie'] = cookies

		responseKey =  http2.request(req)
		json = responseKey.body
		parser = JSON.parse(json)
		return parser['UnifiedVal']['udf']['devices'][0]['rtune']['deviceKey']
	end

	#'-------------- Profile Information  ----------------------'
	def getProfileInfo(cookies, profilToken)
		uriDeviceKey = URI('http://xfinitytv.comcast.net/xtv/authkey/user?p='+ profilToken)
		http2 = Net::HTTP.new(uriDeviceKey.host, uriDeviceKey.port)
		req = Net::HTTP::Get.new(uriDeviceKey)
		req['Cookie'] = cookies

		responseKey =  http2.request(req)
		json = responseKey.body
		parser = JSON.parse(json)
		#deviceKey = parser['UnifiedVal']['udf']['devices'][0]['rtune']['deviceKey']
		return parser
	end

	#'--------------Get Token  ----------------------'
	def getToken(cookies)
		uriToken = URI('http://xfinitytv.comcast.net/xip/fc-rproxy/rtune/authtoken')
		http1 = Net::HTTP.new(uriToken.host, uriToken.port)
		req = Net::HTTP::Get.new(uriToken)
		req['Origin'] = 'http://xfinitytv.comcast.net'
		req['Host'] = 'xfinitytv.comcast.net'
		req['Cookie'] = cookies
		response=  http1.request(req)
		token = response.body
		return token
	end

	#'--------------Send channel  ----------------------'
	def changeChannel(cookies, deviceKey, token, number)
		uriPostChannel = URI('http://xfinitytv.comcast.net/xip/fc-rproxy/rtune/device/'+ deviceKey + '/tune/tv/vcn/'+number)
		http3 = Net::HTTP.new(uriPostChannel.host, uriPostChannel.port)
		req1 = Net::HTTP::Post.new(uriPostChannel)
		req1['Origin'] = 'http://xfinitytv.comcast.net'
		req1['Host'] = 'xfinitytv.comcast.net'
		req1['X-CIM-RT-Authorization'] = token 
		req1['Cookie'] = cookies
		responseChannel =  http3.request(req1)
		puts 'Code = ' + responseChannel.code
		return responseChannel.code
	end
	#------------------- Get Channel Listing
	def getChannelList(cookies)
		beginInt = ((Time.local(Time.now.year, Time.now.month, Time.now.day, Time.now.hour).to_f*1000).to_i).to_s
		endInt = ((Time.local(Time.now.year, Time.now.month, Time.now.day, Time.now.hour+1).to_f*1000).to_i).to_s
		uriGetChannel = URI('http://xfinitytv.comcast.net/vodservice/rest/tv/rovi/grid/3601C/'+beginInt+'/'+endInt+'?version=3&hideDescription=true&hideImageUrl=true&hideSeasonNumber=true&tz=EDT')
		http = Net::HTTP.new(uriGetChannel.host, uriGetChannel.port)
		req1 = Net::HTTP::Get.new(uriGetChannel)
		req1['Cookie'] = cookies
		response = http.request(req1)
		parse = JSON.parse(response.body)
		return parse['grid']['channels']
	end

	def getfavoriteChannelNumber(favoriteChannel, channelList)
		arrayResult = Array.new
		channelList.each { |channelList|
			#Find channel in channelList
			isFavorite = favoriteChannel.select{|favorite| favorite == channelList[1] or favorite == channelList[2] }
			channelName = channelList[1]
			if (channelList[5][0] == 'hd')
				channelName = channelName + ' HD'
			end
			arrayResult.push([channelList[0], channelName, isFavorite != nil]) 
			if (channelList[2] != '' and channelList[1] != channelList[2])
				channelName = channelList[2]
				if (channelList[5][0] == 'hd')
					channelName = channelName + ' HD'
				end
				arrayResult.push([channelList[0], channelName, isFavorite != nil])
			end
		}
		return arrayResult
	end

	def findChannelNumber(name, channelList)
		result = channelList.select {|channel| channel[1] == name}
		return result[0]
	end

end


