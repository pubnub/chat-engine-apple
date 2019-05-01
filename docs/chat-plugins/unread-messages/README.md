# CENUnreadMessagesPlugin

The Unread Message Counts Plugin allows you to count the number of unread messages.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/UnreadMessages'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENUnreadMessagesPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for every created chat.
self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENUnreadMessagesPlugin class]).store();
});
```

Setup with custom events list:
```objc
NSDictionary *configuration = @{
    CENUnreadMessagesConfiguration.events: @[@"ping", @"pong"]
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENUnreadMessagesPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENUnreadMessagesPlugin class])
        .configuration(configuration).store();
});
```


### Parameters:

| Name     | Type                  | Default         | Description |
|:--------:|:---------------------:|:---------------:| ----------- |
| `events` | NSArray<NSString *> * | `@[@"message"]` | List of event names for which plugin should be used. |

Each parameter is _field_ inside of `CENUnreadMessagesConfiguration` _typedef struct_.

<a id="eventstatusdata">

`CENUnreadMessagesEvent` _typedef struct_ contains only two keys which allow check `$unread` event 
information:  
* `CENUnreadMessagesEvent.event` - dictionary with original [CENChatEngine](../../api-reference/chatengine) 
   messages / events which has been received while [chat](../../api-reference/chat) was `inactive`. 
* `CENUnreadMessagesEvent.count` - number of unread messages / events. 


## Methods

<a id="set-chat-state">

[`+ (void)setChat:(CENChat *)chat active:(BOOL)isActive`](#set-chat-state)  
Update [chat's](../../api-reference/chat) activity.

### Parameters:

| Name       | Type                        | Attributes | Description |
|:----------:|:---------------------------:|:----------:| ----------- |  
| `chat`     | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) for which activity should be changed. |
| `isActive` | BOOL                        |  Required  | Whether [chat](../../api-reference/chat) active at this moment or not. |

### Example

```objc
// Focused on the chat room.
[CENUnreadMessagesPlugin setChat:self.chat active:YES];

// Looking at any other chat room.
[CENUnreadMessagesPlugin setChat:self.chat active:NO];
```


<br/><br/><a id="is-active">
 
[`+ (BOOL)isChatActive:(CENChat *)chat`](#is-active) 
Check whether [chat](../../api-reference/chat) marked as active or not.

### Parameters:

| Name    | Type                        | Attributes | Description |
|:-------:|:---------------------------:|:----------:| ----------- |  
| `chat`  | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) for which activity should be checked. |

### Returns:

Whether [chat](../../api-reference/chat) active at this moment or not.

### Example

```objc
// Focused on the chat room.
[CENUnreadMessagesPlugin setChat:self.chat active:YES];

BOOL isActive = [CENUnreadMessagesPlugin isChatActive:self.chat];
```


<br/><br/><a id="unread-count">

[`+ (NSUInteger)unreadCountForChat:(CENChat *)chat`](#unread-count)  
Get current unread messages count for [chat](../../api-reference/chat).

### Parameters:

| Name    | Type                        | Attributes | Description |
|:-------:|:---------------------------:|:----------:| ----------- |  
| `chat`  | [CENChat](../../api-reference/chat) * | Required | [Chat](../../api-reference/chat) for which count should be fetched. |

### Returns:

Number of unread events count.

### Example

```objc
NSUInteger unreadCount = [CENUnreadMessagesPlugin unreadCountForChat:self.chat];
```


## Events

<a id="event-unread"/>

[`$unread`](#event-unread)  
Notify locally when new unread event for chat has been received.

### Properties:

| Name      | Type       |  Value                        | Description |
|:---------:|:----------:|:-----------------------------:| ----------- |
| `event`   | NSString * | `$typingIndicator.stopTyping` | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) *   | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`              | Payload with [event](#eventstatusdata), which has been emitted by plugin for inactive [chat](../../api-reference/chat). |

### Example

```objc
self.chat.on(@"$unread", ^(CENEmittedEvent *event) {
    NSDictionary *pluginPayload = event.data;
    NSDictionary *eventPayload = pluginPayload[CENUnreadMessagesEvent.event];
    CENUser *sender = eventPayload[CENEventData.sender];
    
    NSLog(@"%@ sent a message you haven't seen (there is %@ unread messages) in %@ the full "
          "event is: %@", sender.uuid, pluginPayload[CENUnreadMessagesEvent.count],
          self.chat.name, eventPayload);
});
```