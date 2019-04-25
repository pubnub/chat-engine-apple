# CENChatEngine

<a id="constructor"/>

[`+ (instancetype)clientWithConfiguration:(CENConfiguration *)configuration`](#constructor)  
Create and configure new [ChatEngine](reference-chatengine) client instance with pre-defined configuration.  

#### PARAMETERS

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `configuration` | [CENConfiguration](reference-configuration) | | Reference on instance which store all user-provided information about how client should operate and handle events. |  

#### EXAMPLE

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
```

### Subclass  

* [Emitter](reference-emitter)  

### Properties

<a id="chat"/>

[`@property CENChatBuilderInterface * (^Chat)(void)`](#chat)  
Property provide access to builder which allow create or fetch [chat](reference-chat). `create()` API will instantiate new [Chat](reference-chat) instance, or returns an existing instance if chat has already been created.  

#### PARAMETERS

Next parameters can be passed to builder:  

| Name          | Type         | Attributes | Default                            | Description |
|:-------------:|:------------:|:----------:|:----------------------------------:| ----------- |
| `name`        | NSString     | optional   | `Random unixtimestamp-based name.` | Chat name.  |  
| `private`     | BOOL         | optional   | `NO` | Whether chat require owner's authorization to get access to it or not.<br/>Public chat(s) can be accessed by any user, but `private` require it's owner to grant access rights to read and write. |  
| `autoConnect` | BOOL         | optional   | `YES` |Whether chat should start receive updates on creation or not.<br/>If set to `YES`, [ChatEngine](reference-chatengine) will subscribe for real-time updates after chat instance will be created |  
| `meta`        | NSDictionary | optional   | | Reference on meta data which should be appended to created [chat](reference-chat).<br/>This option require to set `enableMeta` to `YES` in [CENConfiguration](reference-configuration) which used for [ChatEngine](reference-chatengine) configuration.  |  
| `group`       | NSString     | optional   | `custom` |Chat(s) aggregation group name. Available values descrived by [this](reference-structure-chat-groups) structure.  |  

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).   

#### EXAMPLE

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
self.client.once(@"$.ready", ^(CENMe *me) {
    CENChat *chat = self.client.Chat().name(@"lobby").create();
});
// .....
// Find public chat instance with 'lobby' name.
CENChat *chat = self.client.Chat().name(@"lobby").get();
```


<br/><br/><a id="chats"/>

[`@property NSDictionary<NSString *, CENChat *> *chats`](#chats)  
A map of all known [Chats](reference-chat) in this instance of ChatEngine.


<br/><br/><a id="chat-global"/>

[`@property CENChat *global`](#chat-global)  
A global [Chat](reference-chat) that all [Users](reference-user) join when they connect to ChatEngine. Useful for announcement, alerts, and global events.


<br/><br/><a id="user"/>

[`@property CENUserBuilderInterface * (^User)(NSString *uuid)`](#user)  
Property provide access to builder which allow create or fetch [user](reference-user). `create()` API will instantiate new [User](reference-user) instance, or returns an existing instance if user has already been created.  

#### PARAMETERS

Next parameters can be passed to builder:  

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `uuid`  | NSString     |            | Unique user identifier. |  
| `state` | NSDictionary | optional   | Dictionary which may contain additional information about \c user and publicly available from ChatEngine network  |  

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).


#### EXAMPLE

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
self.client.once(@"$.ready", ^(CENMe *me) {
    CENUser *user = self.client.User(@"PubNub").create();
});
// .....
// Find user instance with 'PubNub' name.
CENUser *user = self.client.User(@"PubNub").get();
```


<br/><br/><a id="users"/>

[`@property NSDictionary<NSString *, CENUser *> *users`](#users)  
A map of all known [Users](reference-user) in this instance of ChatEngine.


<br/><br/><a id="me"/>

[`@property CENMe *me`](#me)  
This instance of ChatEngine represented as a special [User](reference-user) known as [Me](reference-me).


<br/><br/><a id="pubnub"/>

[`@property PubNub *pubnub`](#pubnub)  
An instance of PubNub, the networking infrastructure that powers the realtime communication between [Users](reference-user) in Chats.


<br/><br/><a id="isready"/>

[`@property (getter = isReady) BOOL ready`](#isready)  
Indicates if ChatEngine has fired the `$.ready` event.


### Methods

<a id="connect"/>

[`@property CENUserConnectBuilderInterface * (^connect)(NSString *uuid)`](#connect)  
Connect to realtime service and create instance of [Me](reference-me).  

#### PARAMETERS

Next parameters can be passed to builder:  

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `uuid`   | NSString | | A unique string for [Me](reference-me). It can be a device id, username, user id, email, etc. Must be alphanumeric. |  
| `state`   | NSDictionary | optional | An object containing information about this client ([Me](reference-me)). This JSON object is sent to all other clients on the network, so no passwords! |  
| `authKey`   | NSString | optional | A authentication secret. Will be sent to authentication backend for validation. This is usually an access token. See [Authentication](concepts-authentication) for more. |  

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).

#### FIRES:

* [$.connected](#event-network-up-connected)

#### EXAMPLE

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
self.client.connect(@"PubNub").authKey(@"secret").perform();
```


<br/><br/><a id="disconnect"/>

[`@property CENChatEngine * (^disconnect)(void)`](#disconnect)  
Disconnect from all [Chats](reference-chat) and mark them as asleep.  

#### FIRES:

* [$.disconnected](#event-network-down-disconnected)

#### EXAMPLE

```objc
// Create a new chat.
CENChat *chat = self.client.Chat().create();

// Disconnect from ChatEngine.
self.client.disconnect();

// Every individual chat will be disconnected.
chat.on(@"$.disconnected", ^{
    // Chat disconnected and asleep.
});
```


<br/><br/><a id="off"/>

[`@property CENChatEngine * (^off)(NSString *event, id handler)`](#off)  
Inherited From: [Emitter.off](reference-emitter#off)  
Stop a handler block from listening to an event.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | Reference on same handler block which has been used with `on()`. |  

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(id emitter, NSDictionary *payload) {
    NSLog(@"Something happened!");
};

self.client.on(@"$.created.chat", self.eventHandlingBlock);
// .....
self.client.off(@"$.created.chat", self.eventHandlingBlock);
```

<br/><br/><a id="offany"/>

[`@property CENChatEngine * (^offAny)(id handler)`](#offany)  
Inherited from: [Emitter.offAny](reference-emitter#offany)  
Stop a handler block from listen to any events.   

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | Reference on same handler block which has been used with `onAny()`. |  

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(NSString *event, id emitterOrData, id data) {
    NSLog(@"Something happened!");
};

self.client.onAny(self.eventHandlingBlock);
// .....
self.client.offAny(self.eventHandlingBlock);
```


<br/><br/><a id="on"/>

[`@property CENChatEngine * (^on)(NSString *event, id handler)`](#on)  
Inherited From: [Emitter.on](reference-emitter#on)  
Listen for a specific event and fire a handler block when it's emitted. Supports wildcard matching.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run when the event is emitted. If `event` contain wildcard block in addition to emitter and event payload pass event name. |  

#### EXAMPLE

```objc
// Get notified of 'event' emitted by passed emitter.
self.client.on(@"$.created.chat", ^(id emitter, NSDictionary *payload) {
    NSLog(@"'event' was fired", event);
});

/** 
 * Get notified of created.chat and created.user emitted by passed emitter. 
 * Handler block include additional argument to which handled event 
 * name will be passed. 
 */
self.client.on(@"$.created.*", ^(NSString *event, id emitter, NSDictionary *payload) {
    NSLog(@"'%@' was fired", event);
});
```


<br/><br/><a id="onany"/>

[`@property CENChatEngine * (^onAny)(NSString *event, id emitterOrData, id data)`](#onany)  
Inherited From: [Emitter.onAny](reference-emitter#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  
If event has been generated by ChatEngine client itself, then `emitterOrData` can be reference on data generated by event (if any). If ChatEngine forward events from other objects, `emitterOrData` reference on object from which event has been forwarded.


#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | The handler block to run when any event is emitted. Block pass three arguments: name of event, event emitter/data and event payload. |  

#### EXAMPLE

```objc
self.client.onAny(^(NSString *event, id emitterOrData, id data) {
    NSLog(@"All events trigger this.");
});
```


<br/><br/><a id="once"/>

[`@property CENChatEngine * (^once)(NSString *event, id handler)`](#once)  
Inherited From: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run once. If `event` contain wildcard block in addition to emitter and event payload pass event name. |  

#### EXAMPLE

```objc
self.client.once(@"$.ready", ^(id emitter, NSDictionary *payload) {
    NSLog(@"This is only fired once!");
});
```


<br/><br/><a id="proto"/>

[`@property CENPluginsBuilderInterface * (^proto)(NSString *object, id plugin)`](#proto)  
Inherited From: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name            | Type         | Attributes | Description |
|:---------------:|:------------:|:----------:| ----------- |  
| `object`        | NSString     |            | Name of object to which `plugin` should be attached: `User`, `Me`, `Chat` or `Search`. |
| `plugin`        | id           |            | Reference on class which should be registered as `proto` plugin or plugin's identifier for removal or check . |   
| `identifier`    | NSString     |  optional  | Custom identifier under which `proto` plugin should be registered. |   
| `configuration` | NSDictionary |  optional  | Dictionary with set of data which required by plugin developer for it's proper operation. |   

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).

#### EXAMPLE

```objc
// Register Chat's proto plugin using plugin-defined identifier
self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();

// Register Chat's proto plugin using custom identifier and configuration.
self.client.proto(@"Chat", [CENTypingIndicatorPlugin class])
    .identifier(@"my-typing-indicator")
    .configuration(@{ CENTypingIndicatorConfiguration.timeout: @(3.f) }).store();

// Check whether Chat has markdown proto plugin.
if (self.client.proto(@"Chat", [CENMarkdownPlugin class]).exists()) {
    // Markdown proto plugin already registered.
}

// Check whether Chat has typing indicator proto plugin.
if (self.client.proto(@"Chat", @"my-typing-indicator").exists()) {
    // Markdown proto plugin already registered.
}

// Remove Chat's typing indicator proto plugin.
self.client.proto(@"Chat", @"my-typing-indicator").remove();
```


<br/><br/><a id="reauthorize"/>

[`@property CENChatEngine * (^reauthorize)(NSString *authKey)`](#reauthorize)  
Disconnects, changes authentication token, performs handshake with server and reconnects with new auth key. Used for extending logged in session for active users.

#### PARAMETERS

| Name      | Type     | Attributes | Description |
|:---------:|:--------:|:----------:| ----------- |  
| `authKey` | NSString |            | Reference on key which should be used for `local` user from now on. |

#### EXAMPLE

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
self.client.connect(@"PubNub").authKey(@"secret").perform();

self.client.once(@"$.connected", ^(CENChat *chat) {
    // First connection established. 
});

// Some time passes, session token expires.
self.client.reauthorize(authKey);

self.client.once(@"$.connected", ^(CENChat *chat) {
    // Second connection established. 
});
```


<br/><br/><a id="reconnect"/>

[`@property CENChatEngine * (^reconnect)(void)`](#reconnect)  
Performs authentication with server and restores connection to all sleeping chats.

#### FIRES:

* [$.connected](#event-network-up-connected)

#### EXAMPLE

```objc
// Create a new chat.
CENChat *chat = self.client.Chat().create();

// Disconnect from ChatEngine.
self.client.connect(@"PubNub").authKey(@"secret").perform();

// Reconnect sometime later.
self.client.reconnect();
```

<br/><br/><a id="removeall"/>

[`@property CENChatEngine * (^removeAll)(NSString *event)`](#removeall)  
Inherited from: [Emitter.removeAll](reference-emitter#removeall)  
Stop all handler blocks from listening to an event.  

#### PARAMETERS

| Name    | Type     | Description     |
|:-------:|:--------:| --------------- |
| `event` | NSString | The event name. |

#### EXAMPLE

```objc
self.client.removeAll(@"$.state");
```


### Events

<a id="event-created-chat"/>

[`$.created.chat`](#event-created-chat)  
Fired when a [Chat](#reference-chat) has been created within ChatEngine.

#### EXAMPLE

```objc
self.client.on(@"$.created.chat", ^(CENChat *chat) {
    NSLog(@"Chat was created: %@", chat);
});
```


<br/><br/><a id="event-created-me"/>

[`$.created.me`](#event-created-me)  
Fired when a [Me](#reference-me) has been created within ChatEngine.

#### EXAMPLE

```objc
self.client.on(@"$.created.me", ^(CENMe *me) {
    NSLog(@"Me was created: %@", me);
});
```


<br/><br/><a id="event-created-user"/>

[`$.created.user`](#event-created-user)  
Fired when a [User](#reference-user) has been created within ChatEngine.

#### EXAMPLE

```objc
self.client.on(@"$.created.user", ^(CENUser *user) {
    NSLog(@"User was created: %@", user);
});
```


<br/><br/><a id="event-network-down-badrequest"/>

[`$.network.down.badrequest`](#event-network-down-badrequest)  
ChatEngine was unable to connect to real-time network because of incomplete configuration of used PubNub client API.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.badrequest", ^(PNErrorStatus *status) {
    NSLog(@"Error information: %@", status.errorData.information);
});
```


<br/><br/><a id="event-network-down-decryption"/>

[`$.network.down.decryption`](#event-network-down-decryption)  
If using decryption strategies and the decryption fails.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.decryption", ^(PNErrorStatus *status) {
    PNMessageData *messageData = status.associatedObject;
    NSLog(@"Unable to decrypt message sent from '%@': %@", messageData.publisher, messageData.message);
});
```


<br/><br/><a id="event-network-down-denied"/>

[`$.network.down.denied`](#event-network-down-denied)  
PAM permission failure.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.denied", ^(PNErrorStatus *status) {
    if (status.errorData.channels) {
        NSLog(@"Missing access rights for channels: %@", status.errorData.channels);
    }

    if (status.errorData.channelGroups) {
        NSLog(@"Missing access rights for channel group: %@", status.errorData.channelGroups);
    }
});
```


<br/><br/><a id="event-network-down-issue"/>

[`$.network.down.issue`](#event-network-down-issue)  
A subscribe event experienced and exception when running.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.issue", ^(PNErrorStatus *status) {
    NSLog(@"Error information: %@", status.errorData.information);
});
```


<br/><br/><a id="event-network-down-offline"/>

[`$.network.down.offline`](#event-network-down-offline)  
SDK detected that network is down.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.issue", ^(PNSubscribeStatus *status) {
    if (status.subscribedChannels.count) {
        NSLog(@"Unexpectedly disconnected from channels: %@", status.subscribedChannels);
    }

    if (status.subscribedChannelGroups.count) {
        NSLog(@"Unexpectedly disconnected from channel groups: %@", status.subscribedChannelGroups);
    }
});
```


<br/><br/><a id="event-network-down-tlsuntrusted"/>

[`$.network.down.tlsuntrusted`](#event-network-down-tlsuntrusted)  
SDK detected issues with service certificates.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.tlsuntrusted", ^(PNErrorStatus *status) {
    NSLog(@"Error information: %@", status.errorData.information);
});
```


<br/><br/><a id="event-network-down-disconnected"/>

[`$.network.down.disconnected`](#event-network-down-disconnected)  
SDK unsubscribed from channels on user's request.

#### EXAMPLE

```objc
self.client.on(@"$.network.down.disconnected", ^(PNStatus *status) {
    NSLog(@"Disconnected");
});
```


<br/><br/><a id="event-network-up-connected"/>

[`$.network.up.connected`](#event-network-up-connected)  
SDK subscribed with a new mix of channels.

#### EXAMPLE

```objc
self.client.on(@"$.network.up.connected", ^(PNSubscribeStatus *status) {
    if (status.subscribedChannels.count) {
        NSLog(@"Connected to channels: %@", status.subscribedChannels);
    }

    if (status.subscribedChannelGroups.count) {
        NSLog(@"Connected to channel groups: %@", status.subscribedChannelGroups);
    }
});
```


<br/><br/><a id="event-network-up-reconnected"/>

[`$.network.up.reconnected`](#event-network-up-reconnected)  
SDK was able to reconnect to pubnub.

#### EXAMPLE

```objc
self.client.on(@"$.network.up.reconnected", ^(PNSubscribeStatus *status) {
    if (status.subscribedChannels.count) {
        NSLog(@"Re-connected to channels: %@", status.subscribedChannels);
    }

    if (status.subscribedChannelGroups.count) {
        NSLog(@"Re-connected to channel groups: %@", status.subscribedChannelGroups);
    }
});
```


<br/><br/><a id="event-error-sync"/>

[`$.error.sync`](#event-error-sync)  
SDK was unable to complete local user session synchronization.

#### EXAMPLE

```objc
self.client.on(@"$.error.sync", ^(NSError *error) {
    // Session synchronization did fail.
});
```


<br/><br/><a id="event-ready"/>

[`$.ready`](#event-ready)  
Fired when ChatEngine is connected to the internet and ready to go!

#### EXAMPLE

```objc
self.client.on(@"$.ready", ^(CENMe *me) {
    // Connected and ready to go!
});
```


<br/><br/><a id="event-state"/>

[`$.state`](#event-state)  
Broadcast that [User](reference-user) has changed state.

#### EXAMPLE

```objc
self.client.on(@"$.state", ^(CENUser *user) {
    NSLog(@"'%@' has changed state: %@", user.uuid, user.state);
});
```