# CENChat

[CENChatEngine](../chatengine) chat room representation.


## Subclass  

* [CENEventEmitter](../emitter)  
* [CENObject](../object) 


## Properties

<a id="asleep"/>

[`@property BOOL asleep`](#asleep)  
Whether chat has been manually disconnected or not.  
If user manually disconnects via [CENChatEngine.disconnect](../chatengine#disconnect), the 
chat is put to `sleep`. If a connection is reestablished via 
[CENChatEngine.reconnect](../chatengine#reconnect), sleeping chats reconnect automatically.


<br/><a id="channel"/>

[`@property NSString *channel`](#channel)  
See: [PubNub Channels](https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-)  
Name of channel which is used internally by [CENChatEngine](../chatengine) itself.   
Any chat with an identical channel will be able to communicate with one another.  


<br/><a id="connected"/>

[`@property BOOL connected`](#connected)  
Whether chat currently connected to the network.  


<br/><a id="hasconnected"/>

[`@property BOOL hasConnected`](#hasconnected)  
Whether client was able to connect to chat at least once.  


<br/><a id="isprivate"/>

[`@property (getter=isPrivate) BOOL private`](#isprivate)  
Whether chat publicly available or require owner's authorization to join to it via  
[CENChat.invite](#invite).  


<br/><a id="meta"/>

[`@property NSDictionary *meta`](#meta)  
Chat metadata persisted on the server.  
Useful for storing things like the name and description. Call [CENChat.update](#update) to update 

**Note:** To enabled meta information synchronization, make sure to enable it with 
[CENConfiguration.enableMeta](../configuration#enablemeta).  


<br/><a id="name"/>

[`@property NSString *name`](#name)  
Name of channel which has been passed during instance initialization.  


<br/><a id="users"/>

[`@property NSDictionary<NSString *, CENUser *> *users`](#users)  
List of users in this chat.  
Automatically kept in sync as users join and leave the chat. Use 
[$.online.join](../chat#event-online-join) and related events to get notified when this 
changes.  

**Note:** Fetches the list of online users, and not all the users that are part of a chat. 
The aggregated list of users will have to maintained by you in your project.


## Methods

<a id="connect"/>

[`connect()`](#connect)  
Connect [local user](../me) to [PubNub](https://pubnub.com) real-time network to receive 
updates from other [chat](../chat) participants.

### Returns:

[Receiver](../chat) which can be used to chain other methods call. 

### Fires:

* [$.connected](#event-connected)
* [$.error.auth](#event-error-auth)
* [$.error.connection.duplicate](#event-error-connection-duplicate)


### Example

```objc
// Create new chat room, but don't connect to it automatically.
CENChat *chat = self.client.Chat().name(@"some-chat").autoConnect(NO).create();

// Connect to the chat when we feel like it.
chat.connect();
```


<br/><br/><a id="emit"/>

[`emit(NSString *).data(NSDictionary *).perform()`](#emit)    
Emit `event` using specified parameters.  
Events are triggered over the network and all events are made on behalf of 
[local user](../me).

### Parameters:

| Name    | Type           | Attributes | Default | Description        |
|:-------:|:--------------:|:----------:|:-------:| ------------------ |  
| `event` | NSString *     |  Required  |         | The `event` name.  |   
| `data`  | NSDictionary * |            | `nil`   | The event payload. |   

**Note:** Builder parameters can be specified in different variations depending from needs.

### Returns:

[Event](../event) which allow to track emitting progress.

### Example

```objc
// Emit event by one user.
self.chat.emit(@"custom-event").data(@{ @"value": @YES }).perform();

// Handle event on another side.
self.chat.on(@"custom-event", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    CENUser *sender = payload[CENEventData.sender];
    
    NSLog(@"%@ emitted the value: %@", sender.uuid, 
          payload[CENEventData.data][@"message"]);
});
```


<br/><br/><a id="extension"/>

[`extension(id plugin)`](#extension)  
Inherited from: [CENObject.extension](../object#extension)  
Access receiver's interface extensions.


<br/><br/><a id="fetchuserupdates"/>

[`fetchUserUpdates(void)`](#fetchuserupdates)  
Retrieve list of [users](../user) in [chat](../chat).

### Returns:

[Receiver](../chat) which can be used to chain other methods call. 

### Fires:

* [$.error.presence](#event-error-presence)
* [$.online.here](#event-online-here)
* [$.online.join](#event-online-join)

### Example

```objc
self.chat.fetchUserUpdates();
```


<br/><br/><a id="invite"/>

[`invite(CENUser *user)`](#invite)  
Invite a [user](../user) to this [chat](../chat).  
Authorizes the invited user in the [chat](../chat) and sends them an invite via 
[CENUser.direct](../user#direct) chat.  

### Parameters:  

| Name   | Type                        | Attributes | Description |
|:------:|:---------------------------:|:----------:| ----------- |  
| `user` | [CENUser](../user) * |  Required  | [User](../user) which should be invited. | 

### Returns:

[Receiver](../chat) which can be used to chain other methods call.  

### Fires:

* [$.error.auth](#event-error-auth)
* [$.invite](../me#event-invite)

### Example

```objc
// One of user running ChatEngine.
CENChat *secretChat = self.client.Chat().name(@"secret-chat").create();
secretChat.invite(anotherUser);

// Another user listens for invitations.
self.client.me.direct.on(@"$.invite", ^(CENEmittedEvent *event) {
    NSDictionary *payload = ((NSDictionary *)event.data)[CENEventData.data];

    CENChat *secretChat = self.client.Chat().name(payload[@"channel"]).create();
});
```


<br/><br/><a id="leave"/>

[`leave()`](#leave)  
Leave from the [chat](../chat) on behalf of [local user](../me) and stop receiving events.  

### Returns:

[Receiver](../chat) which can be used to chain other methods call.    

### Fires:

* [$.disconnected](#event-diconnected)
* [$.error.leave](#event-error-leave)
* [$.left](#event-left)

### Example

```objc
// Create new chat for local user to participate in.
CENChat *chat = self.client.Chat().name(@"test-chat").create();

// Leave chat when there is no more any need to be participant of it.
chat.leave();
```


<br/><br/><a id="objectify"/>

[`objectify()`](#objectify)  
Serialize [chat](../chat) instance into dictionary.   

### Returns:

`NSDictionary` with publicly visible chat data.  

### Example

```objc
CENChat *chat = self.client.Chat().name(@"test-chat").get();

NSLog(@"Chat dictionary representation: %@", chat.objectify());
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

Stop specific event handling.
```objc
self.messageHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle remote user emitted event payload.
};

self.chat.off(@"message", self.messageHandlingBlock);
```

Stop multiple events handling.
```objc
self.errorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any emitted error.
};

self.chat.off(@"$.error.*", self.errorHandlingBlock);
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

```objc
self.anyEventHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any event emitted by object.
};

self.chat.offAny(self.anyEventHandlingBlock);
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
CENChat *chat = self.client.Chat().name(@"test-chat").create()
    .on(@"$.connected", ^(CENEmittedEvent *event) {
        // Handle connection to chat real-time channel.
    });
```

Handle multiple events using wildcard.
```objc
self.client.me.on(@"$.error.*", ^(CENEmittedEvent *event) {
    // Handle any emitted error.
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

```objc
CENChat *chat = self.client.Chat().name(@"test-chat").create()
    .onAny(^(CENEmittedEvent *event) {
        // Handle any event emitted by object.
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
CENChat *chat = self.client.Chat().name(@"test-chat").create()
    .once(@"$.state", ^(CENEmittedEvent *event) {
        // Handle once user's state change for chat.
    });
```

Handle one of multiple events once using wildcard.
```objc
CENChat *chat = self.client.Chat().name(@"test-chat").create()
    .once(@"$.online.*", ^(CENEmittedEvent *event) {
        // Handle once remote user join or list refresh.
    })
    .once(@"$.offline.*", ^(CENEmittedEvent *event) {
        // Handle once remote user leave or offline events.
    });
```


<br/><br/><a id="plugin-exists"/>

[`plugin(id).exists()`](#plugin-exists)  
Inherited From: [CENObject.plugin](../object#plugin-exists)  
Check whether plugin exists using specified parameters.  
 

<br/><br/><a id="plugin-remove"/>

[`plugin(id).remove()`](#plugin-remove)  
Inherited From: [CENObject.plugin](../object#plugin-remove)  
Remove plugin using specified parameters.  
 

<br/><br/><a id="plugin-store"/>

[`plugin(id).identifier(NSString *).configuration(NSDictionary *).store()`](#plugin-store)  
Inherited From: [CENObject.plugin](../object#plugin-store)  
Create plugin using specified parameters.  


<br/><br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)  
Inherited from: [CENEventEmitter.removeAll](../emitter#removeall)  
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  

### Parameters:

| Name    | Type       | Attributes | Description     |
|:-------:|:----------:|:----------:| --------------- |
| `event` | NSString * |  Required  | Name of event for which has been used to register handler blocks. | 

### Returns:

[Receiver](../chat) which can be used to chain other methods call.  

### Example

Remove specific event handlers
```objc
self.chat.removeAll(@"message");
```

Remove multiple event handlers
```objc
self.chat.removeAll(@"$.error.*");
```


<br/><br/><a id="search"/>

[`search().event(NSString *).sender(CENUser *).limit(NSInteger).pages(NSInteger).count(NSInteger).start(NSNumber *).end(NSNumber *).create()`](#search)
Create events [searcher](../search) using specified parameters which act as `AND` operators.

### Parameters:

| Name     | Type                        | Attributes | Default | Description |
|:--------:|:---------------------------:|:----------:|:-------:| ----------- |
| `event`  | NSString *                  |  |  `nil`  | The [event](../event) name to search for. |  
| `sender` | [CENUser](../user) * |  |  `nil`  | The [user](../user) who sent the message. |  
| `limit`  | NSInteger                   |  |   `20`  | The maximum number of results to return that match search criteria. Search will continue operating until it returns this number of results or it reached the end of history. Limit will be ignored in case if both `start` and `end` timetokens has been passed to search configuration. |  
| `pages`  | NSInteger                   |  |   `10`  | Maximum number of search request which can be performed to reach specified search end criteria: `limit`. |  
| `count`  | NSInteger                   |  |  `100`  | Maximum number of events returned with single search request. |  
| `start`  | NSNumber *                  |  |   `0`   | The timetoken to begin searching between. |  
| `end`    | NSNumber *                  |  |   `0`   | The timetoken to end searching between. |  

**Note:** Builder parameters can be specified in different variations depending from needs.

### Returns:

[Chat](../chat) events [searcher](../search) instance which will emit all old events 
unless `event` is supplied.

### Fires:

* [$.error.search](../chat#event-error-search)

### Example

```objc
self.chat.search().create()
    .on(@"my-custom-event", ^(CENEmittedEvent *event) {
        NSLog(@"This is an old event!: %@", event.data);
    })
    .on(@"$.search.finish", ^(CENEmittedEvent *event) {
        NSLog(@"We have all our results!");
    }).search();
```


<br/><br/><a id="update"/>

[`update(NSDictionary *meta)`](#update)  
Update the [chat](../chat) meta information on server.

### Parameters:

| Name   | Type           | Attributes | Default | Description |
|:------:|:--------------:|:----------:|:-------:| ----------- |
| `meta` | NSDictionary * |  | `nil`   | `NSDictionary` with metadata which should be bound to [chat](../chat). |  

### Returns:

[Receiver](../chat) which can be used to chain other methods call.  

### Fires:

* [$.error.chat](../chat#event-error-search)

### Example

```objc
self.chat.update(@{ @"title": @"Chat title" });
```


## Events

<a id="event-connected"/>

[`$.connected`](#event-connected)  
Notify locally what [chat](#../chat) has been connected to the network.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.connected`               | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `nil`                       | `$.connected` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.chat.on(@"$.connected", ^(CENEmittedEvent *event) {
    NSLog(@"Chat is ready to go!");
});
```  

<br/><br/><a id="event-created-chat"/>

[`$.created.chat`](#event-created-chat)  
Notify locally when [chat](#../chat) has been created within 
[CENChatEngine](../chatengine).

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.created.chat`            | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. |
| `data`    | id         | `nil`                       | `$.created.chat` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.client.on(@"$.created.chat", ^(CENEmittedEvent *event) {
    CENChat *chat = event.emitter;
    
    NSLog(@"Chat was created: %@", chat);
});
```


<br/><br/><a id="event-disconnected"/>

[`$.disconnected`](#event-disconnected)  
Notify locally what [chat](#../chat) has been disconnected from the network.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.disconnected`            | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `nil`                       | `$.disconnected` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.chat.on(@"$.disconnected", ^(CENEmittedEvent *event) {
    NSLog(@"Chat has been disconnected.");
});
```


<br/><br/><a id="event-error-auth"/>

[`$.error.auth`](#event-error-auth)  
Notify locally what [chat](#../chat) _handshake_ did fail .

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.error.auth`              | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `NSError *`                 | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.chat.once(@"$.error.auth", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
                                                    
    NSLog(@"Don't have enough access permissions: %@", error);
}).invite(otherUser);
```


<br/><br/><a id="event-error-chat"/>

[`$.error.chat`](#event-error-chat)  
Notify locally what there was a problem during actions or access to [chat](#../chat) data.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.error.chat`              | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `NSError *`                 | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.chat.once(@"$.error.chat", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
    
    NSLog(@"Unable to change chat metadata: %@", error);
}).update(@{ @"title": @"Chat title" });
```


<br/><br/><a id="event-error-connection-duplicate"/>

[`$.error.connection.duplicate`](#event-error-connection-duplicate)  
Notify locally what [connect()](../chat#connect) called on [connected](#connected) instance.

### Properties:

| Name      | Type       |  Value                         | Description |
|:---------:|:----------:|:------------------------------:| ----------- |
| `event`   | NSString * | `$.error.connection.duplicate` | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) *    | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `NSError *`                    | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
// Create auto-connected chat.
self.chat = self.client.Chat().name(@"public-chat").create();

// Some time later call
self.chat.on(@"$.error.connection.duplicate", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
        
    NSLog(@"Chat already connected: %@", error);
}).connect();
```


<br/><br/><a id="event-error-leave"/>

[`$.error.leave`](#event-error-leave)  
Notify locally what there was a problem during [chat](#../chat) leave process.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.error.leave`             | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `NSError *`                 | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.chat.once(@"$.error.leave", ^(CENEmittedEvent *event) {
    NSError *error = event.data;

    NSLog(@"Unable to leave chat: %@", error);
}).leave();
```


<br/><br/><a id="event-error-presence"/>

[`$.error.presence`](#event-error-presence)  
Notify locally what there was a problem fetching the presence of this [chat](#../chat).

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.error.presence`          | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `NSError *`                 | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.chat.once(@"$.error.presence", ^(CENEmittedEvent *event) {
    NSError *error = event.data;

    NSLog(@"Presence information fetch did fail: %@", error);
}).fetchUserUpdates();
```


<br/><br/><a id="event-error-search"/>

[`$.error.search`](#event-error-search)  
Notify locally what there was a problem fetching the history of this [chat](#../chat).

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.error.search`            | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `NSError *`                 | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.chat.search().limit(3).create()
    .once(@"$.error.search", ^(CENEmittedEvent *event) {
        NSError *error = event.data;

        NSLog(@"Search did fail: %@", error);
    }).search();
```


<br/><br/><a id="event-left"/>

[`$.left`](#event-left)  
Notify locally when [local user](../me) left this [chat](../chat).

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.left`                    | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | `nil`                       | `$.left` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.chat.once(@"$.left", ^(CENEmittedEvent *event) {
    NSLog(@"Left chat.");
}).leave();
```


<br/><br/><a id="event-offline-disconnect"/>

[`$.offline.disconnect`](#event-offline-disconnect)  
Notify locally when remote [user](../user) looses network connection to this 
[chat](../chat) involuntarily.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.offline.disconnect`      | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | [CENUser](../user) * | The [user](../user) that disconnected. |

### Example

```objc
chat.on(@"$.offline.disconnect", ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    NSLog(@"'%@' disconnected from the network.", user.uuid);
});
```


<br/><br/><a id="event-offline-leave"/>

[`$.offline.leave`](#event-offline-leave)  
Notify locally when remote [user](../user) intentionally leaves a [chat](../chat).

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.offline.leave`           | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | [CENUser](../user) * | The [user](../user) that has left the room. |

### Example

```objc
chat.on(@"$.offline.leave", ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    NSLog(@"'%@' left the room manually.", user.uuid);
});
```


<br/><br/><a id="event-online-here"/>

[`$.online.here`](#event-online-here)  
Notify locally when remote [user](../user) has come online. This is when the framework 
already know this user.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.online.here`             | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | [CENUser](../user) * | The [user](../user) that came online. |

### Example

```objc
chat.on(@"$.online.here", ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    NSLog(@"'%@' has come online!", user.uuid);
});
```


<br/><br/><a id="event-online-join"/>

[`$.online.join`](#event-online-join)  
Notify locally when remote [user](../user) has come online. This is when the framework first 
learn of a user. This can be triggered by [PubNub](https://pubnub.com) `$.join` presence event, or 
other network events that notify the framework of a new user.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.online.join`             | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | [CENUser](../user) * | The [user](../user) that came online. |

### Example

```objc
chat.on(@"$.online.join", ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    NSLog(@"'%@' has joined the room!", user.uuid);
});
```


<br/><br/><a id="event-state"/>

[`$.state`](#event-state)  
Notify locally what remote [user](../user) did change his state.  
Only [global](../chatengine#chat-global) able to emit this kind of event.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.state`                   | Name of handled event. |
| `emitter` | id         | [CENChat](../chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../chat) emitted events. |
| `data`    | id         | [CENUser](../user) * | The [user](../user) which changed his state. |

### Example

```objc
self.chat.on(@"$.state", ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    NSLog(@"'%@' has changed state: %@", user.uuid, user.state);
});
```