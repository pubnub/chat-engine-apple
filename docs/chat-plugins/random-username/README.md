# CENRandomUsernamePlugin

Assigns a random username to new users.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/RandomUsername'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENRandomUsernamePlugin.h>
   ```

### Example

Setup with default configuration
```objc
// Register plugin for local user, only after CENChatEngine will create ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.me.plugin([CENRandomUsernamePlugin class]).store();
});
```

Setup with custom property name to which generated username will be stored
```objc
NSDictionary *configuration = @{
    CENRandomUsernameConfiguration.propertyName: @"innerAnimal"
};

// Register plugin for local user, only after CENChatEngine will create ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.me.plugin([CENRandomUsernamePlugin class])
        .configuration(configuration).store();
});
```

Access information added by plugin:
```objc
self.client.on(@"$.state",^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    if (user.state[@"innerAnimal"]) {
        NSLog(@"'%@' inner animal is: %@", user.uuid, user.state[@"innerAnimal"]);
    }
});
```


### Parameters:

| Name           | Type       | Default    | Description |
|:--------------:|:----------:|:----------:| ----------- |
| `propertyName` | NSString * | `username` | Key or key-path in user's [CENMe.state](../../api-reference/me#state) where username should be stored. |

Each parameter is _field_ inside of `CENRandomUsernameConfiguration` _typedef struct_. 