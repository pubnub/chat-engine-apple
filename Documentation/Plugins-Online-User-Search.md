# CENOnlineUserSearchPlugin

This plugin adds ability to get list of users which conform to search criteria in chat.  

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/OnlineUserSearch'
```

Next we need to integrate it into project by running following command:
```
pod install
```  

Now we can import plugin into class which is responsible for work with [ChatEngine](reference-chatengine) client:
```objc
// Import plugin.
#import <CENChatEngine/CENUnreadMessagesPlugin.h>
```

### Configuration

Plugin can be instructed with information about location of value (which will be matched against search request) in user's `state` and whether search should be case-sensitive or not.  

Configuration dictionary root may contain data under keys specified in `CENOnlineUserSearchConfiguration` typedef described [here](reference-online-search-configuration).  

Default configuration shown below:
```objc
@{
    CENOnlineUserSearchConfiguration.propertyName: @"uuid",
    CENOnlineUserSearchConfiguration.caseSensitive: @NO
}
```


##### EXAMPLE

```objc
NSDictionary *configuration = @{
    CENOnlineUserSearchConfiguration.propertyName: @"state.firstName"
};
```

With this configuration, plugin will use string stored in user's [state](reference-user#state) under `firstName` key.  

### Register plugin

Plugin can be registered for specific [Chat](reference-chat) instance or for all [Chat](reference-chat) instances created by client (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin for [global](reference-chatengine#global) chat for simplicity with some non-default [configuration](#configuration):  
```objc
NSDictionary *configuration = @{
    CENOnlineUserSearchConfiguration.propertyName: @"state.firstName"
};

self.client.on(@"$.ready", ^(CENMe *me) {
    self.client.global.plugin([CENOnlineUserSearchPlugin class])
        .configuration(configuration).store();
});
```  

After registration, we can search for users with specific _first name_:  
```objc
[CENOnlineUserSearchPlugin search:@"serhii" inChat:self.client.global 
                   withCompletion:^(NSArray<CENUser *> *users) {
    
    NSLog(@"%s users with 'serhii' as first name has been found.", users.count);
}];
```  

### Methods

`CENOnlineUserSearchPlugin` plugin has one helper class methods to manage it.  

<a id="search">

[`+ (void)search:(NSString *)criteria inChat:(CENChat *)chat withCompletion:(void(^)(NSArray<CENUser *> *))block`](#search)  
Search for user for which passed `criteria` will match to data which stored under [configured key](#configuration) in user's [state](reference-user#state) object.  

##### PARAMETERS

| Name    | Type         | Description |
|:-------:|:------------:| ----------- |  
| `criteria ` | NSString | Reference on string which should be used for match check with configured data in user's [state](reference-user#state) object. |  
| `chat` | [CENChat](reference-chat) | Reference on [Chat](reference-chat) instance inside of which participants should be filtered by `criteria`. |  
| `block` | ^(NSArray<CENUser *> *) | Search completion block. Block pass only one argument - list of [User](reference-user) instances which matched search `criteria`. |  