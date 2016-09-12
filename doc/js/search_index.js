var search_data = {"index":{"searchIndex":["framestest","object","sinapsemqttclient","sinapsemqttclientsingleton","sinapsemqttclientwrapper","sinapsemqttclient","ask_measurement_ap()","ask_measurement_epd()","change_relay_status_ap()","connect()","is_valid_address()","is_valid_ap_id()","is_valid_attribute()","is_valid_radio_configuration()","on_demand_act_epd()","receive_messages_from_subscribed_topics()","test_ask_measurement_ap()","test_ask_measurement_ap_fails()","test_ask_measurement_epd()","test_ask_measurement_epd_fails()","test_change_relay_status_ap()","test_on_demand_act_epd()","test_on_demand_act_epd_fails()","test_send_and_receive_messages()","test_sinapse_mqtt_client_connect_fails()","test_sinapse_mqtt_client_connects_default()","test_sinapse_mqtt_client_connects_ssl()","test_sinapse_mqtt_client_disconnects()","test_sinapse_mqtt_client_exists()","test_subscribe_to_empty_topics()","gemfile","license","readme","rakefile","sinapse_mqtt_client.gemspec"],"longSearchIndex":["framestest","object","sinapsemqttclient","sinapsemqttclientsingleton","sinapsemqttclientwrapper","sinapsemqttclientwrapper::sinapsemqttclient","sinapsemqttclientwrapper::sinapsemqttclient#ask_measurement_ap()","sinapsemqttclientwrapper::sinapsemqttclient#ask_measurement_epd()","sinapsemqttclientwrapper::sinapsemqttclient#change_relay_status_ap()","sinapsemqttclientwrapper::sinapsemqttclient#connect()","object#is_valid_address()","object#is_valid_ap_id()","object#is_valid_attribute()","object#is_valid_radio_configuration()","sinapsemqttclientwrapper::sinapsemqttclient#on_demand_act_epd()","sinapsemqttclientwrapper::sinapsemqttclient#receive_messages_from_subscribed_topics()","framestest#test_ask_measurement_ap()","framestest#test_ask_measurement_ap_fails()","framestest#test_ask_measurement_epd()","framestest#test_ask_measurement_epd_fails()","framestest#test_change_relay_status_ap()","framestest#test_on_demand_act_epd()","framestest#test_on_demand_act_epd_fails()","framestest#test_send_and_receive_messages()","framestest#test_sinapse_mqtt_client_connect_fails()","framestest#test_sinapse_mqtt_client_connects_default()","framestest#test_sinapse_mqtt_client_connects_ssl()","framestest#test_sinapse_mqtt_client_disconnects()","framestest#test_sinapse_mqtt_client_exists()","framestest#test_subscribe_to_empty_topics()","","","","",""],"info":[["FramesTest","","FramesTest.html","",""],["Object","","Object.html","",""],["SinapseMQTTClient","","SinapseMQTTClient.html","",""],["SinapseMQTTClientSingleton","","SinapseMQTTClientSingleton.html","",""],["SinapseMQTTClientWrapper","","SinapseMQTTClientWrapper.html","","<p>require_relative “napse_frames/extended_frames” require_relative\n“napse_frames/evo_frames” …\n"],["SinapseMQTTClientWrapper::SinapseMQTTClient","","SinapseMQTTClientWrapper/SinapseMQTTClient.html","","<p>SinapseMQTTClient\n<p>Class that implements the management of a MQTT Client offering the Sinapse\nAPI  This …\n"],["ask_measurement_ap","SinapseMQTTClientWrapper::SinapseMQTTClient","SinapseMQTTClientWrapper/SinapseMQTTClient.html#method-i-ask_measurement_ap","(ap_id_list)","<p>Function ask_measurement_ap - API: 9. Pull measurement Input arguments:\nap_id_list:  List of AP devices. …\n"],["ask_measurement_epd","SinapseMQTTClientWrapper::SinapseMQTTClient","SinapseMQTTClientWrapper/SinapseMQTTClient.html#method-i-ask_measurement_epd","(epd_id_list, ap_id=\"APID\")","<p>Function ask_measurement_epd - API: 1. Pull measurement Input arguments:\nepd_id_list: List of epd devices. …\n"],["change_relay_status_ap","SinapseMQTTClientWrapper::SinapseMQTTClient","SinapseMQTTClientWrapper/SinapseMQTTClient.html#method-i-change_relay_status_ap","(ap_id_list, relay_status_list)","<p>Funtion change_relay_status_ap - API: 10. Status Change (Acy over relays)\nInput arguments: ap_id_list …\n"],["connect","SinapseMQTTClientWrapper::SinapseMQTTClient","SinapseMQTTClientWrapper/SinapseMQTTClient.html#method-i-connect","()","<p>Connect Overrides the connect method of MQTT::Client because the parent\nmethod leaves  a connected = …\n"],["is_valid_address","Object","Object.html#method-i-is_valid_address","(address)",""],["is_valid_ap_id","Object","Object.html#method-i-is_valid_ap_id","(ap_id)",""],["is_valid_attribute","Object","Object.html#method-i-is_valid_attribute","(attribute)",""],["is_valid_radio_configuration","Object","Object.html#method-i-is_valid_radio_configuration","(address)",""],["on_demand_act_epd","SinapseMQTTClientWrapper::SinapseMQTTClient","SinapseMQTTClientWrapper/SinapseMQTTClient.html#method-i-on_demand_act_epd","(epd_id_list, dimming, ap_id=\"APID\")","<p>Function on_demand_act_epd - API: 3. OnDemand Actuation (Lighting Status)\nInput arguments: epd_id_list …\n"],["receive_messages_from_subscribed_topics","SinapseMQTTClientWrapper::SinapseMQTTClient","SinapseMQTTClientWrapper/SinapseMQTTClient.html#method-i-receive_messages_from_subscribed_topics","()","<p>Function to receive message from the subscribed topics. It runs as a\nforever / infinite loop if it is …\n"],["test_ask_measurement_ap","FramesTest","FramesTest.html#method-i-test_ask_measurement_ap","()",""],["test_ask_measurement_ap_fails","FramesTest","FramesTest.html#method-i-test_ask_measurement_ap_fails","()",""],["test_ask_measurement_epd","FramesTest","FramesTest.html#method-i-test_ask_measurement_epd","()",""],["test_ask_measurement_epd_fails","FramesTest","FramesTest.html#method-i-test_ask_measurement_epd_fails","()",""],["test_change_relay_status_ap","FramesTest","FramesTest.html#method-i-test_change_relay_status_ap","()",""],["test_on_demand_act_epd","FramesTest","FramesTest.html#method-i-test_on_demand_act_epd","()",""],["test_on_demand_act_epd_fails","FramesTest","FramesTest.html#method-i-test_on_demand_act_epd_fails","()",""],["test_send_and_receive_messages","FramesTest","FramesTest.html#method-i-test_send_and_receive_messages","()",""],["test_sinapse_mqtt_client_connect_fails","FramesTest","FramesTest.html#method-i-test_sinapse_mqtt_client_connect_fails","()",""],["test_sinapse_mqtt_client_connects_default","FramesTest","FramesTest.html#method-i-test_sinapse_mqtt_client_connects_default","()",""],["test_sinapse_mqtt_client_connects_ssl","FramesTest","FramesTest.html#method-i-test_sinapse_mqtt_client_connects_ssl","()",""],["test_sinapse_mqtt_client_disconnects","FramesTest","FramesTest.html#method-i-test_sinapse_mqtt_client_disconnects","()",""],["test_sinapse_mqtt_client_exists","FramesTest","FramesTest.html#method-i-test_sinapse_mqtt_client_exists","()",""],["test_subscribe_to_empty_topics","FramesTest","FramesTest.html#method-i-test_subscribe_to_empty_topics","()",""],["Gemfile","","Gemfile.html","","<p>source &#39;rubygems.org&#39;\n<p># Specify your gem&#39;s dependencies in sinapse_mqtt_client.gemspec\ngemspec …\n"],["LICENSE","","LICENSE_txt.html","","<p>Copyright © 2016 ralcaide\n<p>MIT License\n<p>Permission is hereby granted, free of charge, to any person obtaining …\n"],["README","","README_md.html","","<p>Sinapse MQTT Client\n<p>This project implements a ruby gem that offers an MQTT Client with the\nSinapse API …\n"],["Rakefile","","Rakefile.html","","<p>require “bundler/gem_tasks”\n"],["sinapse_mqtt_client.gemspec","","sinapse_mqtt_client_gemspec.html","","<p>lib = File.expand_path(&#39;../lib&#39;, __FILE__) $LOAD_PATH.unshift(lib)\nunless $LOAD_PATH.include?(lib) …\n"]]}}