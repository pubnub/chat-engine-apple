# CENPushNotificationsConfiguration

[Push Notifications](plugins-push-notifications) plugin allow to configure set of options which described in `CENPushNotificationsConfiguration` typedef.  


<a id="configuration-events"/>

[`CENPushNotificationsConfiguration.events`](#configuration-events)  
Name of key under which stored list of event names for which plugin should be used to pre-format event payload for push notification service.

<a id="configuration-services"/>

[`CENPushNotificationsConfiguration.services`](#configuration-services)  
Name of key under which stored list of service names (from [CENPushNotificationsService](reference-push-notifications-service) fields) for which plugin should generate notification payload (to mark as _seen_ or if `formatter` missing or return _nil_).

<a id="configuration-formatter"/>

[`CENPushNotificationsConfiguration.formatter`](#configuration-formatter)  
Nme of key under which stored GCD block which should be used to provide custom payload format.  
Block signature example:  
```objc
^NSDictionary * (NSDictionary *payload) {
    return @{};
}
```  

Block will receive chat [event payload](concepts-event-payload) and should return dictionary where root elements stored on one (or both) of keys from [CENPushNotificationsService](reference-push-notifications-service). Value for each key should contain structure which is expected by corresponding push notification service provider (example can be seen [here](https://www.pubnub.com/docs/ios-objective-c/mobile-gateway#Formatting_your_messages_for_receipt_on_associated_devices)).  
If block returns empty dictionary, plugin won't generate push notification payload and trigger notification. _nil_ value for known events (plugin has default formatting logic for `message` and `$.invite` events) will cause default notifications payload creation.   