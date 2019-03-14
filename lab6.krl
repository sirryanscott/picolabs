ruleset io.picolabs.manage_sensors {
  meta {
    provides children_picos, get_threshold
    shares children_picos, get_threshold
  }
  
  global {
    sensors = function() {
      ent:picos.defaultsTo({}).klog("GETTING PICOS")
    }
    
    get_threshold = function() {
      ent:threshold.defaultsTo(70)
    }
    
    get_name = function() {
      ent:name
    }
  }
  
  rule create_sensor {
    select when sensor new_sensor
    pre {
      name = event:attr("name").klog("NAME: ")
      hasName = sensors().filter(function(v,k){k==name}).klog("CHECKING FOR DUPLICATES")
    } 
    if hasName.length() == 0 then
    send_directive("creating child pico")
    fired {
      raise wrangler event "child_creation"
        attributes{"name": name, "rids": ["io.picolabs.temperature_store", "io.picolabs.wovyn_base2", "io.picolabs.sensor_profile", "io.picolabs.logging"] };
    }
  }
  
  rule store_new_pico {
    select when wrangler child_initialized
    pre {
      name = event:attr("name").klog("NAME: ")
      eci =  event:attr("eci").klog("HERE!!!!!")
    }
    always {
      ent:picos := sensors().put(name, eci);
      raise sensor event "profile_updated"
        attributes {"eci": eci, "domain": "sensor", "type": "profile_updated", "attrs": { "name": name, "threshold": get_threshold(), "phone": "8018823708" }}
    }
  }
  
  rule delete_pico {
    select when sensor unneeded_sensor
    pre {
      name = event:attr("name").klog("DELETING PICO")
      hasName = sensors().filter(function(v,k){k==name})
    }
    if hasName.length() == 1 then
    send_directive("deleting the pico")
    fired {
      ent:picos := sensors().delete(name);
      sensors().klog();
      raise wrangler event "child_deletion"
       attributes {"name": name};
    }
  }
}
