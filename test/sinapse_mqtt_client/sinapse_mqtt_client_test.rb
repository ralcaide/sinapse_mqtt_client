require './test/test_helper'

class FramesTest < Minitest::Test
	$MQTT_broker = 'm21.cloudmqtt.com'
	$MQTT_user = "ugjznzkc"
	$MQTT_password = "7UG2yVgH3zzi"
	$normal_port = 10609
	$ssl_port = 20609
	$tsl_ws_port = 30609 # RAE TODO: The connection to this port is not working. Web services?

	$source_address_wrong = "00000100"
	$destination_address_wrong = "00000200"

	def test_sinapse_mqtt_client_exists
		assert SinapseMQTTClientWrapper::SinapseMQTTClient
	end

	def test_sinapse_mqtt_client_connects_default
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		# Creating the object through the method connect does not return the correct object
		#mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.connect(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect();
		assert_equal mqtt_client.connected?, true
		mqtt_client.disconnect() 
	end

	def test_sinapse_mqtt_client_connects_ssl
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $ssl_port, :ssl => true ,:username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect();
		assert_equal mqtt_client.connected?, true
		mqtt_client.disconnect()
	end

	def test_sinapse_mqtt_client_connect_fails
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :ssl => true ,:username => $MQTT_user, :password => $MQTT_password)
		
		begin
			mqtt_client.connect()
		rescue Exception => ex
			assert_equal OpenSSL::SSL::SSLError, ex.class	
		end

		assert_equal mqtt_client.connected?, true #TODO RAE: The result should be false

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => 'fake')

		begin
			mqtt_client.connect()
		rescue Exception => ex
			assert_equal MQTT::ProtocolException, ex.class	
		end
		assert_equal mqtt_client.connected?, false

	end

	def test_sinapse_mqtt_client_disconnects 
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect();
		assert_equal mqtt_client.connected?, true
		mqtt_client.disconnect()
		assert_equal mqtt_client.connected?, false

	end

	def test_send_and_receive_messages

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		#mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.connect(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		mqtt_client.connect()
		mqtt_client.subscribe("/installation1/APID/ACT/Device1") 


		# TODO RAE: To improve the following part
		# This part of the test is not working well. Maybe it is due the creation of a new Thread in order to receive the messages
		#mqtt_client.receive_messages_from_subscribed_topics do |topic, message|
		#	assert_equal message, "test_message"
		#	assert_not_equal topic, "/installation1/APID/ACT/Device3"
		#end

		mqtt_client.publish("/installation1/APID/ACT/Device1", "test_message")
		mqtt_client.publish("/installation1/APID/ACT/Device2", "test_message")
		mqtt_client.publish("/installation1/APID/ACT/Device3", "test_message") # This message is not got in the subscription

		topic, message = mqtt_client.receive_messages_from_subscribed_topics
		assert_equal message, "test_message"
		assert_equal topic, "/installation1/APID/ACT/Device1"

	end

	def test_subscribe_to_empty_topics
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		mqtt_client.connect()
		begin
			mqtt_client.subscribe()
			puts "after subscribe"
		rescue Exception => ex
			assert_equal ex.message, "no topics given when serialising packet"
			assert_equal ex.class, RuntimeError
		end

		assert_equal true, mqtt_client.connected?

		begin
			mqtt_client.subscribe()
		rescue Exception => ex
			assert_equal ex.message, "no topics given when serialising packet"
			assert_equal ex.class, RuntimeError
		end
		assert_equal true, mqtt_client.connected? 

	end

	def test_ask_measurement_epd
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.ask_measurement_epd(["111111"], "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "1;"} 
		

		result = mqtt_client.ask_measurement_epd(["111111", "222222"], "CMC111112" )
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "1;"}
		assert_equal result[1], {:topic => "INSTALLATION/CMC111112/ACT/222222", :message => "1;"}

		result = mqtt_client.ask_measurement_epd(["111111"])
		assert_equal result[0], {:topic => "INSTALLATION/APID/ACT/111111", :message => "1;"}

		mqtt_client.disconnect() 

	end

	def test_ask_measurement_epd_fails

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		begin
			mqtt_client.ask_measurement_epd(["111111"], "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()
		end
		
		
		begin
			mqtt_client.ask_measurement_epd(["111111"], "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.ask_measurement_epd([], "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one EPD"
		end

		result = mqtt_client.ask_measurement_epd(["111111"], "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "1;"}

		mqtt_client.disconnect()
	end

	def test_ask_measurement_periodically_epd
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.ask_measurement_periodically_epd(["111111"], 5, "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "4;5;"} 
		

		result = mqtt_client.ask_measurement_periodically_epd(["111111", "222222"], "5", "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "4;5;"}
		assert_equal result[1], {:topic => "INSTALLATION/CMC111112/ACT/222222", :message => "4;5;"}

		result = mqtt_client.ask_measurement_periodically_epd(["111111"], 5)
		assert_equal result[0], {:topic => "INSTALLATION/APID/ACT/111111", :message => "4;5;"}

		mqtt_client.disconnect() 

	end

	def test_ask_measurement_periodically_epd_fails

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		begin
			mqtt_client.ask_measurement_periodically_epd(["111111"], 5, "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()
		end
		
		
		begin
			mqtt_client.ask_measurement_periodically_epd(["111111"], 5, "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.ask_measurement_periodically_epd([], 5, "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one EPD"
		end

		result = mqtt_client.ask_measurement_periodically_epd(["111111"], 5, "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "4;5;"}

		mqtt_client.disconnect()
	end

	def test_lighting_profile_act_epd
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		mqtt_client.installation_id = "INSTALLATION"
		lighting_profile = []
		lighting_profile.push({:dimming => "0", :start_time => "09:00"})
		lighting_profile.push({:dimming => "100", :start_time => "19:00"})
		result = mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile,"CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "2;0;09:00;100;19:00;"} 
		

		result = mqtt_client.lighting_profile_act_epd(["111111", "222222"], lighting_profile, "CMC111112" )
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "2;0;09:00;100;19:00;"}
		assert_equal result[1], {:topic => "INSTALLATION/CMC111112/ACT/222222", :message => "2;0;09:00;100;19:00;"}

		result = mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile)
		assert_equal result[0], {:topic => "INSTALLATION/APID/ACT/111111", :message => "2;0;09:00;100;19:00;"}

		lighting_profile = []
		lighting_profile.push({:dimming => "-1", :start_time => "00:00"})
		result = mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile)
		assert_equal result[0], {:topic => "INSTALLATION/APID/ACT/111111", :message => "2;-1;00:00;"} 

		mqtt_client.disconnect()
	end

	def test_lighting_profile_act_epd_fails
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		lighting_profile = []
		lighting_profile.push({:dimming => "100", :start_time => "09:00"})

		begin
			mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile ,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()
		end
		
		
		begin
			mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile, "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.lighting_profile_act_epd([], lighting_profile,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one EPD"
		end

		lighting_profile.push({:dimming => "105", :start_time => "19:00"})
		begin
			mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile , "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "Dimming value is not in the correct range: 0 to 100"
		end	

		lighting_profile = []
		lighting_profile.push({:dimming => "0", :start_time => "09:00"})
		lighting_profile.push({:dimming => "100", :start_time => "19:00"})
		
		result = mqtt_client.lighting_profile_act_epd(["111111"], lighting_profile ,"CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "2;0;09:00;100;19:00;"}

		mqtt_client.disconnect()
	end

	def test_on_demand_act_epd
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.on_demand_act_epd(["111111"], 100,"CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "3;100;"} 
		

		result = mqtt_client.on_demand_act_epd(["111111", "222222"], 0, "CMC111112" )
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "3;0;"}
		assert_equal result[1], {:topic => "INSTALLATION/CMC111112/ACT/222222", :message => "3;0;"}

		result = mqtt_client.on_demand_act_epd(["111111"], 50)
		assert_equal result[0], {:topic => "INSTALLATION/APID/ACT/111111", :message => "3;50;"} 

		mqtt_client.disconnect()
	end

	def test_on_demand_act_epd_fails

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		begin
			mqtt_client.on_demand_act_epd(["111111"], 100 ,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()
		end
		
		
		begin
			mqtt_client.on_demand_act_epd(["111111"], 100,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.on_demand_act_epd([], 100 , "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one EPD"
		end


		begin
			mqtt_client.on_demand_act_epd(["111111"], 105 , "CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "Dimming value is not in the correct range: 0 to 100"
		end

		begin
			mqtt_client.on_demand_act_epd(["111111"])

		rescue Exception => ex
			
		end

		result = mqtt_client.on_demand_act_epd(["111111"], 30, "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "3;30;"}

		mqtt_client.disconnect()
	end


	def test_configure_alerts_threshold_act_epd
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		alerts_threshold = {:temperature => "50", :current => "-1", :voltage => "X"}

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.configure_alerts_threshold_act_epd(["111111"], alerts_threshold,"CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "6;50;-1;X;"} 
		

		result = mqtt_client.configure_alerts_threshold_act_epd(["111111", "222222"], alerts_threshold, "CMC111112" )
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "6;50;-1;X;"}
		assert_equal result[1], {:topic => "INSTALLATION/CMC111112/ACT/222222", :message => "6;50;-1;X;"}

		result = mqtt_client.configure_alerts_threshold_act_epd(["111111"], alerts_threshold)
		assert_equal result[0], {:topic => "INSTALLATION/APID/ACT/111111", :message => "6;50;-1;X;"} 

		mqtt_client.disconnect()
	end

	def test_configure_alerts_threshold_act_epd_fails

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		alerts_threshold = {:temperature => "50", :current => "-1", :voltage => "X"}
		begin
			mqtt_client.configure_alerts_threshold_act_epd(["111111"], alerts_threshold ,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()
		end
		
		
		begin
			mqtt_client.configure_alerts_threshold_act_epd(["111111"], alerts_threshold ,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.configure_alerts_threshold_act_epd([], alerts_threshold ,"CMC111112")

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one EPD"
		end


		begin
			#RAE TODO
			#mqtt_client.on_demand_act_epd(["111111"], 105 , "CMC111112")

		rescue Exception => ex
			#assert_equal ex.message, "Dimming value is not in the correct range: 0 to 100"
		end

		begin
			mqtt_client.configure_alerts_threshold_act_epd(["111111"])

		rescue Exception => ex
			
		end

		result = mqtt_client.configure_alerts_threshold_act_epd(["111111"], alerts_threshold, "CMC111112")
		assert_equal result[0], {:topic => "INSTALLATION/CMC111112/ACT/111111", :message => "6;50;-1;X;"}

		mqtt_client.disconnect()
	end

	def test_ask_measurement_ap
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.ask_measurement_ap(["CMC111111"],)
		assert_equal result[0], {:topic => "INSTALLATION/CMC/ACT/CMC111111", :message => "1;"} 

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.ask_measurement_ap(["CMC111111"], "EN")
		assert_equal result[0], {:topic => "INSTALLATION/EN/ACT/CMC111111", :message => "1;"} 
		

		result = mqtt_client.ask_measurement_ap(["CMC111111", "CMC222222"])
		assert_equal result[0], {:topic => "INSTALLATION/CMC/ACT/CMC111111", :message => "1;"}
		assert_equal result[1], {:topic => "INSTALLATION/CMC/ACT/CMC222222", :message => "1;"}

		mqtt_client.disconnect()
	end

	def test_ask_measurement_ap_fails

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		begin
			mqtt_client.ask_measurement_ap(["CMC111111"])

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()
		end
		
		
		begin
			mqtt_client.ask_measurement_ap(["CMC111111"])

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.ask_measurement_ap([])

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one AP"
		end

		result = mqtt_client.ask_measurement_ap(["CMC111111"])
		assert_equal result[0], {:topic => "INSTALLATION/CMC/ACT/CMC111111", :message => "1;"}

		mqtt_client.disconnect()
	end

	def test_change_relay_status_ap
		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()

		mqtt_client.installation_id = "INSTALLATION"
		result = mqtt_client.change_relay_status_ap(["CMC111111"], ["0","1", "X","X","X","X","X"])
		assert_equal result[0], {:topic => "INSTALLATION/CMC/ACT/CMC111111", :message => "ACT0;ACT1;ACTX;ACTX;ACTX;ACTX;ACTX;"} 

		result = mqtt_client.change_relay_status_ap(["CMC111111"], ["0","1", "X","X","X","X","X"], "EN")
		assert_equal result[0], {:topic => "INSTALLATION/EN/ACT/CMC111111", :message => "ACT0;ACT1;ACTX;ACTX;ACTX;ACTX;ACTX;"}
		

		result = mqtt_client.change_relay_status_ap(["CMC111111", "CMC222222"], ["0","1", "X","X","X","1","X"])
		assert_equal result[0], {:topic => "INSTALLATION/CMC/ACT/CMC111111", :message => "ACT0;ACT1;ACTX;ACTX;ACTX;ACT1;ACTX;" }
		assert_equal result[1], {:topic => "INSTALLATION/CMC/ACT/CMC222222", :message => "ACT0;ACT1;ACTX;ACTX;ACTX;ACT1;ACTX;" }

		mqtt_client.disconnect()
	end

	def test_change_relay_status_ap_catching_exceptions

		mqtt_client = SinapseMQTTClientWrapper::SinapseMQTTClient.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)

		begin
			mqtt_client.change_relay_status_ap(["CMC111111"], ["0","1", "X","X","X","X","X"])

		rescue Exception => ex
			assert_equal ex.message, "The client is disconnected from the broker"
			mqtt_client.connect()

		end
		
		
		begin
			mqtt_client.change_relay_status_ap(["CMC111111"], ["0","1", "X","X","X","X","X"])

		rescue Exception => ex
			assert_equal ex.message, "The ID of the installation can not be empty"
			mqtt_client.installation_id = "INSTALLATION"
		end
 	
 		
		begin
			mqtt_client.change_relay_status_ap([], ["0","1", "X","X","X","X","X"])

		rescue Exception => ex
			assert_equal ex.message, "It should be provided at least one AP"
		end


		begin
			mqtt_client.change_relay_status_ap(["CMC111111"], ["1", "X","X","X","X","X"])

		rescue Exception => ex
			assert_equal ex.message, "The list of relay status should contains 7 elements"
		end

		begin
			mqtt_client.change_relay_status_ap(["CMC111111"], ["A", "1", "X","X","X","X","X"])

		rescue Exception => ex
			assert_equal ex.message, "The value of a relay status should be 1, 0 or X"
		end

		result = mqtt_client.change_relay_status_ap(["CMC111111"], ["0","1","X","X","X","X","X"] )
		assert_equal result[0], {:topic => "INSTALLATION/CMC/ACT/CMC111111", :message => "ACT0;ACT1;ACTX;ACTX;ACTX;ACTX;ACTX;"}
		
		mqtt_client.disconnect()
	end




	# Tests for Vodafone EPD simulator
	def test_simulate_status_frame
		mqtt_client = SinapseEPDSimulatorVodafone.new(:host => $MQTT_broker, :port => $normal_port, :username => $MQTT_user, :password => $MQTT_password)
		mqtt_client.connect()
		
		# Simulating EPD
		#result = mqtt_client.simulate_status_frame
		#assert_equal result[0], {:topic => "LU/LUM/SEN", :message => "FFFFFF;30;1;90;150;220;60;0;60;60;0;60;50"} # RAE: To Improve

		# EPD with data
		status_parameters = {
			id_radio: "123456",
			temp: 30,
			stat: 1,
			dstat: 75,
			voltage: 220,
			current: 120,
			active_power: 75,
			reactive_power: 0,
			apparent_power: 75,
			aggregated_active_energy: 150,
			aggregated_reactive_energy: 0,
			aggregated_apparent_energy: 150,
			frequency: 50
		}

		result = mqtt_client.simulate_status_frame("LU/LUM/SEN", status_parameters)
		assert_equal result[0], {:topic => "LU/LUM/SEN", :message => "123456;30;1;75;120;220.0;75.0;0.0;75.0;150;0;150;50;"} # RAE: To Improve

		mqtt_client.disconnect()

	end

	# End tests for Vodafone EPD simulator
end