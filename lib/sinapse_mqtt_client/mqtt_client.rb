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

		attr_reader :installation_id
		attr_accessor :installation_id
		
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


		#Implementation of the API commands
		
		#EPD Commands (End Point Device commands)

		# Function ask_measurement_epd - API: 1. Pull measurement
		# Input arguments:
		# epd_id_list: List of epd devices. It should contains at least one epd id (RF or IoT)
		# ap_id: Id of the Access point to be used to reach the epd, or the list of epds. The AP_ID can be the ID of a AP, a group ID or
		# a broadcast ID. The default value is APID -> It is not necessary any AP to reach the end point device
		# Output:
		# Returns an array of hashes with the messages published in each topic. The hashes are like {:topic => topic, :message => message}
		def ask_measurement_epd(epd_id_list, ap_id="APID")
			
			check_general_arguments_and_connection_epd(epd_id_list, ap_id)

			messages_published = []
			
			basic_topic = @installation_id + "/"+ ap_id + "/" + "ACT/"
			message = "1;" 
			epd_id_list.each do |epd_id|
				topic = basic_topic + epd_id 	
				publish(topic, message)
				messages_published.push({:topic => topic, :message => message})
			end

			return messages_published
		end


		# Function lighting_profile_act_epd - API: 2. Lighting profile
		# Input arguments:
		# epd_id_list: List of epd devices. It should contains at least one epd id (RF or IoT)
		# lighting_profile: Array of hashes containing the lighting profile to be applied to the epd list. The hashes cointains
		# the dimming status (integer between 0 and 100) and the start time. Example:
		# [{:dimming => "0", :start_time => "09:00"}, {:dimming => "100", :start_time => "19:00"}]
		# ap_id: Id of the Access point to be used to reach the epd, or the list of epds. The AP_ID can be the ID of a AP, a group ID or
		# a broadcast ID. The default value is APID -> It is not necessary any AP to reach the end point device
		# Output:
		# Returns an array of hashes with the messages published in each topic. The hashes are like {:topic => topic, :message => message}
		def lighting_profile_act_epd(epd_id_list, lighting_profile, ap_id="APID")
			check_general_arguments_and_connection_epd(epd_id_list, ap_id)
			lighting_profile = arrange_lighting_profile_epd(lighting_profile)
			check_lighting_profile_epd(lighting_profile)

			messages_published = []
			basic_topic = @installation_id + "/"+ ap_id + "/" + "ACT/"

			# Create lighting profile message
			message = "2;"
			lighting_profile.each do |lighting_profile_step|
				message = message + lighting_profile_step[:dimming] + ";" + lighting_profile_step[:start_time] + ";" 
			end

			epd_id_list.each do |epd_id|
				topic = basic_topic + epd_id 	
				publish(topic, message)
				messages_published.push({:topic => topic, :message => message})
			end

			return messages_published

		end

		# Function on_demand_act_epd - API: 3. OnDemand Actuation (Lighting Status)
		# Input arguments:
		# epd_id_list: List of epd devices. It should contains at least one epd id (RF or IoT)
		# dimming: Integer between 0 and 100. It indicates the status of the light. 0=OFF, 100=ON(100%) 50=ON-DIMMING_TO(50%)
		# ap_id: Id of the Access point to be used to reach the epd, or the list of epds. The AP_ID can be the ID of a AP, a group ID or
		# a broadcast ID. The default value is APID -> It is not necessary any AP to reach the end point device
		# Output:
		# Returns an array of hashes with the messages published in each topic. The hashes are like {:topic => topic, :message => message}
		def on_demand_act_epd(epd_id_list, dimming, ap_id="APID")

			check_general_arguments_and_connection_epd(epd_id_list, ap_id)
			check_dimming_epd(dimming)

			messages_published = []
			
			basic_topic = @installation_id + "/"+ ap_id + "/" + "ACT/"
			message = "3;" + dimming.to_s + ";"   
			epd_id_list.each do |epd_id|
				topic = basic_topic + epd_id 	
				publish(topic, message)
				messages_published.push({:topic => topic, :message => message})
			end

			return messages_published

		end

		# Function configure_alert_threshold_act_epd - API: 6. Configure threshold
		# Input arguments:
		# epd_id_list: List of epd devices. It should contains at least one epd id (RF or IoT)
		# alerts_threshold: hash with three elements indicating the thresholds to create an alarm in relation with the
		# temperature in C, current in A and voltage in V. Example:
		# {:temperature => "50", current => "X", voltage => "260" }
		# Values: Int > 0, -1 (Delete threshold), "X" (Do not modify the current threshold)
		# ap_id: Id of the Access point to be used to reach the epd, or the list of epds. The AP_ID can be the ID of a AP, a group ID or
		# a broadcast ID. The default value is APID -> It is not necessary any AP to reach the end point device
		# Output:
		# Returns an array of hashes with the messages published in each topic. The hashes are like {:topic => topic, :message => message}
		def configure_alerts_threshold_act_epd(epd_id_list, alerts_threshold, ap_id="APID")

			check_general_arguments_and_connection_epd(epd_id_list, ap_id)
			check_alerts_threshold_epd(alerts_threshold)

			messages_published = []
			
			basic_topic = @installation_id + "/"+ ap_id + "/" + "ACT/"
			message = "6;" + alerts_threshold[:temperature]+ ";" + alerts_threshold[:current] + ";" + alerts_threshold[:voltage] + ";"   
			epd_id_list.each do |epd_id|
				topic = basic_topic + epd_id 	
				publish(topic, message)
				messages_published.push({:topic => topic, :message => message})
			end

			return messages_published

		end



		# AP / CMC Commands (Access Point commands)	

		# Function ask_measurement_ap - API: 9. Pull measurement
		# Input arguments:
		# ap_id_list:  List of AP devices. It should contains at least one AP ID. The AP_ID can be the ID of a AP, a group ID or
		# a broadcast ID.
		# Output:
		# Returns an array of hashes with the messages published in each topic. The hashes are like {:topic => topic, :message => message}
		def ask_measurement_ap(ap_id_list)
			
			check_general_arguments_and_connection_ap(ap_id_list)

			messages_published = []
			
			basic_topic = @installation_id + "/CMC/ACT/" 
			message = "1;" 
			ap_id_list.each do |ap_id|
				topic = basic_topic + ap_id 	
				publish(topic, message)
				messages_published.push({:topic => topic, :message => message})
			end

			return messages_published
		end		


		# Funtion change_relay_status_ap - API: 10. Status Change (Acy over relays)
		# Input arguments:
		# ap_id_list:  List of AP devices. It should contains at least one AP ID. The AP_ID can be the ID of a AP, a group ID or
		# a broadcast ID.
		# relay_status_list: List of seven elements that contains the status of each relay -> 0 / 1 / X
		# Output:
		# Returns an array of hashes with the messages published in each topic. The hashes are like {:topic => topic, :message => message}
		def change_relay_status_ap(ap_id_list, relay_status_list)
			
			check_general_arguments_and_connection_ap(ap_id_list)
			check_relay_status_list_ap(relay_status_list)

			messages_published = []
			
			basic_topic = @installation_id + "/CMC/ACT/" 
			message = "ACT" + relay_status_list[0] + ";ACT" + relay_status_list[1] + ";ACT" + relay_status_list[2] \
				+ ";ACT" + relay_status_list[3] \
				+ ";ACT" + relay_status_list[4] \
				+ ";ACT" + relay_status_list[5] \
				+ ";ACT" + relay_status_list[6] + ";"

			ap_id_list.each do |ap_id|
				topic = basic_topic + ap_id 	
				publish(topic, message)
				messages_published.push({:topic => topic, :message => message})
			end

			return messages_published

		end


private
		def check_general_arguments_and_connection_epd(epd_id_list, ap_id)
			unless connected?
				raise "The client is disconnected from the broker"
			end		

			if @installation_id.nil?
				raise "The ID of the installation can not be empty"
			end	

			if epd_id_list.empty?
				raise "It should be provided at least one EPD"
			end
			
			#TODO RAE: To check that AP_ID is valid
			unless is_valid_ap_id(ap_id)
				raise "The AP_ID is not valid"
			end

			#TODO RAE: To check each EPD_ID -> RF // IoT?
		
		end

		def check_dimming_epd(dimming)
			unless dimming.between?(-1, 100) #Dimming can be -1 in order to remove lighting profiles  
				raise "Dimming value is not in the correct range: 0 to 100"
			end

		end

		def check_lighting_profile_epd(lighting_profile) 
			#RAE TODO
			lighting_profile.each do |lighting_profile_step|
				check_dimming_epd(lighting_profile_step[:dimming].to_i)
			end
		end

		def check_alerts_threshold_epd(alerts_threshold)
			#RAE TODO
		end

		def arrange_lighting_profile_epd(lighting_profile)
			#RAE TODO: This function should arrange the hashes in relation to the start_time from 00:00 to 23:59
			return lighting_profile
		end

		def check_general_arguments_and_connection_ap(ap_id_list)
			unless connected?
				raise "The client is disconnected from the broker"
			end		

			if @installation_id.nil?
				raise "The ID of the installation can not be empty"
			end	

			if ap_id_list.empty?
				raise "It should be provided at least one AP"
			end
			
			#TODO RAE: To check that AP_ID is valid
			ap_id_list.each do |ap_id|
				unless is_valid_ap_id(ap_id)
					raise "The AP_ID is not valid"
				end
			end
		
		end

		def check_relay_status_list_ap(relay_status_list)
			unless relay_status_list.length == 7
				raise "The list of relay status should contains 7 elements"
			end

			relay_status_list.each do |relay_status|
				if /^[10X]$/.match(relay_status).nil?
					raise "The value of a relay status should be 1, 0 or X"
				end
			end

		end
	end
		
end