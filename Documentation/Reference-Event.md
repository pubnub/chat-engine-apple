Event represents an event that may be emitted or subscribed to.

### Subclass  

* [Object](reference-object)  
* [Emitter](reference-emitter)  


### Properties

<a id="channel"/>

[`@property NSString *channel`](#channel)  
See: [PubNub Channels](https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-)  
The [Chat.channel](reference-chat#channel) that this events is registered to.

<a id="chat"/>

[`@property CENChat *chat`](#chat)  
Events are always a property of a [Chat](reference-chat). Responsible for listening to specific events and firing events when they occur.

<br/><a id="event"/>

[`@property NSString *event`](#event)  
The string representation of the event. This is supplied as the first parameter to [Chat.on](reference-chat#on).


### Methods

<a id="off"/>

[`@property CENUser * (^off)(NSString *event, id handler)`](#off)  
Inherited From: [Emitter.off](reference-emitter#off)  
Stop a handler block from listening to an event.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | Reference on same handler block which has been used with `on()`. |  

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(NSDictionary *payload) {
    NSLog(@"Something happened!");
};

event.on(@"event", self.eventHandlingBlock);
// .....
event.off(@"event", self.eventHandlingBlock);
```

<br/><br/><a id="offany"/>

[`@property CENUser * (^offAny)(id handler)`](#offany)  
Inherited from: [Emitter.offAny](reference-emitter#offany)  
Stop a handler block from listen to any events.   

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | Reference on same handler block which has been used with `onAny()`. |  

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(NSString *event, id data) {
    NSLog(@"Something happened!");
};

event.onAny(self.eventHandlingBlock);
// .....
event.offAny(self.eventHandlingBlock);
```


<br/><br/><a id="on"/>

[`@property CENUser * (^on)(NSString *event, id handler)`](#on)  
Inherited From: [Emitter.on](reference-emitter#on)  
Listen for a specific event and fire a handler block when it's emitted. Supports wildcard matching.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run when the event is emitted. If `event` contain wildcard block in addition to event payload pass event name. |  

#### EXAMPLE

```objc
// Get notified of 'event' emitted by passed emitter.
event.on(@"$.error.getState", ^(NSError *error) {
    NSLog(@"'$.error.getState' was fired", event);
});

/** 
 * Get notified of 'event.a' and 'event.b' emitted by passed emitter. 
 * Handler block include additional argument to which handled event 
 * name will be passed. 
 */
event.on(@"event.*", ^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' was fired", event);
});
```


<br/><br/><a id="onany"/>

[`@property CENUser * (^onAny)(NSString *event, id data)`](#onany)  
Inherited From: [Emitter.onAny](reference-emitter#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | The handler block to run when any event is emitted. Block pass name of event and event data. |  

#### EXAMPLE

```objc
event.onAny(^(NSString *event, id data) {
    NSLog(@"All events trigger this.");
});
```


<br/><br/><a id="once"/>

[`@property CENUser * (^once)(NSString *event, id handler)`](#once)  
Inherited From: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run once. If `event` contain wildcard block in addition to payload pass event name. |  

#### EXAMPLE

```objc
event.once(@"event", ^(NSDictionary *payload) {
    NSLog(@"This is only fired once!");
});
```
 

<br/><br/><a id="plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(id plugin)`](#plugin)  
Inherited From: [Object.plugin](reference-object#plugin)  
Tutorials: [Plugins](concepts-plugins)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin ` | id       | The plugin class or identifier. |

<br/><br/><a id="removeall"/>

[`@property CENUser * (^removeAll)(NSString *event)`](#removeall)  
Inherited from: [Emitter.removeAll](reference-emitter#removeall)  
Stop all handler blocks from listening to an event.  

#### PARAMETERS

| Name    | Type     | Description     |
|:-------:|:--------:| --------------- |
| `event` | NSString | The event name. |

#### EXAMPLE

```objc
event.removeAll(@"event");
```


### Events

<a id="event-emitted"/>

[`$.emitted`](#event-emitted)  
Message successfully published.

#### EXAMPLE

```objc
event.on(@"$.emitted", ^(NSDictionary *payload) {
    NSLog(@"Event has been sent at: %@", payload[CENEventData.timetoken]);
});
```

<br/><br/><a id="event-error-emitter"/>

[`$.error.emitter`](#event-error-emitter)  
There was a problem fetching the state of this user.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `error` | NSError | Error instance with error information. |

#### EXAMPLE

```objc
chat.on(@"$.error.emitter", ^(NSError *error) {
    NSLog(@"Event emit did fail: %@", error);
});
```