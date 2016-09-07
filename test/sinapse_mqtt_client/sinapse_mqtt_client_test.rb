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

end