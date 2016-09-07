require_relative "helpers"
require "mqtt"

module SinapseMQTTClientWrapper

	
	# SinapseMQTTClient  
	# Class that implements the management of a MQTT Client offering the Sinapse API 
	# This class inherits from MQTT::Client : https://github.com/njh/ruby-mqtt
	# and provides methods that offer the Sinapse API: Create Sinapse messages and publish them in the Sinapse formatted topics
	# The methods for the MQTT Client management are the ones provided my MQTT::Client
	
	class SinapseMQTTClient < MQTT::Client

		#attr_reader :number_of_bytes, :command, :source_address, :destination_address, :parameter_1, :parameter_2, :parameter_3, :pa, :ttl, :checksum, :parameter_4
		#attr_accessor :source_address, :destination_address
		
		# Connect
		# Overrides the connect method of MQTT::Client because the parent method leaves 
		# a connected = true after a fail connect. After a fail connect, the method 
		# connected? should return false instead of true
		def connect
			begin
				super
			rescue Exception => ex
				disconnect() #TODO RAE: This behaviour works when the problem is not due to SSL. Try to fix it for SSL
				raise ex
			end

		end


		# Function to receive message from the subscribed topics.
		# It runs as a forever / infinite loop if it is called with a block. If not, it waits until a message is received and is returned to a the caller
		# If the method is called with a block, it is necessary to create a thread in order to doesn't block the program
		def receive_messages_from_subscribed_topics 
			if block_given?
					#@client.get do |topic, message|
					get do |topic, message|	
						yield(topic, message)
					end
			else 
				#topic, message = @client.get
				topic, message = get
				return topic, message
			end
		end

	end
		
end