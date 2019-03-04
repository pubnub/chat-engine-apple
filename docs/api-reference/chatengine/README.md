# CENChatEngine

[CENChatEngine](../chatengine) client which is responsible for organization of 
[users](../user) interaction through [chats](../chat) and provide responses back to 
completion block / closure / delegate.


## Subclass  

* [CENEventEmitter](../emitter)  


## Properties

<a id="chats"/>

[`@property NSDictionary<NSString *, CENChat *> *chats`](#chats)
A map of all known [chats](../chat) in this instance of ChatEngine.


<br/><br/><a id="current-configuration"/>

[`@property CENConfiguration *currentConfiguration`](#current-configuration)  
Current [CENChatEngine](../chatengine) client configuration.


<br/><br/><a id="chat-global"/>

[`@property CENChat *global`](#chat-global)  
A global [chat](../chat) to which join all [users](../user) when 
[CENChatEngine](../chatengine) client connects.


<br/><br/><a id="logger"/>

[`@property PNLLogger *logger`](#logger)  
[CENChatEngine](../chatengine) logger which can be used to insert additional logs to console
(if enabled) and file (if enabled).


<br/><br/><a id="me"/>

[`@property CENMe *me`](#me)  
This instance of [CENChatEngine](../chatengine) represented as a special 
[user](../user) known as [local user](../me).  


<br/><br/><a id="pubnub"/>

[`@property PubNub *pubnub`](#pubnub)  
[PubNub](https://pubnub.com) client instance, the networking infrastructure that powers the realtime
communication between [users](../user) in [chats](../chat).


<br/><br/><a id="isready"/>

[`@property (getter = isReady) BOOL ready`](#isready)  
Whether [CENChatEngine](../chatengine) client is ready to use or not.  
[$.ready](#event-ready) event will be emitted when [CENChatEngine](../chatengine) client is 
ready.


<br/><br/><a id="sdkversion"/>

[`@property NSString *sdkVersion`](#sdkversion)  
[CENChatEngine](../chatengine) SDK version.


<br/><br/><a id="users"/>

[`@property NSDictionary<NSString *, CENUser *> *users`](#users)  
A map of all known [users](../user) in this [CENChatEngine](../chatengine) client.


## Methods

<a id="constructor"/>

[`+ (instancetype)clientWithConfiguration:(CENConfiguration *)configuration`](#constructor)  
Create and configure new [CENChatEngine](../chatengine) client instance.

### Parameters:

| Name            | Type                                          | Attributes | Description |
|:---------------:|:---------------------------------------------:|:----------:| ----------- |  
| `configuration` | [CENConfiguration](../configuration) * |  Required  | User-provided information about how client should operate and handle events. |

### Returns:

Configured and ready to use [CENChatEngine](../chatengine) client.  

### Example

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36"
                                                                   subscribeKey:@"demo-36"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
```

<br/><br/><a id="chat-create"/>

[`Chat().name(NSString *).private(BOOL).autoConnect(BOOL).meta(NSDictionary *).create()`](#chat-create)  
Create and configure [chat](../chat) using specified parameters.   

### Parameters:

| Name          | Type           | Attributes | Default         | Description |
|:-------------:|:--------------:|:----------:|:---------------:| ----------- |
| `name`        | NSString *     |  | `[NSDate date]` | Unique alphanumeric chat identifier with maximum 50 characters. Usually something like `The Watercooler`, `Support`, or `Off Topic`. See [PubNub Channels](https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-).<br/>PubNub `channel` names are limited to `92` characters. If a user exceeds this limit while creating chat, an `error` will be thrown. The limit includes the prefixes and suffixes added by the chat engine as listed [here](../../advanced-concepts/pubnub-channel-topology). |  
| `private`     | BOOL           |  | `NO`            | Whether [chat](../chat) access should be restricted only to invited [users](../user) or not. |  
| `autoConnect` | BOOL           |  | `YES`           | Whether [local user](../me) should be connected to this chat after creation or not. If set to `NO`, call [CENChat.connect](../chat#connect) method to connect to this [chat](../chat). |  
| `meta`        | NSDictionary * |  | `@{}`           | Information which should be persisted on server. To use this parameter [CENConfiguration.enableMeta](../configuration#enablemeta) should be set to `YES` during [CENChatEngine](../chatengine) client configuration. |

**Note:** Builder parameters can be specified in different variations depending from needs.

### Returns:

Configured and ready to use [CENChat](../chat) instance.

### Fires:

* [$.created.chat](../chat#event-created-chat)
* [$.error.auth](../chat#event-error-auth)

### Example

```objc
CENChat *chat = self.client.Chat().name(@"lobby").create();
```

<br/><br/><a id="chat-get"/>

[`Chat().name(NSString *).private(BOOL).get()`](#chat-get)  
Search for [chat](../chat) using specified parameters. 

### Parameters:

| Name          | Type           | Attributes | Default | Description |
|:-------------:|:--------------:|:----------:|:-------:| ----------- |
| `name`        | NSString *     | Required   |         | Unique alphanumeric chat identifier with maximum 50 characters. Usually something like `The Watercooler`, `Support`, or `Off Topic`. See [PubNub Channels](https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-).<br/>PubNub `channel` names are limited to `92` characters. If a user exceeds this limit while creating chat, an `error` will be thrown. The limit includes the prefixes and suffixes added by the chat engine as listed [here](../../advanced-concepts/pubnub-channel-topology). |  
| `private`     | BOOL           |            | `NO`    | Whether [chat](../chat) access should be restricted only to invited [users](../user) or not. |

**Note:** Builder parameters can be specified in different variations depending from needs.

### Returns:

Previously created [chat](../chat) instance or `nil` in case if it doesn't exists.

### Example

```objc
CENChat *chat = self.client.Chat().name(@"lobby").get();
```

<br/><br/><a id="connect"/>

[`connect(NSString *uuid).state(NSDictionary *).authKey(NSString *).perform()`](#connect)  
Connect [local user](../me) to real-time service using specified parameters.  

### Parameters:

| Name      | Type           | Attributes | Default         | Description |
|:---------:|:--------------:|:----------:|:---------------:| ----------- |  
| `uuid`    | NSString *     |  Required  |                 | Unique alphanumeric identifier for [local user](../me). It can be a device id, username, user id, email, etc. |  
| `state`   | NSDictionary * |            | `@{}`           | Object with [local user](../me) state which will be publicly available from [CENChatEngine.global](../chatengine#chat-global) chat.<br/>This object is sent to all other clients on the network, so no passwords! |  
| `authKey` | NSString *     |            | `[NSUUID UUID]` | User authentication secret key. Will be sent to authentication backend for validation. This is usually an access token. See \b {Authentication authentication} for more. See [Security](../../concepts/security) for more. |  

**Note:** Builder parameters can be specified in different variations depending from needs.

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.   

### Fires:

* [$.connected](../chat#event-connected)
* [$.created.chat](../chat#event-created-chat)
* [$.created.me](../me#event-created-me)
* [$.created.session](../session#event-created-session)
* [$.error.auth](../chat#event-error-auth)
* [$.error.sync](../session#event-error-sync)
* [$.network.down.decryption](#event-network-down-decryption)
* [$.network.down.denied](#event-network-down-denied)
* [$.network.down.issue](#event-network-down-issue)
* [$.network.down.offline](#event-network-down-offline)
* [$.network.down.tlsuntrusted](#event-network-down-tlsuntrusted)
* [$.network.up.connected](#event-network-up-connected)
* [$.network.up.reconnected](#event-network-up-reconnected)
* [$.ready](#event-ready)

### Example

```objc
self.client.connect(@"PubNub").authKey(@"secret").perform();
```


<br/><br/><a id="disconnect"/>

[`disconnect()`](#disconnect)  
Disconnect from all [chats](../chat) and mark them as asleep.  

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.   

### Fires:

* [$.disconnected](../chat#event-disconnected)
* [$.network.down.disconnected](#event-network-down-disconnected)

### Example

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

[`off(NSString *event, CENEventHandlerBlock handler)`](#off)  
Inherited From: [CENEventEmitter.off](../emitter#off)  
Unsubscribe from particular or multiple (wildcard) `events` by removing `handler` from listeners 
list.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event for which handler should be removed. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.  

### Example

Stop specific event handling
```objc
self.createHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle chat instance creation.
};

self.client.off(@"$.created.chat", self.createHandlingBlock);
```

Stop multiple event handling
```objc
self.createHandlingBlock = ^(id emitter, NSDictionary *payload) {
    // Handle object creation events: $.created.chat, $.created.user,
    // $.created.me, $.created.search and other.
};

self.client.off(@"$.created.*", self.createHandlingBlock);
```


<br/><br/><a id="offany"/>

[`offAny(CENEventHandlerBlock handler)`](#offany)  
Inherited from: [CENEventEmitter.offAny](../emitter#offany)  
Unsubscribe from any events emitted by receiver by removing `handler` from listeners list.   

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.  

### Example

```objc
self.anyHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any client event.
};
self.client.offAny(self.anyHandlingBlock);
```


<br/><br/><a id="on"/>

[`on(NSString *event, CENEventHandlerBlock handler)`](#on)  
Inherited From: [CENEventEmitter.on](../emitter#on)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and handle
it with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
self.client.on(@"$.created.chat", ^(CENEmittedEvent *event) {
    // Handle chat instance creation.
});
```

Handle multiple events using wildcard.
```objc
self.client.on(@"$.created.*", ^(CENEmittedEvent *event) {
    // Handle object creation events: $.created.chat, $.created.user,
    // $.created.me, $.created.search and other.
});
```


<br/><br/><a id="onany"/>

[`onAny(CENEventHandlerBlock handler)`](#onany)  
Inherited From: [CENEventEmitter.onAny](../emitter#onany)  
Subscribe on any events which will be emitted by receiver and handle them with provided event 
handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle any events. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.  

### Example

```objc
self.client.onAny(^(CENEmittedEvent *event) {
    // Handle any client event.
});
```


<br/><br/><a id="once"/>

[`once(NSString *event, CENEventHandlerBlock handler)`](#once)  
Inherited From: [CENEventEmitter.once](../emitter#once)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and 
handle it once with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
self.client.once(@"$.created.chat", ^(CENEmittedEvent *event) {
    // Handle chat instance creation once.
});
```

Handle one of multiple events once using wildcard.
```objc
self.client.once(@"$.created.*", ^(CENEmittedEvent *event) {
    // Handle any object creation event once: $.created.chat, $.created.user,
    // $.created.me, $.created.search and other.
});
```


<br/><br/><a id="proto-exists"/>

[`proto(NSString *object, id plugin).exists()`](#proto-exists)  
Check whether proto plugin exists using specified parameters.  
 
### Parameters

| Name            | Type               | Attributes | Description |
|:---------------:|:------------------:|:----------:| ----------- |
| `object`        | NSString *         |  Required  | Object's type for which proto plugins should be accessed: `Chat`, `User`, `Me` or `Search`. |
| `plugin`        | Class / NSString * |  Required  | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. |

### Returns:

Whether proto plugin exists or not.

### Example

```objc
if (self.client.proto(@"Chat", [CENMarkdownPlugin class]).exists()) {
    // Markdown proto plugin already registered.
}
```


<br/><br/><a id="proto-remove"/>

[`proto(NSString *object, id plugin).exists()`](#proto-remove)   
Remove plugin using specified parameters.  
 
### Parameters

| Name            | Type               | Attributes | Description |
|:---------------:|:------------------:|:----------:| ----------- |
| `object`        | NSString *         |  Required  | Object's type for which proto plugins should be accessed: `Chat`, `User`, `Me` or `Search`. |
| `plugin`        | Class / NSString * |  Required  | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. |

### Example

```objc
self.client.proto(@"Chat", [CENMarkdownPlugin class]).remove();
```


<br/><br/><a id="proto-store"/>

[`proto(NSString *object, id plugin).identifier(NSString *).configuration(NSDictionary *).store()`](#proto-store)   
Create proto plugin using specified parameters.  
 
### Parameters

| Name            | Type               | Attributes | Default               | Description |
|:---------------:|:------------------:|:----------:|:---------------------:| ----------- |
| `object`        | NSString *         |  Required  |                       | Object's type for which proto plugins should be accessed: `Chat`, `User`, `Me` or `Search`. |
| `plugin`        | Class / NSString * |  Required  |                       | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. | 
| `identifier`    | NSString *         |            | `Plugin's identifier` | Plugin identifier under which initialized plugin will be stored and can be retrieved. | 
| `configuration` | NSDictionary *     |            | `@{}`                 | Dictionary with configuration for plugin. | 

**Note:** Builder parameters can be specified in different variations depending from needs.

### Example

```objc
self.client.proto(@"Chat", [AwesomeChatPlugin class])
    .identifier(@"com.awesome.plugin")
    .configuration(@{ @"api-key": @"secret" })
    .store();
```


<br/><br/><a id="reauthorize"/>

[`reauthorize(NSString *authKey)`](#reauthorize)  
Re-authorize [local user](../user) with new `authorization` key.  
Disconnects, changes authentication token, performs handshake with server and reconnects with new 
auth key. Used for extending logged in session for active users.

### Parameters:

| Name      | Type       | Attributes | Description |
|:---------:|:----------:|:----------:| ----------- |  
| `authKey` | NSString * |  Required  | Reference on key which should be used for `local` user from now on. |

### Fires: 

* [$.connected](../chat#event-connected)
* [$.error.auth](../chat#event-error-auth)
* [$.network.down.denied](#event-network-down-denied)
* [$.network.down.issue](#event-network-down-issue)
* [$.network.down.offline](#event-network-down-offline)
* [$.network.up.connected](#event-network-up-connected)

### Example

```objc
// After some time, maybe after some access token expiration.
self.client.reauthorize(@"super-secret");

self.client.once(@"$.connected", ^(CENEmittedEvent *event) {
    // Handle connection again after authorization with different key.
});
```


<br/><br/><a id="reconnect"/>

[`reconnect()`](#reconnect)  
Performs authentication with server and restores connection to all sleeping chats.  

### Fires:

* [$.connected](../chat#event-connected)
* [$.error.auth](../chat#event-error-auth)
* [$.network.down.denied](#event-network-down-denied)
* [$.network.down.issue](#event-network-down-issue)
* [$.network.down.offline](#event-network-down-offline)
* [$.network.up.connected](#event-network-up-connected)

### Example

```objc
// Create a new chat
CENChat *chat = self.client.Chat().create();

// Disconnect from ChatEngine
self.client.disconnect();

// Reconnect sometime later.
self.client.reconnect();
```

<br/><br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)  
Inherited from: [CENEventEmitter.removeAll](../emitter#removeall)  
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  

### Parameters:

| Name    | Type       | Attributes | Description     |
|:-------:|:----------:|:----------:| --------------- |
| `event` | NSString * |  Required  | Name of event for which has been used to register handler blocks. | 

### Returns:

[Receiver](../chatengine) which can be used to chain other methods call.  

### Example

```objc
self.client.removeAll(@"$.state");
```


<br/><br/><a id="user-create"/>

[`User(NSString *uuid).state(NSDictionary *).create()`](#user-create)  
Create new [user](../user) using specified parameters.  

### Parameters:

| Name    | Type           | Attributes | Default | Description |
|:-------:|:--------------:|:----------:|:-------:| ----------- |  
| `uuid`  | NSString *     |  Required  |         | Unique alphanumeric identifier for this [user](../user). It can be a device id, username, user id, email, etc. |  
| `state` | NSDictionary * |            | `@{}`   | `NSDictionary` with `user`'s information synchronized between all clients of [CENChatEngine.global](../chatengine#chat-global) chat. |  

**Note:** Builder parameters can be specified in different variations depending from needs.

### Returns:

Configured and ready to use [CENUser](../user) instance.

### Example

Create user w/o state
```objc
CENUser *user = self.client.User(@"ChatEngineUser").create();
```

Create user w/ state
```objc
CENUser *user = self.client.User(@"ChatEngineUser").state(@{ @"name": @"PubNub" }).create();
```


<br/><br/><a id="user-get"/>

[`User(NSString *uuid).get()`](#user-get)  
Search for user instance basing on passed parameters. 

### Parameters:

| Name    | Type           | Attributes | Default | Description |
|:-------:|:--------------:|:----------:|:-------:| ----------- |  
| `uuid`  | NSString *     |  Required  |         | Unique alphanumeric identifier for this [user](../user). It can be a device id, username, user id, email, etc. |  
| `state` | NSDictionary * |            | `nil`   | Dictionary which may contain additional information about `user` and publicly available from ChatEngine network. |  

### Returns:

Previously created [CENUser](../user) instance or `nil` in case if it doesn't exists.

### Example

```objc
CENUser *user = self.client.User(@"ChatEngineUser").get();
```


## Events

[CENChatEngine](../chatengine) in addition to own [events](#events) is able to handle events
sent by other components ([CENChat](../chat#events), [CENUser](../user#events),
[CENMe](../me#events), [CENSession](../chat#events), 
[CENEvent](../event#events) and [CENSearch](../search#events)) where locally emitted 
event [representation object](../emitted-event) `emitter` property will be set to 
corresponding object.

<br/><a id="event-network-down-badrequest"/>

[`$.network.down.badrequest`](#event-network-down-badrequest)  
Notify locally what [CENChatEngine](../chatengine) was unable to connect to real-time network 
because of incomplete configuration of used [PubNub](https://pubnub.com) client API.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.badrequest` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNErrorStatus](https://www.pubnub.com/docs/ios-objective-c/status-events) * | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.client.on(@"$.network.down.badrequest", ^(CENEmittedEvent *event) {
    PNErrorStatus *status = event.data;
    
    NSLog(@"Error information: %@", status.errorData.information);
});
```


<br/><br/><a id="event-network-down-decryption"/>

[`$.network.down.decryption`](#event-network-down-decryption)  
Notify locally what used decryption passphrase (`cipherKey`) can't be used to decrypt received data.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.decryption` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNErrorStatus](https://www.pubnub.com/docs/ios-objective-c/status-events) * | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.client.on(@"$.network.down.decryption", ^(CENEmittedEvent *event) {
    PNErrorStatus *status = event.data;
    PNMessageData *messageData = status.associatedObject;
    
    NSLog(@"Unable to decrypt message sent from '%@': %@", messageData.publisher, messageData.message);
});
```


<br/><br/><a id="event-network-down-denied"/>

[`$.network.down.denied`](#event-network-down-denied)  
Notify locally what user's authorization key used with 
[CENChatEngine.connect](../chatengine#connect) doesn't have required permissions.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.denied` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNErrorStatus](https://www.pubnub.com/docs/ios-objective-c/status-events) * | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.client.on(@"$.network.down.denied", ^(CENEmittedEvent *event) {
    PNErrorStatus *status = event.data;
    
    if (status.errorData.channels) {
        NSLog(@"Missing access rights for channels: %@", status.errorData.channels);
    }

    if (status.errorData.channelGroups) {
        NSLog(@"Missing access rights for channel group: %@", status.errorData.channelGroups);
    }
});
```


<br/><br/><a id="event-network-down-disconnected"/>

[`$.network.down.disconnected`](#event-network-down-disconnected)  
SDK unsubscribed from channels on user's request.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.disconnected` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNSubscribeStatus](https://www.pubnub.com/docs/ios-objective-c/api-../publish-and-subscribe#subscribe_returns) * | [PubNub](https://pubnnub.com) SDK object which contain information about list of active subscriptions and time of last response. |

### Example

```objc
self.client.on(@"$.network.down.disconnected", ^(CENEmittedEvent *event) {
    PNSubscribeStatus *status = event.data;
                                                   
    NSLog(@"Disconnected");
});
```


<br/><br/><a id="event-network-down-issue"/>

[`$.network.down.issue`](#event-network-down-issue)  
Notify locally what subscribe event experienced an exception when running.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.issue` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNErrorStatus](https://www.pubnub.com/docs/ios-objective-c/status-events) * | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.client.on(@"$.network.down.issue", ^(CENEmittedEvent *event) {
    PNErrorStatus *status = event.data;
    
    NSLog(@"Error information: %@", status.errorData.information);
});
```


<br/><br/><a id="event-network-down-offline"/>

[`$.network.down.offline`](#event-network-down-offline)  
Notify locally what SDK detected that network is down.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.offline` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNSubscribeStatus](https://www.pubnub.com/docs/ios-objective-c/api-../publish-and-subscribe#subscribe_returns) * | [PubNub](https://pubnnub.com) SDK object which contain information about list of active subscriptions and time of last response. |

### Example

```objc
self.client.on(@"$.network.down.offline", ^(CENEmittedEvent *event) {
    PNSubscribeStatus *status = event.data;
    
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
Notify locally what SDK detected issues with service certificates.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.down.tlsuntrusted` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNErrorStatus](https://www.pubnub.com/docs/ios-objective-c/status-events) * | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.client.on(@"$.network.down.tlsuntrusted", ^(CENEmittedEvent *event) {
    PNErrorStatus *status = event.data;
                                     
    NSLog(@"Error information: %@", status.errorData.information);
});
```


<br/><br/><a id="event-network-up-connected"/>

[`$.network.up.connected`](#event-network-up-connected)  
Notify locally what SDK subscribed with a new mix of channels.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.up.connected` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNSubscribeStatus](https://www.pubnub.com/docs/ios-objective-c/api-../publish-and-subscribe#subscribe_returns) * | [PubNub](https://pubnnub.com) SDK object which contain information about list of active subscriptions and time of last response. |

### Example

```objc
self.client.on(@"$.network.up.connected", ^(CENEmittedEvent *event) {
    PNSubscribeStatus *status = event.data;
    
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
Notify locally what SDK was able to reconnect to PubNub.  

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.network.up.reconnected` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [PNSubscribeStatus](https://www.pubnub.com/docs/ios-objective-c/api-../publish-and-subscribe#subscribe_returns) * | [PubNub](https://pubnnub.com) SDK object which contain information about list of active subscriptions and time of last response. |

### Example

```objc
self.client.on(@"$.network.up.reconnected", ^(CENEmittedEvent *event) {
    PNSubscribeStatus *status = event.data;
    
    if (status.subscribedChannels.count) {
        NSLog(@"Re-connected to channels: %@", status.subscribedChannels);
    }

    if (status.subscribedChannelGroups.count) {
        NSLog(@"Re-connected to channel groups: %@", status.subscribedChannelGroups);
    }
});
```


<br/><br/><a id="event-ready"/>

[`$.ready`](#event-ready)  
Notify locally when [CENChatEngine](../chatengine) is connected to the internet and ready to
go!

### Properties:

| Name      | Type       |  Value         | Description |
|:---------:|:----------:|:--------------:| ----------- |
| `event`   | NSString * | `$.ready` | Name of handled event. |
| `emitter` | id         | [CENChatEngine](../chatengine) * | Object, which emitted local event. In this case it will be `self.client` since handler added to listen [CENChatEngine](../chatengine) emitted events. |
| `data`    | id         | [CENMe](../me) * | [Local user](../me) with which [CENChatEngine](../chatengine) connected to real-time network. |

### Example

```objc
self.client.on(@"$.ready", ^(CENEmittedEvent *event) {
    CENMe *me = event.data;
});
```