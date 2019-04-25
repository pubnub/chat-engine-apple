# CENPushNotifications

This plugin adds ability to enable / disable push notifications on particular [Chat](reference-chat)s and push payload configuration. 

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/PushNotifications'
```

Next we need to integrate it into project by running following command:
```
pod install
```  

Now we can import plugin into class which is responsible for work with [ChatEngine](reference-chatengine) client:
```objc
// Import plugin.
#import <CENChatEngine/CENPushNotificationsPlugin.h>
```

### Configuration

Plugin can be instructed with information about `events` for which should trigger configured payload `formatter` which will provide payload for each of specified push notification `services`.  

Configuration dictionary root may contain data under keys specified in `CENPushNotificationsConfiguration` typedef described [here](reference-push-notifications-configuration).  

Default configuration shown below:
```objc
@{
    CENPushNotificationsConfiguration.events: [@"$notifications.seen"]
}
```

##### EXAMPLE

```objc
NSDictionary * (^formatter)(NSDictionary *payload) = ^NSDictionary * (NSDictionary *payload) {
    NSDictionary *payload = nil;
    if ([payload[CENEventData.event] isEqualToString:@"message"]) {
        NSString *chatName = ((CENChat *)payload[CENEventData.chat]).name;
        NSString *title = [NSString stringWithFormat:@"%@ sent message in %@", payload[CENEventData.sender], chatName];
        NSString *body = cePayload[CENEventData.data][@"message"] ?: cePayload[CENEventData.data][@"text"];
        payload = @{ CENPushNotificationsService.apns: @{ @"aps": @{ @"alert": @{ @"title": title, @"body": body} } };
    } else if ([payload[CENEventData.event] isEqualToString:@"ignoreMe"]) {
        // Create empty payload to ensure what push notification won't be truggered.
        payload = @{};
    } 
    
    return payload;
};

NSDictionary *configuration = @{
    CENPushNotificationsConfiguration.events: [@"message", @"$.invite"],
    CENPushNotificationsConfiguration.formatter: formatter,
    CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns]
};
```
With this configuration, plugin will pre-format payload to include push notification payload for Apple Push Notification Service each time when `message` event emitted. For `$.invite` formatter return _nil_ and plugin willo construct default payload content for invitation notification.    
[ChatEngine](reference-chatengine) support APNS and GCM/FCM push notification services. Please see [this](https://www.pubnub.com/docs/ios-objective-c/mobile-gateway#Formatting_your_messages_for_receipt_on_associated_devices) manual to see what should be placed under `pn_apns` (represented by [apns](reference-push-notifications-service#service-apns)) and `gcm`  (represented by [fcm](reference-push-notifications-service#service-gcm)).

### Register plugin

Plugin can be registered only for [Me](reference-me) explicitly or implicitly by client when [Me](reference-me) will be created (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin using non-default [configuration](#configuration):  
```objc
NSDictionary * (^formatter)(NSDictionary *payload) = ^NSDictionary * (NSDictionary *payload) {
    NSDictionary *payload = nil;
    if ([payload[CENEventData.event] isEqualToString:@"message"]) {
        NSString *chatName = ((CENChat *)payload[CENEventData.chat]).name;
        NSString *title = [NSString stringWithFormat:@"%@ sent message in %@", payload[CENEventData.sender], chatName];
        NSString *body = cePayload[CENEventData.data][@"message"] ?: cePayload[CENEventData.data][@"text"];
        payload = @{ CENPushNotificationsService.apns: @{ @"aps": @{ @"alert": @{ @"title": title, @"body": body} } };
    } else if ([payload[CENEventData.event] isEqualToString:@"ignoreMe"]) {
        // Create empty payload to ensure what push notification won't be truggered.
        payload = @{};
    } 
    
    return payload;
};

NSDictionary *configuration = @{
    CENPushNotificationsConfiguration.events: [@"message", @"$.invite"],
    CENPushNotificationsConfiguration.formatter: formatter,
    CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns]
};

self.client.on(@"$.ready", ^(CENMe *me) {
    me.plugin([CENPushNotificationsPlugin class]).configuration(configuration).store();
});
```  


### Methods

`CENPushNotificationsPlugin` plugin has few helper class methods to manage it.  

<a id="enablepushnotifications">

[`+ (void)enablePushNotificationsForChats:(NSArray<CENChat *> *)chats withDeviceToken:(NSData *)token completion:(void(^)(NSError *error))block`](#enablepushnotifications)  
Enable push notifications on specified list of `chat`s.

##### PARAMETERS

| Name    | Type         | Description |
|:-------:|:------------:| ----------- |  
| `chats` | NSArray<[CENChat](reference-chat) *> | Reference on list of [Chat](reference-chat)s for which [ChatEngine](reference-chatengine) service should start remote notification triggering. |  
| `token` | NSData | Reference on device token which has been provided by APNS. |
| `block` | void(^)(NSError *error) | Reference on block which will be called at the end of registration process. Block pass only one argument - request processing error (if any error happened during request). |    

<br/><a id="disablepushnotifications">

[`+ (void)disablePushNotificationsForChats:(NSArray<CENChat *> *)chats withDeviceToken:(NSData *)token completion:(void(^)(NSError *error))block`](#disablepushnotifications)  
Disable push notifications on specified list of `chat`s.  

##### PARAMETERS

| Name    | Type         | Description |
|:-------:|:------------:| ----------- |  
| `chats` | NSArray<[CENChat](reference-chat) *> | Reference on list of [Chat](reference-chat)s for which [ChatEngine](reference-chatengine) service should stop remote notification triggering. |  
| `token` | NSData | Reference on device token which has been provided by APNS. |
| `block` | void(^)(NSError *error) | Reference on block which will be called at the end of unregister process. Block pass only one argument - request processing error (if any error happened during request). |  

<br/><a id="disableallpushnotifications">

[`+ (void)disableAllPushNotificationsForUser:(CENMe *)user withDeviceToken:(NSData *)token completion:(void(^)(NSError *error))block`](#disableallpushnotifications)  
Disable all push notifications for specified user.

##### PARAMETERS

| Name    | Type         | Description |
|:-------:|:------------:| ----------- |  
| `user` | [CENMe](reference-me) | Reference on [local](reference-me) [ChatEngine](reference-chatengine) user for which notifications should be disabled. |  
| `token` | NSData | Reference on device token which has been provided by APNS. |
| `block` | void(^)(NSError *error) | Reference on block which will be called at the end of unregister process. Block pass only one argument - request processing error (if any error happened during request). |  