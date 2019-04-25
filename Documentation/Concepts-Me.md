To authorize this client as a ChatEngine User, use the `connect` method.  
```objc
self.client.connect(@"serhii").perform();
```

This connects to the PubNub Data Stream network on behalf of the device running this code. 

### ChatEngine.connect()

The method connects to [ChatEngine.global](reference-chategnine#global-chat). The parameter `serhii` is a unique identifier for the new [User](reference-user).  
When ChatEngine has been connected, a fancy [Me](reference-me) object is returned by the [$.ready](reference-chatengine#event-ready) event.  
```objc
self.client.on(@"$.ready", ^(CENMe *me) {
    // Now me can be used.
});
```

At this point the [Me](reference-me) object is fully usable:  
```objc
me.update(@{ @"lastOnline": [NSDate date] });
```  

See [Users and State](concepts-users-and-state) for more information on [Me.update](reference-me#update).  

### Usernames

In order to give every user a unique name, let's create a function that returns a random animal.  
```objc
- (NSString *)username {
  NSArray<NString *> *animals = @[@"pigeon", @"seagull", @"bat", @"owl", @"sparrows", @"robin", @"bluebird", @"cardinal"];

  return animals[(arc4random() % animals.count)];
}
```  

We can call `-username` to get a random animal name. This will be our new username.  
Remember when we defined [Me](reference-me) and supplied `serhii` as the first parameter of [ChatEngine.connect](reference-chategnine#connect)? Well, we can supply whatever we want to use as the [User](reference-user) identifier there. Let's use our new method!  

```objc
self.client.connect([self username]).perform();
```  

Now every time we launch application or open chat controller, we'll have a different username.

![chat window](https://www.pubnub.com/sites/default/files/images/chatengine/online-status.png)
