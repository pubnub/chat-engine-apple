When developing with ChatEngine, errors will occasionally be reported to let you know when things go
wrong.  
By default, errors are both emitted as `$.error` events from the object that is responsible and 
bubbled via `raise`.  

## Thrown Errors

You'll notice thrown errors because they usually break application execution and log a stack trace 
within the console.

## Errors as Events

You can also subscribe to errors via the `$.error` event. If you'd like to subscribe to all 
ChatEngine errors, try the following:  

```objc
self.client.on('$.error.*', ^(CENEmittedEvent *event) {
    NSLog(@"'%@' error: %@", event.event, error.data);
});
```  

## Errors in Production

In a production app, it is not a good idea to throw errors. If you'd like to suppress errors, 
provide `NO` to [CENConfiguration.throwErrors](../../api-reference/configuration#throwexceptions).  

## Example Errors

These are the errors thrown when a client tries to access a [chat](../../api-reference/chat) you 
don't have PAM access to (see privacy):  
```objc
CENChat *privChat = self.client.Chat().name(@"locked-down-i-dont-have-permissions").create();
```  

Private chat emits these events:  

* [$.error.auth](../../api-reference/chat#event-error-auth)
* [$.error.presence](../../api-reference/chat#event-error-presence)  

ChatEngine emits this event:  

* [$.network.down.denied](../../api-reference/chatengine#event-network-down-denied)