
def is_valid_address(address)
	unless /^[0-9a-fA-F]{6}$/.match(address).nil? then
		return true
	else
		return false	
	end
end

def is_valid_attribute(attribute)
	unless /^[0-9a-fA-F]{2}$/.match(attribute).nil? then
		return true
	else
		return false	
	end
end

def is_valid_radio_configuration(address)
	# RAE TODO
	return true
end

def is_valid_ap_id(ap_id)
	# RAE TODO
	return true
end

