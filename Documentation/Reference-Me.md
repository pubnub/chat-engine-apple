# CENMe

Represent the client connection as a special [User](reference-user) with write permissions. Has the ability to update it's state on the network.

### Subclass  

* [User](reference-user)  
* [Object](reference-object)  
* [Emitter](reference-emitter)  

### Properties

<a id="direct"/>

[`@property CENChat *direct`](#direct)  
See: [Chat](reference-chat)  
Inherited From: [User.direct](reference-user#direct)  
Direct is a private channel that anybody can publish to but only the user can subscribe to. Great for pushing notifications or inviting to other chats. Users will not be able to communicate with one another inside of this chat. Check out the [Chat.invite](reference-chat#invite) method for private chats utilizing [User.direct](reference-user#direct).   

#### EXAMPLE

```objc
// Me
self.client.me.direct.on(@"private-message", ^(NSDictionary *payload) {
    CENUser *sender = payload[CENEventData.sender];

    NSLog(@"'%@' sent you a direct message", sender.uuid);
});

// Another user.
them.direct.emit(@"private-message").data(@{ @"secret": @42 }).perform();
```


<br/><br/><a id="feed"/>

[`@property CENChat *feed`](#feed)  
See: [Chat](reference-chat)  
Inherited From: [User.feed](reference-user#feed)  
Feed is a Chat that only streams things a User does, like 'startTyping' or 'idle' events for example. Anybody can subscribe to a User's feed, but only the User can publish to it. Users will not be able to converse in this channel.

#### EXAMPLE

```objc
// Me
self.client.me.feed.emit(@"update").data(@{ @"msg": @"I may be away from my computer right now" }).perform();

// Another user.
them.feed.on(@"update", ^(NSDictionary *payload) {
});
```

<br/><br/><a id="session"/>

[`@property CENSession *session`](#session)  
User's synchronization [session](reference-session) used to track changes in list of active chats across local user devices (which currently online).  

#### EXAMPLE

```objc
self.client.me.session.on(@"$.chat.join", ^(CENChat *chat) {
    NSLog(@"I joined '%@' from another device.", chat.name);
});
```

<br/><br/><a id="state"/>

[`@property NSDictionary *state`](#state)  
Inherited From: [User.state](reference-user#state)  
Gets the user state. See [Me.update](reference-me#update) for how to assign state values.

#### EXAMPLE

```objc
NSLog(@"User's state: %@", self.client.me.state);
```


### Methods

<a id="off"/>

[`@property CENMe * (^off)(NSString *event, id handler)`](#off)  
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

self.client.me.on(@"$.error.getState", self.eventHandlingBlock);
// .....
self.client.me.off(@"$.error.getState", self.eventHandlingBlock);
```

<br/><br/><a id="offany"/>

[`@property CENMe * (^offAny)(id handler)`](#offany)  
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

self.client.me.onAny(self.eventHandlingBlock);
// .....
self.client.me.offAny(self.eventHandlingBlock);
```


<br/><br/><a id="on"/>

[`@property CENMe * (^on)(NSString *event, id handler)`](#on)  
Inherited From: [Emitter.on](reference-emitter#on)  
Listen for a specific event and fire a handler block when it's emitted. Supports wildcard matching.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run when the event is emitted. If `event` contain wildcard block in addition to event payload pass event name. |  

#### EXAMPLE

```objc
// Get notified of '$.error.getState' emitted by passed emitter.
self.client.me.on(@"$.error.getState", ^(NSError *error) {
    NSLog(@"'$.error.getState' was fired", event);
});

/** 
 * Get notified of any error emitted by passed emitter. 
 * Handler block include additional argument to which handled event 
 * name will be passed. 
 */
self.client.me.on(@"$.error.*", ^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' was fired", event);
});
```


<br/><br/><a id="onany"/>

[`@property CENMe * (^onAny)(NSString *event, id data)`](#onany)  
Inherited From: [Emitter.onAny](reference-emitter#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | The handler block to run when any event is emitted. Block pass name of event and event data. |  

#### EXAMPLE

```objc
self.client.me.onAny(^(NSString *event, id data) {
    NSLog(@"All events trigger this.");
});
```


<br/><br/><a id="once"/>

[`@property CENMe * (^once)(NSString *event, id handler)`](#once)  
Inherited From: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run once. If `event` contain wildcard block in addition to payload pass event name. |  

#### EXAMPLE

```objc
self.client.me.once(@"$.error.getState", ^(NSDictionary *payload) {
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
 
<br/><br/><a id="extension"/>

[`@property CENMe * (^extension)(id plugin, void(^block)(id extension))`](#extension)  
Tutorials: [Plugins](concepts-plugins#plugin-extension)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin` | id       | The plugin class or identifier. |
| `block` | ^(id extension) | Reference on extension execution context block. Block pass one argument - reference on extension instance which can be used. |

<br/><br/><a id="removeall"/>

[`@property CENMe * (^removeAll)(NSString *event)`](#removeall)  
Inherited from: [Emitter.removeAll](reference-emitter#removeall)  
Stop all handler blocks from listening to an event.  

#### PARAMETERS

| Name    | Type     | Description     |
|:-------:|:--------:| --------------- |
| `event` | NSString | The event name. |

#### EXAMPLE

```objc
self.client.me.removeAll(@"$.error.*");
```


<br/><br/><a id="update"/>

[`@property CENChat * (^update)(NSDictionary * __nullable meta)`](#update)  
Update [Me](reference-me)'s state in a [Chat](reference-chat). All other [Users](reference-user) will be notified of this change via [$.state](reference-chatengine#event-state). Retrieve state at any time with [Me.state](reference-me#state).

#### PARAMETERS

| Name      | Type        | Description |
|:---------:|:-----------:| ----------- |
| `state`   | NSDictionary | The new state for [Me](reference-me). |  

#### EXAMPLE

```objc
me.update(@{ @"value": @YES });
```

### Events

<a id="event-invite"/>

[`$.invite`](#event-invite)  
Tutorials: [Private Chats](concepts-private-chat)  
Notified [Me](reference-me) that they've been invited to a new private [Chat](reference-chat). Fired by the [Chat.invite](reference-chat#invite) method.

#### EXAMPLE

```objc
self.client.me.direct.on(@"$.invite", ^(NSDictionary *payload) {
    CENChat *privateChat = self.client.Chat().name(payload[CENEventData.data][@"channel"]).create();
});
```

<br/><br/><a id="event-error-getstate"/>

[`$.error.getState`](#event-error-getstate)  
There was a problem fetching the state of this user.

#### EXAMPLE

```objc
chat.on(@"$.error.getState", ^(NSError *error) {
    NSLog(@"State fetch did fail: %@", error);
});
```