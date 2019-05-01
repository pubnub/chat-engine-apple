## Connect to ChatEngine

The [CENChatEngine.connect](../../api-reference/chatengine#connect) method allows you to connect to 
ChatEngine with a `uuid` that uniquely identifies the [user](../../api-reference/user).

```objc
self.client.connect(@"john").perform();
```

### Listen to $.ready event

A [$.ready](../../api-reference/chatengine#event-ready) event is triggered when a user is 
successfully connected to ChatEngine. The event includes a [local user](../../api-reference/me) 
object that represents the [user](../../api-reference/user) that has been connected.

```objc
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    CENMe *me = event.data;
    
    NSLog(@"Connected as: %@", me.uuid);
});
```

When the user connects to ChatEngine, it joins a global chat accessed via 
[CENChatEngine.global](../../api-reference/chatengine#chat-global). The user also automatically 
joins its own direct chat called [CENMe.direct](../../api-reference/me#direct) and feed chat called 
[CENMe.feed](../../api-reference/me#feed).   
Refer to [Channel Topology](../../advanced-concepts/pubnub-channel-topology).

See [CENChatEngine.connect](../../api-reference/chatengine#connect) for more information.


## Set User State

The [CENChatEngine.connect](../../api-reference/chatengine#connect) method also allows you to 
include a user `state` object that can be shared with other users on the platform. State is stored 
in PubNub. 
Username, location or avatar are examples of information that could be included in the state object.
The contents of the state object has no special meaning to ChatEngine or PubNub.

```objc
self.client.connect(@"john").state(@{
    @"name": @"John Doe", 
    @"team": @"red"
}).perform();
```

### Listen to $.state event

A `$.state` event is triggered to all users in the `global` chat room if a user connects with a user
state.

```objc
self.client.global.on('$.state', ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    NSLog(@"'%@' state is set to: %@", user.uuid, user.state);
});
```


## Update User State

You can update state for [local user](../../api-reference/me) object by calling the 
[CENMe.update](../../api-reference/me#update) method. When you update user state, another 
[`$.state`](../../api-reference/chat#event-state) event is triggered to other users in the global 
chat room.

```objc
self.client.me.update(@{
    @"name": @"John Doe", 
    @"team": @"green"
});
```