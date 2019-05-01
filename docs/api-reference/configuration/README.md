# CENConfiguration

[CENChatEngine](../chatengine) client configuration.

## Properties

<a id="cipherkey"/>

[`@property NSString *cipherKey`](#cipherkey)  
Data encryption key.  
Key which is used to encrypt messages pushed to [PubNub](https://pubnub.com) service and decrypt 
received from [chats](../chat).  

<br/><br/><a id="debugevents"/>

[`@property (getter = shouldDebugEvents) BOOL debugEvents`](#debugevents)  
Whether [CENChatEngine](../chatengine) should print out all received events.  
Console will print out all events which has been emitted locally or by remote client.

**Default**: `NO`

<br/><br/><a id="enablemeta"/>

[`@property BOOL enableMeta`](#enablemeta)  
Whether created [chats](../chat) should fetch their meta information from 
[CENChatEngine](../chatengine) network or not.

**Default**: `NO`

<br/><br/><a id="functionendpoint"/>

[`@property NSString *functionEndpoint`](#functionendpoint)  
URI which should be used to access running \b PubNub Functions which is used as 
[CENChatEngine](../chatengine) back-end.  

**Default**: `https://pubsub.pubnub.com/v1/blocks/sub-key`

<br/><br/><a id="globalchannel"/>

[`@property NSString *globalChannel`](#globalchannel)  
Name of channel to which all has access.  
[CENChatEngine](../chatengine) has privacy settings which allow to make chats `public` or 
`private`.
`Public` chats can be accessed by anyone by their name. Global chat is special kind of chat to
which any [CENChatEngine](../chatengine) instance will subscribe automatically after
instantiation. This chat can be used for announcements or remote 
[CENChatEngine](../chatengine) clients reconfiguration (depends on how new message from it 
will be handled).

**Default**: `chat-engine`

<br/><br/><a id="presenceheartbeatinterval"/>

[`@property NSInteger presenceHeartbeatInterval`](#presenceheartbeatinterval)  
Number of seconds which is used by client to notify \b PubNub what user still active. 

**Note:** Value should be smaller then [presenceHeartbeatValue](#presenceheartbeatvalue) for better 
presence control.

**Default**: `0` seconds

<br/><br/><a id="presenceheartbeatvalue"/>

[`@property NSInteger presenceHeartbeatValue`](#presenceheartbeatvalue)  
Number of seconds which is used by server to track whether client still active or not.  
If within specified amount of time client won't notify server about it's presence, it will 'timeout' 
for rest of users.

**Note:** Value can't be smaller then `5` seconds or larger than `300` seconds and will be reset to 
it automatically.

**Default**: `300` seconds

<br/><br/><a id="publishkey"/>

[`@property NSString *publishKey`](#publishkey)  
Key which is used to publish data to chat(s).

**Note:** This key can be obtained on PubNub's administration [portal](https://admin.pubnub.com) 
after free registration.

<br/><br/><a id="subscribekey"/>

[`@property NSString *subscribeKey`](#subscribekey)  
Key which is used to connect and receive updates from chat(s).

**Note:** This key can be obtained on PubNub's administration [portal](https://admin.pubnub.com) 
after free registration.  

<br/><br/><a id="synchronizesession"/>

[`@property (getter = shouldSynchronizeSession) BOOL synchronizeSession`](#synchronizesession)  
Whether [user's](../me) session should be synchronized between owm devices or not.
With enabled synchronization, chats list change on [user's](../me) devices mobile, desktop) 
will be synchronized.

**Default**: `NO`

<br/><br/><a id="throwexceptions"/>

[`@property (getter = shouldThrowExceptions) BOOL throwExceptions`](#throwexceptions)  
Whether [CENChatEngine](../chatengine) should throw errors or not.

**Default**: `NO`


## Methods

<a id="constructor"/>

[`+ (instancetype)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey`](#constructor)  
Create and configure instance using minimal required data.

### Parameters:

| Name           | Type       | Attributes | Description |
|:--------------:|:----------:|:----------:| ----------- |  
| `publishKey`   | NSString * |  Required  | Key which allow client to publish data to chat(s). |  
| `subscribeKey` | NSString * |  Required  | Key which allow client to connect and receive updates from chat(s). |  