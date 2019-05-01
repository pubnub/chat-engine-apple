# CENTypingIndicatorPlugin

Typing indicators show that the user is typing with visual cues such as blinking dots or an explicit notification such as `typing…`. The ChatEngine Typing Indicator plugin emits events when a user starts and stops typing.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/TypingIndicator'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENTypingIndicatorPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for every created chat.
self.client.proto(@"Chat", [CENTypingIndicatorPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENTypingIndicatorPlugin class]).store();
});
```

Setup with custom timeout value:
```objc
NSDictionary *configuration = @{
    CENTypingIndicatorConfiguration.timeout: @(5.f)
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENTypingIndicatorPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENTypingIndicatorPlugin class])
        .configuration(configuration).store();
});
```


### Parameters:

| Name      | Type                  | Default         | Description |
|:---------:|:---------------------:|:---------------:| ----------- |
| `events`  | NSArray<NSString *> * | `@[@"message"]` | List of event names for which plugin should be used. |
| `timeout` | NSNumber *            | `1.f`           | Typing event timeout. |

Each parameter is _field_ inside of `CENTypingIndicatorConfiguration` _typedef struct_.


## Methods

<a id="set-typing">

[`+ (void)setTyping:(BOOL)isTyping inChat:(CENChat *)chat`](#set-typing)  
Update typing indicator state.

### Parameters:

| Name       | Type                        | Attributes | Description |
|:----------:|:---------------------------:|:----------:| ----------- |  
| `isTyping` | BOOL                        |  Required  | Whether user typing at this moment or not. |
| `chat`     | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) for which typing indicator should be changed. |

### Example

```objc
// Emit the typing event.
[CENTypingIndicatorPlugin setTyping:YES inChat:self.chat];

/**
 * Manually emit the stop tying event this is automatically emitted after the timeout period,
 * or when a message is sent.
 */
[CENTypingIndicatorPlugin setTyping:NO inChat:self.chat];
```


<br/><br/><a id="is-typing">

[`+ (BOOL)isTypingInChat:(CENChat *)chat`](#is-typing)  
Check whether typing indicator currently `ON` in [chat](../../api-reference/chat) or not.

### Parameters:

| Name   | Type                        | Attributes | Description |
|:------:|:---------------------------:|:----------:| ----------- |  
| `chat` | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) for which check should be done. |

### Returns:

Whether typing indicator currently on in specified [chat](../../api-reference/chat) or off.

### Example

```objc
BOOL isTyping = [CENTypingIndicatorPlugin isTypingInChat:self.chat];
```


## Events

<a id="event-typingindicator-start-typing"/>

[`$typingIndicator.startTyping`](#event-typingindicator-start-typing)  
Notify locally when typing did start.

### Properties:

| Name      | Type       |  Value                         | Description |
|:---------:|:----------:|:------------------------------:| ----------- |
| `event`   | NSString * | `$typingIndicator.startTyping` | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) *    | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`               | `$typingIndicator.startTyping` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.chat.on(@"$typingIndicator.startTyping", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    CENUser *user = payload[CENEventData.sender];

    NSLog(@"'%@' start typing in '%@'", user.uuid, self.client.global.name);
});
```


<br/><br/><a id="event-typingindicator-stop-typing"/>

[`$typingIndicator.stopTyping`](#event-typingindicator-stop-typing)  
Notify locally when typing did stop.

### Properties:

| Name      | Type       |  Value                        | Description |
|:---------:|:----------:|:-----------------------------:| ----------- |
| `event`   | NSString * | `$typingIndicator.stopTyping` | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) *   | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | `NSDictionary *`              | `$typingIndicator.stopTyping` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.chat.on(@"$typingIndicator.stopTyping", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    CENUser *user = payload[CENEventData.sender];

    NSLog(@"'%@' did stop typing in '%@'", user.uuid, self.client.global.name);
});
```