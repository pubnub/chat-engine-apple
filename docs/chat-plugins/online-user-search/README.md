# CENOnlineUserSearchPlugin

This plugin simplifies and automates the process of searching for currently online users.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/OnlineUserSearch'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENOnlineUserSearchPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for every created chat.
self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENOnlineUserSearchPlugin class]).store();
});
```

Setup with custom property name which should be used for search:
```objc
NSDictionary *configuration = @{
    CENOnlineUserSearchConfiguration.propertyName: @"state.firstName"
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENOnlineUserSearchPlugin class])
        .configuration(configuration).store();
});
```


### Parameters:

| Name            | Type       | Default | Description |
|:---------------:|:----------:|:-------:| ----------- |
| `caseSensitive` | BOOL       | `NO`    | Boolean which specify whether case-sensitive search should be used or not. |
| `propertyName`  | NSString * | `uuid`  | Name of property which should be used in search.<br/>It is possible to use [CENUser.uuid](../../api-reference/user#uuid) and also key-path for [CENUser.state](../../api-reference/user#state) property. |

Each parameter is _field_ inside of `CENOnlineUserSearchConfiguration` _typedef struct_.


## Methods

<a id="search">

[`+ (NSArray<CENUser *> *)search:(NSString *)criteria inChat:(CENChat *)chat`](#search)  
Search for [users](../../api-reference/user) using provided search criteria to look up for online users.

### Parameters:

| Name       | Type                        | Attributes | Description |
|:----------:|:---------------------------:|:----------:| ----------- |  
| `criteria` | NSString *                  |  Required  | String which should be checked in property specified under `CENOnlineUserSearchConfiguration.propertyName` key. |
| `chat`     | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) for which search should be done. |

### Returns:

List of [users](../../api-reference/user) which conform to search criteria.

### Example

```objc
NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"bob" inChat:chat];

NSLog(@"Found %@ users which has 'bob' in their UUID or state", @(users.count));
```