ruleset io.picolabs.wovyn_base {
  meta {
    name "Wovyn Sensor"
    description <<
Pico for Wovyn Sensor labs
>>
    author "Ryan Struthers"
   logging on
  }
  global {
    
  }
 
  rule process_heartbeat {
    select when wovyn heartbeat
    pre {
      sensor_data = event:attrs
      temp = sensor_data["generic_thing"]["temperature"]
    }
    if sensor_data.isnull() then
    send_directive("Sensor Data", {"sensor_data": sensor_data})
    fired {
    }
    else {
      raise wovyn event "new_temperature_reading".klog()
        attributes { "temperature": nameFromID(temp), "timestamp": time.now() }
    }
  }
  
  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      sensor_data = even:attrs
      temperature = sensor_data["temperature"]
      timestamp = sensor_data["timestamp"].klog()
    }
    
  }

}

