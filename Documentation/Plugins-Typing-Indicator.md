# CENTypingIndicatorPlugin

This plugin adds ability to send updated on whether user started / ended message input. For each kind of user's action plugin emit separate event: start (`$typingIndicator.startTyping`) and stop (`$typingIndicator.stopTyping`).   

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/TypingIndicator'
```

Next we need to integrate it into project by running following command:
```
pod install
```  

Now we can import plugin into class which is responsible for work with [ChatEngine](reference-chatengine) client:
```objc
// Import plugin.
#import <CENChatEngine/CENTypingIndicatorPlugin.h>
```

### Configuration

Plugin provide pretty simple configuration options - time after which plugin automatically send `$typingIndicator.stopTyping` event. This option passed to plugin configuration under `CENTypingIndicatorConfiguration.timeout` key.  

Default configuration shown below:
```objc
@{
    CENTypingIndicatorConfiguration.timeout: @(1.f)
}
```

##### EXAMPLE

```objc
NSDictionary *configuration = @{
    CENTypingIndicatorConfiguration.timeout: @(10.f)
};
```

In example above, if user stop typing, plugin automatically will send update after `10` seconds.

### Register plugin

Plugin can be registered for specific [Chat](reference-chat) instance or for all [Chat](reference-chat) instances created by client (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin for [global](reference-chatengine#global) chat for simplicity with some non-default [configuration](#configuration):  
```objc
NSDictionary *configuration = @{
    CENTypingIndicatorConfiguration.timeout: @(10.f)
};

self.client.on(@"$.ready", ^(CENMe *me) {
    self.client.global.plugin([CENTypingIndicatorPlugin class])
        .configuration(configuration).store();
});
```  

After registration, we can listen for typing indicator state change:  
```objc
self.client.global.on(@"$typingIndicator.startTyping", ^(NSDictionary *payload) {
    CENUser *user = payload[CENEventData.sender];
    CENChat *chat = payload[CENEventData.chat];

    NSLog(@"'%@' started typing in '%@'", user.uuid, chat.name);
});

// This handler will fire after 10 seconds because we didn't disabled typing indicator.
self.client.global.on(@"$typingIndicator.stopTyping", ^(NSDictionary *payload) {
    CENUser *user = payload[CENEventData.sender];
    CENChat *chat = payload[CENEventData.chat];

    NSLog(@"'%@' stopped typing in '%@'", user.uuid, chat.name);
});

// To change typing indicator state, plugin's helper methods can be used.
[CENTypingIndicatorPlugin setTyping:YES inChat:self.client.global];
```  

### Methods

`CENTypingIndicatorPlugin` plugin has few helper class methods to manage it.  

<a id="settyping">

[`+ (void)setTyping:(BOOL)isTyping inChat:(CENChat *)chat`](#settyping)  
Change current typing indicator state for specified `chat`.  

##### PARAMETERS

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `isTyping` | BOOL | | Whether [local](reference-me) user should send information about starting typing activity (`YES`) or stop (`NO`). |  
| `chat` | [CENChat](reference-chat) | | Reference on [Chat](reference-chat) instance for which typing indicator update should be sent. |  

<br/><a id="checkistypinginchat">

[`+ (void)checkIsTypingInChat:(CENChat *)chat withCompletion:(void(^)(BOOL isTyping))block`](#checkistypinginchat)  
Check whether typing indicator currently active in specified `chat` or not.  

##### PARAMETERS

| Name    | Type         | Attributes | Description |
|:-------:|:------------:|:----------:| ----------- |  
| `chat` | [CENChat](reference-chat) | | Reference on [Chat](reference-chat) for which check should be done. |  
| `block` | ^(BOOL isTyping) | | Reference on check completion block. Block pass only one argument - whether typing indicator active or not. |  