[ChatEngine](reference-chatengine) client configuration object. This instance allow to set values which allow to manage how client connect and communicate with PubNub network.  

<a id="constructor"/>

[`+ (instancetype)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey`](#constructor)  
Create and configure new [Configuration](reference-configuration) configuration instance.  

#### PARAMETERS

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `publishKey` | NSString | | Key which allow client to publish data to chat(s). |  
| `subscribeKey` | NSString | | Key which allow client to connect and receive updates from chat(s). |  

#### EXAMPLE

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" 
                                                                   subscribeKey:@"demo-36"];
```

### Properties

<a id="publishkey"/>

[`@property NSString *publishKey`](#publishkey)  
Key which is used to publish data to chat(s).

<br/><br/><a id="subscribekey"/>

[`@property NSString *subscribeKey`](#subscribekey)  
Key which is used to connect and receive updates from chat(s).

<br/><br/><a id="cipherkey"/>

[`@property NSString *cipherKey`](#cipherkey)  
Data encryption key which is used to encrypt messages pushed to PubNub service and decrypt messages received
from live feeds on which client subscribed at this moment.  

<br/><br/><a id="presenceheartbeatvalue"/>

[`@property NSInteger presenceHeartbeatValue`](#presenceheartbeatvalue)  
Number of seconds which is used by server to track whether client still online or time out.  

**Default**: 150 seconds

<br/><br/><a id="presenceheartbeatinterval"/>

[`@property NSInteger presenceHeartbeatInterval`](#presenceheartbeatinterval)  
Number of seconds which is used by server to track whether client still online or time out.  

**Default**: 120 seconds

<br/><br/><a id="functionendpoint"/>

[`@property NSString *functionEndpoint`](#functionendpoint)  
URI which should be used to access running PubNub Functions which act as ChatEngine back-end.  

**Default**: https://pubsub.pubnub.com/v1/blocks/sub-key

<br/><br/><a id="globalchannel"/>

[`@property NSString *globalChannel`](#globalchannel)  
Name of channel to which all has access.  

**Default**: `chat-engine`

<br/><br/><a id="synchronizesession"/>

[`@property (getter = shouldSynchronizeSession) BOOL synchronizeSession`](#synchronizesession)  
Whether user session should be synchronized between different devices or not.  
With enabled synchronization, all user devices (mobile, desktop) will be synchronized in part of active chats.  

**Default**: `NO`

<br/><br/><a id="enablemeta"/>

[`@property BOOL enableMeta`](#enablemeta)  
Whether created / synchronized (if enabled [synchronizeSession](reference-configuration#synchronizesession) chat instances should fetch meta information from [ChatEngine](reference-chatengine) network or not.

**Default**: `NO`

<br/><br/><a id="debugevents"/>

[`@property (getter = shouldDebugEvents) BOOL debugEvents`](#throwexceptions)  
Whether [ChatEngine](reference-chatengine) should enable debug for all emitted events or not.

**Default**: `NO`

<br/><br/><a id="throwexceptions"/>

[`@property (getter = shouldThrowExceptions) BOOL throwExceptions`](#throwexceptions)  
Whether [ChatEngine](reference-chatengine) should throw errors or not.

**Default**: `NO`
