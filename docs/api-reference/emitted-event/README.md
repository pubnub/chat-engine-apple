# CENEmittedEvent

Local [CENChatEngine](../chatengine) emitted events representation.

## Properties

<a id="emitter"/>

[`@property id emitter`](#emitter)  
Object which emitted [event](#event) locally. 

<br/><br/><a id="event"/>

[`@property NSString *event`](#event)  
Full name of emitted event.  

<br/><br/><a id="data"/>

[`@property id data`](#data)  
Object which has been sent along with local [event](#event) for handlers consumption.
There is events like `$.connected` which doesn't set this property, so it will be `nil`.  

When handler user to receive remote events 
([custom events](../../advanced-concepts/namespaces#custom-events)), this property will store dictionary
with following keys (each key is _field_ inside of `CENEventData` _typedef struct_) in it:  
* `event` - name of emitted event,
* `chat` - [chat](../chat) on which `event` has been received,
* `sender` - [user](../user) which represent event sender,
* `timetoken` - timetoken representing date when event has been emitted,
* `data` - `NSDictionary` with data emitted by `sender`,
* `eventID` - unique event identifier.

### Example

```objc
self.chat.on(@"$.online.*", ^(CENEmittedEvent *event) {
    // In this case information about user's presence change will be logged out.
    CENUser *user = event.data;
    
    NSLog(@"User '%@' %@'ed", user.uuid, event.event);
});
```