ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Ryan Struthers"
    logging on
    shares hello
  }
  
  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }
  
  rule hello_world {
    select when echo hello
    send_directive("hey", {"something": "Hello World"})
  }
  
  /*
  rule hello_monkey{
    select when echo monkey
    pre {
      name = event:attr("name").defaultsTo("Monkey").klog()
    }
    send_directive(hello(name))
  }
  
  */
   rule hello_monkey2{
    select when echo monkey
    pre {
      name = event:attr("name") => event:attr("name") | "Monkey"
    }
    send_directive(hello(name))
  }
  
}
