require_relative "helpers"
require "mqtt"

#
# Class that implements a simulation of the Sinapse EPDs talking the Vodafone API
#
class SinapseEPDSimulatorVodafone < SinapseMQTTClientWrapper::SinapseMQTTClient

	# Method that sends a status frame through the provided topic. The values of the Status frame are provided through the params hash or are simulated if the params hash is empty
	# params 
	def simulate_status_frame(topic = "LU/LUM/SEN", params = nil, nominal_power = 60, id = "FFFFFF")

		messages_published = []

		if params.nil?
			params = simulate_status_params(nominal_power, id)
		end

		# TODO RAE: Check params are well formed

		message = params[:id_radio].to_s + ";" + params[:temp].to_i.to_s + ";" + params[:stat].to_s + ";" + params[:dstat].to_s + ";" + params[:current].to_i.to_s +
			";" + params[:voltage].to_f.round(1).to_s + ";" + params[:active_power].to_f.round(1).to_s + ";" + params[:reactive_power].to_f.round(1).to_s + ";" + params[:apparent_power].to_f.round(1).to_s + 
			";" + params[:aggregated_active_energy].to_i.to_s + ";" + params[:aggregated_reactive_energy].to_i.to_s + ";" + params[:aggregated_apparent_energy].to_i.to_s + ";" + params[:frequency].to_i.to_s	

		publish(topic, message)
		
		messages_published.push({:topic => topic, :message => message})

		return messages_published
	end

private
	
	# Simulate status parameters for the device with ID
	def simulate_status_params(nominal_power = 60, id= "FFFFFF")
		id_radio = id
		temp = 30 + rand(-6..6)
		stat = rand(0..1)
		stat == 1 ? dstat = rand(10..90) : dstat = 0
		voltage = 220 + rand(-10..10) # Voltage in Volts

		# current (mA) = P/V * (dstat / 100) * 1000
		current = (voltage.to_f / nominal_power.to_f) * (dstat.to_f / 100.0) * 1000 # Current in mA
		active_power = (voltage * current.to_i) / 1000 # Power in Watts
		reactive_power = 0
		apparent_power = active_power * rand(0.9..1)
		aggregated_active_energy = active_power * rand(2..100)
		aggregated_reactive_energy = 0
		aggregated_apparent_energy = aggregated_active_energy * rand(0.9..1)
		frequency = 50 + rand(-2.0..2.0)

		status_parameters = {
			id_radio: id_radio,
			temp: temp,
			stat: stat,
			dstat: dstat,
			voltage: voltage,
			current: current,
			active_power: active_power,
			reactive_power: reactive_power,
			apparent_power: apparent_power,
			aggregated_active_energy: aggregated_active_energy,
			aggregated_reactive_energy: aggregated_reactive_energy,
			aggregated_apparent_energy: aggregated_apparent_energy,
			frequency: frequency
		}

		return status_parameters 

	end 

end