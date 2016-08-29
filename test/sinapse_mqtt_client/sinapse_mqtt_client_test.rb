require './test/test_helper'

class FramesTest < Minitest::Test
	$MQTT_broker = "m21.cloudmqtt.com"
	$MQTT_user = "ugjznzkc"
	$MQTT_password = "7UG2yVgH3zzi"
	$normal_port = 10609
	$ssl_port = 20609
	$tsl_ws_port = 30609 # RAE TODO: The connection to this port is not working. Web services?

	$source_address_wrong = "00000100"
	$destination_address_wrong = "00000200"

	def test_sinapse_mqtt_client_exists
		assert SinapseMQTTClient::MQTTClient
	end

	def test_sinapse_mqtt_client_connects_default
		mqtt_client = SinapseMQTTClient::MQTTClient.new
		mqtt_client.connect()
		assert_equal mqtt_client.connected?, true
		mqtt_client.disconnect() 
	end

	def test_sinapse_mqtt_client_connects_ssl
		mqtt_client = SinapseMQTTClient::MQTTClient.new
		mqtt_client.connect($MQTT_broker, $ssl_port, true, $MQTT_user, $MQTT_password)
		assert_equal mqtt_client.connected?, true
		mqtt_client.disconnect()
	end

	def test_sinapse_mqtt_client_disconnects 
		mqtt_client = SinapseMQTTClient::MQTTClient.new
		mqtt_client.connect()
		assert_equal mqtt_client.connected?, true
		mqtt_client.disconnect()
		assert_equal mqtt_client.connected?, false

	end

	def test_send_and_receive_messages
		mqtt_client = SinapseMQTTClient::MQTTClient.new
		mqtt_client.connect()
		mqtt_client.subscribe("/installation1/APID/ACT/Device1")
		#assert_equal mqtt_client.subscribe("/installation1/APID/ACT/Device2"), 31 


		# This part of the test is not working well. Maybe it is due the creation of a new Thread in order to receive the messages
		mqtt_client.receive_messages_from_subscribed_topics do |topic, message|
			assert_equal message, "test_message"
			assert_not_equal topic, "/installation1/APID/ACT/Device3"
		end

		mqtt_client.publish("/installation1/APID/ACT/Device1", "test_message")
		mqtt_client.publish("/installation1/APID/ACT/Device2", "test_message")
		mqtt_client.publish("/installation1/APID/ACT/Device3", "test_message") # This message is not got in the subscription


	end

end