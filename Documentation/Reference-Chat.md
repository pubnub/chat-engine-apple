# CENChat

This is the root [Chat](reference-chat) class that represents a chat room.

### Subclass  

* [Object](reference-object) 
* [Emitter](reference-emitter)  

### Properties

<a id="asleep"/>

[`@property BOOL asleep`](#asleep)  
If user manually disconnects via [ChatEngine.disconnect](reference-chatengine#disconnect), the chat is put to `sleep`. If a connection is reestablished via [ChatEngine.reconnect](reference-chatengine#reconnect), sleep chats reconnected automatically.

<br/><a id="channel"/>

[`@property NSString *channel`](#channel)  
See: [PubNub Channels](https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-)  
A string identifier for the Chat room. Any chat with an identical channel will be able to communicate with one another.  

<br/><a id="connected"/>

[`@property BOOL connected`](#connected)  
Boolean value that indicates of the Chat is connected to the network.  

<br/><a id="hasconnected"/>

[`@property BOOL hasConnected`](#hasconnected)  
Keep a record if we've every successfully connected to this chat before.  

<br/><a id="isprivate"/>

[`@property (getter=isPrivate) BOOL private`](#isprivate)  
Excludes all users from reading or writing to the chat unless they have been explicitly invited via [Chat.invite](#invite).  

<br/><a id="meta"/>

[`@property NSDictionary *meta`](#meta)  
Chat metadata persisted on the server. Useful for storing things like the name and description. Call [Chat.update](#update) to update remote information.  
To enabled meta information synchronization, make sure to enable it with [Configuration.enableMeta](reference-configuration#enablemeta).  

<br/><a id="name"/>

[`@property NSString *name`](#name)  
Name of channel which has been passed during instance initialization.  

<br/><a id="users"/>

[`@property NSDictionary<NSString *, CENUser *> *users`](#users)  
A list of users in this [Chat](reference-chat). Automatically keep in sync as users join and leave the chat. Use [$.join](event-join) and related events to get notified when this changes.  

### Methods

<a id="connect"/>

[`@property CENChat * (^connect)(void)`](#connect)  
Establish authentication with the server, then subscribe with PubNub.  

#### FIRES:

* [$.connected](#event-connected)


#### EXAMPLE

```objc
// Create chat w/o with disabled auto connection.
CENChat *chat = self.client.Chat().autoConnect(NO).create();

// Request to connect to chat
chat.connect()
```

<br/><br/><a id="emit"/>

[`@property CENChatEmitBuilderInterface * (^emit)(NSString *event)`](#emit)  
Send events to other clients in this [Chat](reference-chat). Events are triggered over the network and all events are made on behalf of [Me](reference-me).  

#### PARAMETERS

Next parameters can be passed to builder:  

| Name    | Type         | Attributes | Description        |
|:-------:|:------------:|:----------:| ------------------ |  
| `event` | NSString     |            | The `event` name.  |   
| `data`  | NSDictionary |  optional  | The event payload. |   

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).

#### EXAMPLE

```objc
chat.emit(@"custom-event").data(@{ @"value": @YES }).perform();
chat.on(@"custom-event", ^(NSDictionary *payload) {
    CENUser *sender = payload[CENEventData.sender];

    NSLog(@"%@ emitted the value: %@", sender.uuid, payload[CENEventData.data]);
});
```

<br/><br/><a id="fetchuserupdates"/>

[`@property CENChat * (^fetchUserUpdates)(void)`](#fetchuserupdates)  
Ask PubNub for information about Users in this [Chat](reference-chat).  


#### EXAMPLE

```objc
chat.fetchUserUpdates().on(@"online.*", ^(NSString *event, CENUser *user) {
    // Handle user presence event.
});
```


<br/><br/><a id="invite"/>

[`@property CENChat * (^invite)(CENUser *user)`](#invite)  
Invite a user to this Chat. Authorizes the invited user in the Chat and send then an invite via [User.direct](reference-user#direct).  

#### PARAMETERS

Next parameters can be passed to builder:  

| Name   | Type                      | Attributes | Description        |
|:------:|:-------------------------:|:----------:| ------------------ |  
| `user` | [CENUser](reference-user) |            | The [CENUser](reference-user) to invite to this chatroom. |   

#### EXAMPLE

```objc
// One user running ChatEngine
CENChat *secretChat = self.client.Chat(@"secret-channel").create();
secretChat.invite(someoneElse);

// someoneElse in another instance of ChatEngine
me.direct.on(@"$.invite", ^(NSDictionary *payload) {
    CENChat *secretChat = self.client.Chat(payload[CENEventData.data][@"channel"]).create();
});
```

<br/><br/><a id="leave"/>

[`@property CENChat * (^leave)(void)`](#leave)  
Leave from the [Chat](reference-chat) on behalf of [Me](reference-me). Disconnects from the [Chat](reference-chat) and will stop receiving events.  

#### FIRES:

* [$.left](#event-left)
* [$.disconnected](#event-diconnected)

#### EXAMPLE

```objc
chat.leave();
```

<br/><br/><a id="objectify"/>

[`@property NSDictionary * (^objectify)(void)`](#objectify)  
Turns [Chat](reference-chat) into NSDictionary representation.  

#### EXAMPLE

```objc
CENChat *chat = self.client.Chat().name(@"test-chat").get();
NSLog(@"Chat dictionary representation: %@", chat.objectify());
```


<br/><br/><a id="off"/>

[`@property CENChat * (^off)(NSString *event, id handler)`](#off)  
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

chat.on(@"event", self.eventHandlingBlock);
// .....
chat.off(@"event", self.eventHandlingBlock);
```

<br/><br/><a id="offany"/>

[`@property CENChat * (^offAny)(id handlerBlock)`](#offany)  
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

chat.onAny(self.eventHandlingBlock);
// .....
chat.offAny(self.eventHandlingBlock);
```


<br/><br/><a id="on"/>

[`@property CENChat * (^on)(NSString *event, id handler)`](#on)  
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
chat.on(@"event", ^(NSDictionary *payload) {
    NSLog(@"'event' was fired", event);
});

/** 
 * Get notified of event.a and event.b emitted by passed emitter. 
 * Handler block include additional argument to which handled event 
 * name will be passed. 
 */
chat.on(@"event.*", ^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' was fired", event);
});
```


<br/><br/><a id="onany"/>

[`@property CENChat * (^onAny)(NSString *event, id data)`](#onany)  
Inherited From: [Emitter.onAny](reference-emitter#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | The handler block to run when any event is emitted. Block pass name of event and event data. |  

#### EXAMPLE

```objc
chat.onAny(^(NSString *event, id data) {
    NSLog(@"All events trigger this.");
});
```


<br/><br/><a id="once"/>

[`@property CENChat * (^once)(NSString *event, id handler)`](#once)  
Inherited From: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run once. If `event` contain wildcard block in addition to payload pass event name. |  

#### EXAMPLE

```objc
chat.once(@"message", ^(NSDictionary *payload) {
    NSLog(@"This is only fired once!");
});
```
 

<br/><br/><a id="plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(id plugin)`](#plugin)  
Tutorials: [Plugins](concepts-plugins)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin ` | id       | The plugin class or identifier. |
 
<br/><br/><a id="extension"/>

[`@property CENChat * (^extension)(id plugin, void(^block)(id extension))`](#extension)  
Tutorials: [Plugins](concepts-plugins#plugin-extension)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin` | id       | The plugin class or identifier. |
| `block` | ^(id extension) | Reference on extension execution context block. Block pass one argument - reference on extension instance which can be used. |

<br/><br/><a id="removeall"/>

[`@property CENChat * (^removeAll)(NSString *event)`](#removeall)  
Inherited from: [Emitter.removeAll](reference-emitter#removeall)  
Stop all handler blocks from listening to an event.  

#### PARAMETERS

| Name    | Type     | Description     |
|:-------:|:--------:| --------------- |
| `event` | NSString | The event name. |

#### EXAMPLE

```objc
chat.removeAll(@"message");
```


<br/><br/><a id="search"/>

[`@property CENChatSearchBuilderInterface * (^search)(void)`](#search)  
See: [Search](reference-search)  
Search through previously emitted events. Parameters act as `AND` operators. Returns an instance of the emitted based Search. Which will emit all old events unless `event` is supplied.

#### PARAMETERS

Next parameters can be passed to builder:  

| Name      | Type                      | Attributes | Default | Description |
|:---------:|:-------------------------:|:----------:|:-------:| ----------- |
| `name`   | NSString                  |  optional  |         | The [Event](reference-event) to search for.  |  
| `sender` | [CENUser](reference-user) |  optional  |         | The [User](reference-user) who sent the message. |  
| `limit`  | NSInteger                 |  optional  |   `20`  | The maximum number of results to return that match search criteria. Search will continue operating until it returns this number of results or it reached the end of history. Limit will be ignored in case if both `start` and `end` timetokens has been passed to search configuration. |  
| `pages`  | NSInteger                 |  optional  |   `10`  | Maximum number of search request which can be performed to reach specified search end criteria: `limit`. |  
| `count`  | NSInteger                 |  optional  |  `100`  | Maximum number of events returned with single search request. |  
| `start`  | NSNumber                  |  optional  |   `0`   | The timetoken to begin searching between. |  
| `end`    | NSNumber                  |  optional  |   `0`   | The timetoken to end searching between. |  

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).   


<br/><br/><a id="update"/>

[`@property CENChat * (^update)(NSDictionary * __nullable meta)`](#update)  
Update the [Chat](reference-chat) metadata on the server.

#### PARAMETERS

| Name      | Type        | Description |
|:---------:|:-----------:| ----------- |
| `meta`   | NSDictionary | Dictionary object representing chat metadata. |  

#### EXAMPLE

```objc
chat.update(@{ @"title": @"Chat title" });
```

### Events

<a id="event-connected"/>

[`$.connected`](#event-connected)  
Broadcast that the [Chat](#reference-chat) is connected to the network.

#### EXAMPLE

```objc
chat.on(@"$.connected", ^{
    NSLog(@"Chat is ready to go!");
});
```

<br/><br/><a id="event-connected"/>

[`$.disconnected`](#event-disconnected)  
Broadcast that the [Chat](#reference-chat) is disconnected from the network.

#### EXAMPLE

```objc
chat.on(@"$.disconnected", ^{
    NSLog(@"Chat has been disconnected.");
});
```

<br/><br/><a id="event-error-auth"/>

[`$.error.auth`](#event-error-auth)  
Broadcast that the [Chat](#reference-chat) did fail _handshake_ process.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `error` | NSError | Error instance with error information. |

#### EXAMPLE

```objc
chat.on(@"$.error.auth", ^(NSError *error) {
    NSLog(@"Unable to authorize with chat. Don't have enough access permissions: %@", error);
});

chat.invite(otherUser).on(@"$.error.auth", ^(NSError *error) {
    NSLog(@"Don't have enough access permissions: %@", error);
});
```

<br/><br/><a id="event-error-chat"/>

[`$.error.chat`](#event-error-chat)  
There was a problem during manipulate or access to chat data.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `error` | NSError | Error instance with error information. |

#### EXAMPLE

```objc
chat.update(@{ @"title": @"Chat title" }).on(@"$.error.chat", ^(NSError *error) {
    NSLog(@"Unable to change chat metadata: %@", error);
});

chat.leave().on(@"$.error.chat", ^(NSError *error) {
    NSLog(@"Don't have enough access permissions: %@", error);
});
```

<br/><br/><a id="event-error-presence"/>

[`$.error.presence`](#event-error-presence)  
There was a problem fetching the presence of this chat.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `error` | NSError | Error instance with error information. |

#### EXAMPLE

```objc
chat.fetchUserUpdates().on(@"$.error.presence", ^(NSError *error) {
    NSLog(@"Presence information fetch did fail: %@", error);
});
```

<br/><br/><a id="event-error-search"/>

[`$.error.search`](#event-error-search)  
There was a problem fetching the history of this chat.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `error` | NSError | Error instance with error information. |

#### EXAMPLE

```objc
chat.search().limit(3).create().search().on(@"$.error.search", ^(NSError *error) {
    NSLog(@"Search did fail: %@", error);
});
```

<br/><br/><a id="event-left"/>

[`$.left`](#event-left)  
Fired when [Me](reference-me) leaves [Chat](reference-chat).

#### EXAMPLE

```objc
chat.leave().on(@"$.left", ^{
    NSLog(@"Left chat.");
});
```

<br/><br/><a id="event-offline-disconnect"/>

[`$.offline.disconnect`](#event-offline-disconnect)  
Fired specifically when [User](reference-user) looses network connection to the [Chat](reference-chat) involuntarily.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `user` | [CENUser](reference-user) | The [User](reference-user) that disconnected. |

#### EXAMPLE

```objc
chat.on(@"$.offline.disconnect", ^(CENUser *user) {
    NSLog(@"'%@' disconnected from the network.", user.uuid);
});
```

<br/><br/><a id="event-offline-leave"/>

[`$.offline.leave`](#event-offline-leave)  
Fired when a [User](reference-user) intentionally leaves a [Chat](reference-chat).

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `user` | [CENUser](reference-user) | The [User](reference-user) that has left the room. |

#### EXAMPLE

```objc
chat.on(@"$.offline.leave", ^(CENUser *user) {
    NSLog(@"'%@' left the room manually.", user.uuid);
});
```

<br/><br/><a id="event-online-here"/>

[`$.online.here`](#event-online-here)  
Broadcast that a [User](reference-user) has come online. This is when the framework already know this user.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `user` | [CENUser](reference-user) | The [User](reference-user) that came online. |

#### EXAMPLE

```objc
chat.on(@"$.online.here", ^(CENUser *user) {
    NSLog(@"'%@' has come online!", user.uuid);
});
```

<br/><br/><a id="event-online-join"/>

[`$.online.join`](#event-online-join)  
Broadcast that a [User](reference-user) has come online. This is when the framework first learn of a user. This can be triggered by `$.join`, or other network events that notify the framework of a new user.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `user` | [CENUser](reference-user) | The [User](reference-user) that came online. |

#### EXAMPLE

```objc
chat.on(@"$.online.join", ^(CENUser *user) {
    NSLog(@"'%@' has joined the room!", user.uuid);
});
```