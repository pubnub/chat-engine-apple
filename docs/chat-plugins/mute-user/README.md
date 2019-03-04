# CENMuterPlugin

Chat moderation sometimes requires _muting_ or _banning_ users. The ChatEngine muter adds the 
ability to **mute** a user in an object.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/Muter'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENMuterPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for every created chat.
self.chat.plugin([CENMuterPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENMuterPlugin class]).store();
});
```

Setup with custom events which won't be received from muted user:
```objc
NSDictionary *configuration = @{
    CENMuterConfiguration.events: @[@"ping", @"pong"]
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENMuterPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when ChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENMuterPlugin class])
        .configuration(configuration).store();
});
```


### Parameters:

| Name     | Type                  | Default         | Description |
|:--------:|:---------------------:|:---------------:| ----------- |
| `events` | NSArray<NSString *> * | `@[@"message"]` | List of event names for which plugin should be used. |

Each parameter is _field_ inside of `CENMuterConfiguration` _typedef struct_.


## Methods

<a id="mute">

[`+ (void)muteUser:(CENUser *)user inChat:(CENChat *)chat`](#mute)  
Mute specific [user](../../api-reference/user) in [chat](../../api-reference/chat).

### Parameters:

| Name   | Type                        | Attributes | Description |
|:------:|:---------------------------:|:----------:| ----------- |  
| `user` | [CENUser](../../api-reference/user) * |  Required  | [User](../../api-reference/user) from which [CENChatEngine](../../api-reference/chatengine) client should stop receiving messages in specified [chat](../../api-reference/chat). |
| `chat` | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) in which [user](../../api-reference/user) should be silenced. |

### Example

```objc
[CENMuterPlugin muteUser:self.user inChat:self.chat];
```


<br/><br/><a id="unmute">

[`+ (void)unmuteUser:(CENUser *)user inChat:(CENChat *)chat`](#unmute)  
Unmute specific [User](../../api-reference/user) in [Chat](../../api-reference/chat).

### Parameters:

| Name   | Type                        | Attributes | Description |
|:------:|:---------------------------:|:----------:| ----------- |  
| `user` | [CENUser](../../api-reference/user) * |  Required  | [User](../../api-reference/user) from which [CENChatEngine](../../api-reference/chatengine) client should start receiving messages in specified [chat](../../api-reference/chat). |
| `chat` | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) in which [user](../../api-reference/user) should be able to send messages. |

### Example

```objc
[CENMuterPlugin unmuteUser:self.user inChat:self.chat];
```


<br/><br/><a id="is-muted">
 
[`+ (BOOL)isMutedUser:(CENUser *)user inChat:(CENChat *)chat`](#is-muted) 
Check whether specified [user](../../api-reference/user) still muted in specific [chat](../../api-reference/chat) or not.

### Parameters:

| Name   | Type                        | Attributes | Description |
|:------:|:---------------------------:|:----------:| ----------- |  
| `user` | [CENUser](../../api-reference/user) * |  Required  | [User](../../api-reference/user) for which should be checked ability to send messages to specified [chat](../../api-reference/chat). |
| `chat` | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) inside of which check should be done. |

### Returns:

Whether specified [user](../../api-reference/user) is muted in [chat](../../api-reference/chat) or not.

### Example

```objc
BOOL isMuted = [CENMuterPlugin isMutedUser:self.user inChat:self.chat];

NSLog(@"'%@' still muted? %@", self.user.uuid, isMuted ? @"YES" : @"NO");
```


## Events

<a id="event-muter-rejected"/>

[`$muter.eventRejected`](#event-muter-rejected)
Notify locally when muted user message has been rejected.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.eventStatus.read`        | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`            | Payload with event, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.chat.on(@"$muter.eventRejected", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    CENUser *mutedUser = payload[CENEventData.sender];

    NSLog(@"Muted '%@' sent something: %@", mutedUser.uuid, payload[CENEventData.data]);
});
```