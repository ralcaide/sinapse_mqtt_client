# Sinapse MQTT Client 

This project implements a ruby gem that offers an MQTT Client with the Sinapse API on top of that. 
It is based in https://github.com/njh/ruby-mqtt/ and works as a wrap easing the use of the MQTT implementation of
the Sinapse API

## Installation

This gem it is not available in an public online repository, so it is necessary to install it as a local gem. Following is explained how to do that:

1. Download the code

2. Create the gem as: gem build sinapse_mqtt_client.gemspec  

3. Add this line to your application's Gemfile:

```ruby
gem 'sinapse_mqtt_client', :path => "/path/example/gem" 
```

4. And then execute:

    $ bundle

Or install it yourself as:

    $ gem install -local /path/example/gem/sinapse_mqtt_client-version.gem

## Usage

TODO: Write usage instructions here

### Create a singleton class to be used in a Rails / Sinatra application

```ruby
require 'sinapse_mqtt_client'
require 'singleton'

class SinapseMQTTClientSingleton < SinapseMQTTClientWrapper::SinapseMQTTClient
	include Singleton

	attr_reader :messages_received, :topics_subscribed, 

	def start_historical_variables_of_MQTT_client_singleton
		@messages_received = Array.new  #Array where the received messages are saved
		@topics_subscribed = Array.new
	end

end
```

### Connect / Disconnect using the singleton class

```ruby
mqtt_client = SinapseMQTTClientSingleton.instance
mqtt_client.host = "sinapsemqtt.com"
mqtt_client.port = 1883
mqtt_client.username = "user"
mqtt_client.password = "password"
mqtt_client.installation_id = "TEST_INSTALLATION"
mqtt_client.ssl = false
mqtt_client.keep_alive = 3600

# Connect
mqtt_client.connect()

# Start basic singleton variables
mqtt_client.start_historical_variables_of_MQTT_client_singleton


# Test connection and then disconnect

if mqtt_client.connected?
    mqtt_client.disconnect
end
```



## Contributing

1. Fork it ( https://github.com/[my-github-username]/sinapse_mqtt_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
