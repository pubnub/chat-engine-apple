ChatEngine supports full permissions based management supported by PubNub Access Manager.  

### Fresh

When you first set up your PubNub keys, all PubNub channels are locked down and nobody can read or write anything.  

### Authentication

When [ChatEngine.connect](reference-chatengine#connect) is called, it connects to PubNub functions and authorizes the user to access all public channels, and their own channels.  
```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"YOUR_PUB_KEY" 
                                                                   subscribeKey:@"YOUR_SUB_KEY"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
self.client.connect(username).authKey(@"YOUR_AUTH_KEY").perform();
```

It authorizes PubNub Access Manager permissions for the supplied authentication key on all read and write channels. See [PubNub Channel Topology](concepts-pubnub-channel-topology).  
`YOUR_AUTH_KEY` is typically a session based token that should be cycled frequently. Providing a consistent `auth key` is not recommended.  

### Successful Authentication

When the endpoint responds and ChatEngine successfully connects to PubNub, [ChatEngine](reference-chatengine) emits the `$.ready` event.  

### Authentication Failure

If the authentication call fails, [ChatEngine](reference-chatengine) emits `$.error.auth`.

If the call is successful but [ChatEngine](reference-chatengine) can not connect to PubNub, [ChatEngine](reference-chatengine) will emit a `$.network.down.*` event.

See [Private Chats](concepts-private-chats) for more information about how to utilize secure private chats.  

### Editing Authentication Policy

* Navigate to the [PubNub Admin Portal](https://admin.pubnub.com).
* Find your ChatEngine app.
* Locate the ChatEngine PubNub Functions.
* Edit the `authenticationPolicy()` code within the `chat-engine-server`.