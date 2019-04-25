# CENUnreadMessagesPlugin

This plugin adds ability to send updated on whether new event has been sent to `inactive` chat.  

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/UnreadMessages'
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

Plugin provide pretty simple configuration options - list of event names for which plugin will count unread messages (when chat `inactive`). This option passed to plugin configuration under `CENUnreadMessagesConfiguration.events` key.  

Default configuration shown below:
```objc
@{
    CENUnreadMessagesConfiguration.events: @[@"message"]
}
```

##### EXAMPLE

```objc
NSDictionary *configuration = @{
    CENUnreadMessagesConfiguration.events: @[@"ping", @"pong", @"message"]
};
```

With this configuration, plugin will count only next events: `ping`, `pong` and `messages` and ignore unknown (for example `alert`).  

### Register plugin

Plugin can be registered for specific [Chat](reference-chat) instance or for all [Chat](reference-chat) instances created by client (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin for [global](reference-chatengine#global) chat for simplicity with some non-default [configuration](#configuration):  
```objc
NSDictionary *configuration = @{
    CENUnreadMessagesConfiguration.events: @[@"ping", @"pong", @"message"]
};

self.client.on(@"$.ready", ^(CENMe *me) {
    self.client.global.plugin([CENUnreadMessagesPlugin class])
        .configuration(configuration).store();
});
```  

After registration, we can listen for unread messages count change:  
```objc
self.client.global.on(@"$unread", ^(NSDictionary *payload) {
    CENChat *chat = payload[CENUnreadMessagesEvent.chat];
    NSString *event = payload[CENUnreadMessagesEvent.event];
    NSNumber *count = payload[CENUnreadMessagesEvent.count];

    NSLog(@"'%@' received another '%@' event and now contain %@ unread messages.", chat.name, event, count);
});

// To mark chat as active, use following helper method.
[CENUnreadMessagesPlugin setChat:self.client.global active:YES];
```  

List of unread event payload described [here](reference-unread-messages-event). 

### Methods

`CENUnreadMessagesPlugin` plugin has few helper class methods to manage it.  

<a id="setactive">

[`+ (void)setChat:(CENChat *)chat active:(BOOL)isActive`](#setactive)  
Change current typing indicator state for specified `chat`.  

##### PARAMETERS

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `chat` | [CENChat](reference-chat) | | Reference on [Chat](reference-chat) instance for which activity state should be changed. |  
| `isActive` | BOOL | | Whether [Chat](reference-chat) currently active or not (whether `$unread` events should be generated). |  

<br/><a id="fetchunreadcountforchat">

[`+ (void)fetchUnreadCountForChat:(CENChat *)chat withCompletion:(void(^)(NSUInteger count))block`](#fetchunreadcountforchat)  
Retrieve information about current number of unseen messages in `chat`.  

##### PARAMETERS

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `chat` | [CENChat](reference-chat) | | Reference on [Chat](reference-chat) for which data fetch should be done. |  
| `block` | ^(NSUInteger count) | | Reference on fetch completion block. Block pass only one argument - number of unseen messages. |  