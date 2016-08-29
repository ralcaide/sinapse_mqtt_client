require_relative "helpers"
require "mqtt"

module SinapseMQTTClient

	
	#MQTTClient: Class that implements the management of a MQTT Client
	# Connection, disconnection, send and receive
	
	class MQTTClient

		#attr_reader :number_of_bytes, :command, :source_address, :destination_address, :parameter_1, :parameter_2, :parameter_3, :pa, :ttl, :checksum, :parameter_4
		#attr_accessor :source_address, :destination_address
		attr_reader :client
		attr_accessor :client

		
   		# Function to connect to a MQTT Broker
   		# Inputs:
   		# host: String - Url of the broker
        # port: Int - Port number
        # tls: Boolean - SSL or not
        # user: String - Username
        # password: String - Password of the username
		def connect(host="m21.cloudmqtt.com", port=10609, tls=false, user="ugjznzkc", password="7UG2yVgH3zzi")
	
			@client = MQTT::Client.new
			
			if !@client.connected? then   
				@client.host = host
				@client.port = port
				@client.ssl = tls
				@client.username = user
				@client.password = password
				@client.connect()
				puts "MQTT client connected to the server"
			else
				puts "MQTT client already connected to the server"
			end

		end

		
		# Function to disconnect the MQTT client from the server / broker
		def disconnect()
			
			if @client.connected? then
				@client.disconnect()
				puts "MQTT client disconnected from the server"
			else
				puts "The client was not connected to the server"
			end
			
		end

		
		# Function to ask if the client is connected to the broker
		def connected?
			@client.connected?
		end

		
		# Function to publish a message in a given topic
		# Inputs:
		# topic: String - Address where the message will be published
		# message: String - Message that will be published
		def publish(topic, message)
			@client.publish(topic, message)
			puts "Message: "+ message + " published in " + topic
		end


		# Function to subscribe the client to any topic
		# Inputs: 
		# topic: String - Address where the client will be subscribed to
		def subscribe(topic)
			@client.subscribe(topic)
		end


		# Function to receive message from the subscribed topics.
		# It runs as a forever / infinite loop if it is called with a block. If not, it waits until a message is received and is returned to a the caller
		# If the method is called with a block, it is necessary to create a thread in order to doesn't block the program
		def receive_messages_from_subscribed_topics 
			##
			#Thread.new {
			#	@client.get do |topic, message|
			#		puts "Message received: " + message + "from: " + topic
			#	end
			#}
			if block_given?
				Thread.new {
					@client.get do |topic, message|
						yield(topic, message)
					end
				}	
			else 
				topic, message = @client.get
				return topic, message
			end
		end

	end
		
end