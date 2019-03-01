# CENEventStatusPlugin

In many chat applications today, when a user sends a message, they expects to know if it was sent, 
delivered, and read by the recipient. With the ChatEngine Event Status plugin, you can fire a 
notification for each state of the message - sent, delivered and read.  


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/EventStatus'
   ```
2. Added dependency installation:
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:
   ```objc
   #import <CENChatEngine/CENEventStatusPlugin.h>
   ```

### Example

Setup with default configuration:

```objc
// Register plugin for every created chat.
self.client.proto(@"Chat", [CENEventStatusPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENEventStatusPlugin class]).store();
});
```

Setup with custom events:
```objc
NSDictionary *configuration = @{
    CENEventStatusConfiguration.events: @[@"ping", @"pong", @"message"]
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENEventStatusPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENEventStatusPlugin class])
        .configuration(configuration).store();
});
```

### Parameters:

| Name      | Type                  | Default         | Description |
|:---------:|:---------------------:|:---------------:| ----------- |
| `events`  | NSArray<NSString *> * | `@[@"message"]` | List of event names for which plugin should be used. |

Each parameter is _field_ inside of `CENEventStatusConfiguration` _typedef struct_.

<a id="eventstatusdata">

`CENEventStatusData` _typedef struct_ contains keys which can be used to access event status 
information:  
* `CENEventStatusData.data` - event status information under `CENEventData.data` root key. 
* `CENEventStatusData.identifier` - unique identifier of event for which delivery read receipt has 
   been processed. 


## Methods

<a id="readevent">

[`+ (void)readEvent:(NSDictionary *)event inChat:(CENChat *)chat`](#readevent)  
Mark particular event as `read` and notify other [chat](../../api-reference/chat) participants.  

### Parameters:

| Name    | Type                        | Attributes | Description |
|:-------:|:---------------------------:|:----------:| ----------- |  
| `event` | NSDictionary *              |  Required  | `NSDictionary` with event data which has been received from [chat](../../api-reference/chat). |
| `chat`  | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) to which `read` acknowledgment should be sent. |

### Example

```objc
self.chat.on(@"message", ^(CENEmittedEvent *event) {
    [CENEventStatusPlugin readEvent:event.data inChat:self.chat];
});
```


## Events

<a id="event-eventstatus-created"/>

[`$.eventStatus.created`](#event-eventstatus-created)  
Notify locally what new event created.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.eventStatus.created`     | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`            | Payload with event information, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.chat.on(@"$.eventStatus.created", ^(CENEmittedEvent *event) {
    NSDictionary *eventData = ((NSDictionary *)event.data)[CENEventData.data];
    NSString *eventID = eventData[CENEventStatusData.identifier];

    // Chat is about to send new event with 'eventID'.
});
```


<br/><br/><a id="event-eventstatus-sent"/>

[`$.eventStatus.sent`](#event-eventstatus-sent)  
Notify locally what event has been sent.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.eventStatus.sent`        | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`            | Payload with event information, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.chat.on(@"$.eventStatus.sent", ^(CENEmittedEvent *event) {
    NSDictionary *eventData = ((NSDictionary *)event.data)[CENEventData.data];
    NSString *eventID = eventData[CENEventStatusData.identifier];

    // Event with 'eventID' has been sent.
});
```


<br/><br/><a id="event-eventstatus-delivered"/>

[`$.eventStatus.delivered`](#event-eventstatus-delivered)  
Notify locally what event has been delivered.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.eventStatus.delivered`   | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`            | Payload with event information, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.chat.on(@"$.eventStatus.delivered", ^(CENEmittedEvent *event) {
    NSDictionary *eventData = ((NSDictionary *)event.data)[CENEventData.data];
    NSString *eventID = eventData[CENEventStatusData.identifier];
    
    // Event with 'eventID' has been delivered.
});
```


<br/><br/><a id="event-eventstatus-read"/>

[`$.eventStatus.read`](#event-eventstatus-read)  
Notify locally what event seen by another user.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.eventStatus.read`        | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`            | Payload with event information, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.chat.on(@"$.eventStatus.read", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    CENUser *sender = payload[CENEventData.sender];
    NSDictionary *eventData = payload[CENEventData.data];
    NSString *eventID = eventData[CENEventStatusData.identifier];

    // 'eventID' event has been read by 'sender'.
});
```


## How to Mark the Message as Sent

As soon as a new message is sent, it will be triggered the event: 
[$.eventStatus.sent](#event-eventstatus-sent) which contains the tracking id.

```objc
// Property which will store list of received messages.
self.messages = [NSMutableArray new];
/** 
 * Property which will store list of sent message identifiers.
 * Those messages, who's event status tracking id is not in this list treated as 'sent'.
 */
self.sending = [NSMutableArray new];

self.chat.on(@"$.eventStatus.sent", ^(CENEmittedEvent *event) {
    NSString *eventID = event.data[CENEventData.data][CENEventStatusData.identifier];

    [self.sending addObject:eventID];
});

self.chat.on(@"message", ^(CENEmittedEvent *event) {
    NSString *eventID = event.data[CENEventStatusData.data][CENEventStatusData.identifier];
    
    [self.sending removeObject:eventID];
    [self.messages addObject:event.data];
});
```

## How to identify and Mark a Message as Delivery

When a message is delivered successfully, it will be triggered the event: 
[$.eventStatus.delivered](#event-eventstatus-delivered) which contains the tracking id into the data
field and also the sender field in which you can know who received the message.

```objc
// Property which will store list of received messages.
self.messages = [NSMutableArray new];
/** 
 * Property which will store list of delivered message identifiers.
 */
self.delivered = [NSMutableArray new];

self.chat.on(@"$.eventStatus.delivered", ^(CENEmittedEvent *event) {
    NSDictionary *eventData = ((NSDictionary *)event.data)[CENEventData.data];
    NSString *eventID = eventData[CENEventStatusData.identifier];

    [self.delivered addObject:eventID];
});
```

## How to Mark a Message as Read

Using [helper](#readevent) method plugin allow to mark particular event as `seen`. Passing the 
payload received through this function, you can notify to the sender that the message was already 
read.

In this point you can use different strategies to mark the message as read e.g. using the scroll 
down or when the list is focused.

```objc
self.chat.on(@"message", ^(CENEmittedEvent *event) {
    [CENEventStatusPlugin readEvent:event.data inChat:self.chat];
});
```

## How to know which Ones and Who have Read the Messages

When a message is marked as read, you will receive a notification through the event 
[$.eventStatus.read](#event-eventstatus-read) with which you can display into your UI that message 
was read, in addition every payload contains the sender data and with this you can know who read the
message.

```objc
// Property which will store list of received messages.
self.messages = [NSMutableArray new];
/** 
 * Property which will store list of 'seen' message identifiers.
 */
self.seen = [NSMutableArray new];

self.chat.on(@"$.eventStatus.read", ^(CENEmittedEvent *event) {
    NSDictionary *eventData = ((NSDictionary *)event.data)[CENEventData.data];
    NSString *eventID = eventData[CENEventStatusData.identifier];

    [self.seen addObject:eventID];
});
```