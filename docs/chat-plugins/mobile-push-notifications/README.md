# CENPushNotifications

This plugin adds ability to enable / disable push notifications on particular [Chat](../../api-reference/chat)s and push payload configuration.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/PushNotifications'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENPushNotificationsPlugin.h>
   ``` 

### Example

```objc
CENPushNotificationFormatterCallback formatter = ^NSDictionary * (NSDictionary *payload) {
    NSDictionary *payload = nil;
    if ([payload[CENEventData.event] isEqualToString:@"message"]) {
        NSString *chatName = ((CENChat *)payload[CENEventData.chat]).name;
        NSString *title = [NSString stringWithFormat:@"%@ sent message in %@", payload[CENEventData.sender], chatName];
        NSString *body = cePayload[CENEventData.data][@"message"] ?: cePayload[CENEventData.data][@"text"];
        payload = @{ CENPushNotificationsService.apns: @{ @"aps": @{ @"alert": @{ @"title": title, @"body": body} } };
    } else if ([payload[CENEventData.event] isEqualToString:@"ignoreMe"]) {
        // Create empty payload to ensure what push notification won't be triggered.
        payload = @{};
    } 
    
    return payload;
};

NSDictionary *configuration = @{
    CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns],
    CENPushNotificationsConfiguration.events: @[@"ping", @"message"],
    CENPushNotificationsConfiguration.formatter: formatter
};

// Register plugin for local user, when CENChatEngine will create it.
self.client.proto(@"Me", [CENPushNotificationsPlugin class])
    .configuration(configuration).store();

// or register plugin for local user, when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.me.plugin([CENPushNotificationsPlugin class])
        .configuration(configuration).store();
});
``` 


### Parameters:

| Name        | Type                                 | Default                      | Description |
|:-----------:|:------------------------------------:|:----------------------------:| ----------- |
| `debug`     | BOOL                                 | `NO`                         | Boolean which specify whether sent push notification should allow debugging with [PubNub Console](https://www.pubnub.com/docs/console) or not. |
| `events`    | NSArray<NSString *> *                | `@[@"message", @"$.invite"]` | List of event names which should trigger push notification payload composition before sending event. |
| `services`  | NSArray<NSString *> *                | `nil`                        | List of [service names](#pushnotificationservices) for which plugin should generate notification payload (to mark as `seen` or if `formatter` missing).<br/>Not required, if custom `formatter` take care of all required `events`.|
| `formatter` | CENPushNotificationFormatterCallback | `nil`                        | Block / closure which should be used to provide custom payload format.<br/><br/>Formatter expected to return dictionary where under [service names](#pushnotificationservices) stored data which should be sent to corresponding service.<br/>Remote notification won't be created if empty dictionary returned.<br/>Default formatter (only for `message` and `$.invite`) events will be used if `nil`returned from custom formatter. |

Each parameter is _field_ inside of `CENPushNotificationsConfiguration` _typedef struct_.  

<a id="pushnotificationservices">

`CENPushNotificationsService` _typedef struct_ has only two fields for which default formatter 
(for `message` and `$.invite` events) can generate push notifications payload:  
* `CENPushNotificationsService.apns`
* `CENPushNotificationsService.fcm`


## Methods

<a id="enablepushnotifications">

[`+ (void)enableForChats:(NSArray<CENChat *> *)chats withDeviceToken:(NSData *)token completion:(nullable CENPushNotificationCallback)block`](#enablepushnotifications)  
Enable push notifications on specified list of [chats](../../api-reference/chat).
  
**Note:** This method should be called at every application launch with received device push token.

### Parameters:

| Name    | Type                                   | Attributes | Description |
|:-------:|:--------------------------------------:|:----------:| ----------- |  
| `chats` | NSArray<[CENChat](../../api-reference/chat) *> * |  Required  | List of [chats](../../api-reference/chat) for which remote notification should be triggered. |  
| `token` | NSData *                               |  Required  | Device token which has been provided by APNS. |
| `block` | CENPushNotificationCallback            |            | Block / closure which will be called at the end of registration process and pass error (if any). |

### Example    

```objc
[CENPushNotificationsPlugin enableForChats:@[chat1, chat2] withDeviceToken:self.token
                               completion:^(NSError *error) {

        if (error) {
            NSLog(@"Request did fail with error: %@", error);
        }
    }];
}];
```


<br/><br/><a id="disablepushnotifications">

[`+ (void)disableForChats:(NSArray<CENChat *> *)chats withDeviceToken:(NSData *)token completion:(nullable CENPushNotificationCallback)block`](#disablepushnotifications)  
Disable push notifications on specified list of [chats](../../api-reference/chat).  

### Parameters:

| Name    | Type                                   | Attributes | Description |
|:-------:|:--------------------------------------:|:----------:| ----------- |  
| `chats` | NSArray<[CENChat](../../api-reference/chat) *> * |  Required  | List of [chats](../../api-reference/chat) for which remote notifications shouldn't be triggered. |  
| `token` | NSData *                               |  Required  | Device token which has been provided by APNS. |
| `block` | CENPushNotificationCallback            |            | Block / closure which will be called at the end of un-registration process and pass error (if any). |

### Example    

```objc
[CENPushNotificationsPlugin disableForChats:@[chat1, chat2] withDeviceToken:self.token
                                 completion:^(NSError *error) {

        if (error) {
            NSLog(@"Request did fail with error: %@", error);
        }
    }];
}];
```


<br/><br/><a id="disableallpushnotifications">

[`+ (void)disableAllForUser:(CENMe *)user withDeviceToken:(NSData *)token completion:(nullable CENPushNotificationCallback)block`](#disableallpushnotifications)
Disable all push notifications for [local user](../../api-reference/me).  

**Note:** It is good idea to call this method when user signs off.

### Parameters:

| Name    | Type                        | Attributes | Description |
|:-------:|:---------------------------:|:----------:| ----------- |  
| `user`  | [CENMe](../../api-reference/me) *     |  Required  | [Local user](../../api-reference/me) for which notifications should be disabled. |  
| `token` | NSData *                    |  Required  | Device token which has been provided by APNS. |
| `block` | CENPushNotificationCallback |            | Block / closure which will be called at the end of un-registration process and pass error (if any). |

### Example    

```objc
[CENPushNotificationsPlugin disableAllForUser:self.client.me withDeviceToken:self.token
                                   completion:^(NSError *error) {

        if (error) {
            NSLog(@"Request did fail with error: %@", error);
        }
    }];
}];
```


<br/><br/><a id="marknotificationasseen">

[`+ (void)markAsSeen:(NSNotification *)notification forUser:(CENMe *)user withCompletion:(nullable CENPushNotificationCallback)block`](#marknotificationasseen)
Try to hide notification from notification centers on another [local user](../../api-reference/me) devices.

### Parameters:

| Name           | Type                        | Attributes | Description |
|:--------------:|:---------------------------:|:----------:| ----------- |  
| `notification` | NSNotification *            |  Required  | Received remote notification which should be hidden. |  
| `user`         | [CENMe](../../api-reference/me) *     |  Required  | [Local user](../../api-reference/me) for which `notification` should be hidden on another devices. |
| `block`        | CENPushNotificationCallback |            | Block / closure which will be called at the end of process and pass error (if any). |

### Example    

```objc
[CENPushNotificationsPlugin markAsSeen:pushNotification forUser:self.client.me
                        withCompletion:^(NSError *error) {
                        
        if (error) {
            NSLog(@"Request did fail with error: %@", error);
        }
    }];
}];
```


<br/><br/><a id="markallnotificationsasseen">

[`+ (void)markAllAsSeenForUser:(CENMe *)user withCompletion:(nullable CENPushNotificationCallback)block`](#markallnotificationsasseen)
Try to hide notification from notification centers on another [local user](../../api-reference/me) devices.

### Parameters:

| Name    | Type                        | Attributes | Description |
|:-------:|:---------------------------:|:----------:| ----------- |    
| `user`  | [CENMe](../../api-reference/me) *     |  Required  | [Local user](../../api-reference/me) for which `notification` should be hidden on another devices. |
| `block` | CENPushNotificationCallback |            | Block / closure which will be called at the end of process and pass error (if any). |

### Example    

```objc
[CENPushNotificationsPlugin markAllAsSeenForUser:self.client.me
                                  withCompletion:^(NSError *error) {
                                  
        if (error) {
            NSLog(@"Request did fail with error: %@", error);
        }
    }];
}];
```