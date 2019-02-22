ruleset io.picolabs.temperature_store {
  meta {
    provides temperatures, threshold_violations, inrange_temperatures
    shares temperatures, threshold_violations, inrange_temperatures
  }
  
  
  global {
    temperatures = function() {
      ent:temps.defaultsTo([]).klog("ALL TEMP READINGS:")
    }
    threshold_violations = function () {
      ent:violations.defaultsTo([]).klog("ALL VIOLATIONS:")
    }
    inrange_temperatures = function () {
      ent:temps.difference(ent:violations)
    }
  }
  
  
  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      sensor_data = event:attrs
      temperature = sensor_data["temperature"]
      timestamp = sensor_data["timestamp"]
      newEntry = {
        "temperature":temperature,
        "timestamp":timestamp
      }
    }
      if sensor_data then
      send_directive("adding temperature")
      fired {
        ent:temps := temperatures().append([newEntry])
      }
  }
  
  
  
  rule collect_threshold_violations {
    select when wovyn threshold_violation
     pre {
      sensor_data = event:attrs
      temperature = sensor_data["temperature"]
      timestamp = sensor_data["timestamp"]
      newEntry = {
        "temperature":temperature,
        "timestamp":timestamp
      }
    }
      if sensor_data then
      send_directive("adding threshold violation")
      fired {
        ent:violations := threshold_violations().append([newEntry])
      }
  }
  
  
  
  rule clear_temperatures {
    select when sensor reading_reset
    send_directive("Clearing temperatures")
    always {
      clear ent:temps;
      clear ent:violations
    }
  }
}
