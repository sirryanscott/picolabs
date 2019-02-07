ruleset io.picolabs.wovyn_base {
  meta {
    name "Wovyn Sensor"
    description <<
Pico for Wovyn Sensor labs
>>
    author "Ryan Struthers"
   logging on
    
    use module io.picolabs.lesson_keys
    use module io.picolabs.twilio_v2 alias twilio
        with account_sid = keys:twilio{"account_sid"}
             auth_token =  keys:twilio{"auth_token"}
    
    shares messages
  }
  global {
    temperature_threshold = 75
    to = 8018823708
    from = 13259390035
    message = "Temperature threshold violation notification"
    
    messages = function(To, From, PageSize) {
    twilio:messages(To, From, PageSize)
    }
  }
 
  rule process_heartbeat {
    select when wovyn heartbeat
    pre {
      sensor_data = event:attrs.klog()
      temperature_data = sensor_data{["genericThing", "data", "temperature"]}.klog()
      newTemp = temperature_data[0]{"temperatureF"}.klog()
    }
    if sensor_data.isnull() then
    send_directive("Sensor Data", {"sensor_data": sensor_data})
    fired {
    }
    else {
      raise wovyn event "new_temperature_reading"
        attributes { "temperature": newTemp, "timestamp": time:now() }
    }
  }
  
  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      sensor_data = event:attrs
      temperature = sensor_data["temperature"].klog()
      timestamp = sensor_data["timestamp"].klog()
    }
    if temperature > temperature_threshold then
    send_directive("Threshold Violation", {"temperature": temperature})
    fired {
      raise wovyn event "threshold_violation"
        attributes { "temperature": newTemp, "timestamp": time:now() }
    }
    else {
    }
  }
  
  rule threshold_notification {
    select when wovyn threshold_violation
    twilio:send_sms(to, from, message)
  }

}

