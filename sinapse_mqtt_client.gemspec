# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinapse_mqtt_client/version'

Gem::Specification.new do |spec|
  spec.name          = "sinapse_mqtt_client"
  spec.version       = SinapseMQTTClient::VERSION
  spec.authors       = ["ralcaide"]
  spec.email         = ["rafa.alcaide@sinapseenergia.com"]
  spec.summary       = %q{Implements a MQTT Client offering the Sinapse API. The MQTT Client is based on the ruby-mqtt gem}
  spec.description   = %q{Implements a MQTT Client offering the Sinapse API. The MQTT Client is based on the ruby-mqtt gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  #Testing tools
  spec.add_development_dependency "minitest"
  #spec.add_development_dependency "vcr" # Gem to perform HTTP tests. It is not necessary at this moment
  #spec.add_development_dependency "webmock" # This gem simulates a web server. It is not necessary at this moment

  #Hard dependencies
  #spec.add_dependency "faraday" # This gem works as http client. It is not necessary at this moment
  spec.add_dependency "json"
  spec.add_dependency "mqtt"

end
