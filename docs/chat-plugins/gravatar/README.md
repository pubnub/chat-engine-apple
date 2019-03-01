# CENGravatarPlugin

Adds gravatars to users' state in PubNub ChatEngine.  
Also, plugin automatically refresh Gravatar URL in case, if user change his `email` address in 
[state](../../api-reference/user#state).


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/Gravatar'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENGravatarPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for local user, only after CENChatEngine will create ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.me.plugin([CENGravatarPlugin class]).store();
});
```

Setup with custom keys:
```objc
NSDictionary *configuration = @{
    CENGravatarPluginConfiguration.gravatarURLKey = @"profile.imgURL",
    CENGravatarPluginConfiguration.emailKey = @"contacts.email"
};

// Register plugin for local user, only after CENChatEngine will create ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.me.plugin([CENGravatarPlugin class])
        .configuration(configuration).store();
});
```

Access information added by plugin:
```objc
self.client.on(@"$.state",^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    
    if ([user.state valueForKeyPath:@"profile.imgURL"]) {
        NSLog(@"'%@' profile image can be downloaded here: %@", 
              user.uuid, [user.state valueForKeyPath:@"profile.imgURL"]);
    }
});
```


### Parameters:

| Name             | Type       | Default    | Description |
|:----------------:|:----------:|:----------:| ----------- |
| `emailKey`       | NSString * | `email`    | Key or key-path in user's [CENMe.state](../../api-reference/me#state) where email address is stored.|
| `gravatarURLKey` | NSString * | `gravatar` | Key or key-path in user's [CENMe.state](../../api-reference/me#state) where Gravatar URL should be stored.|

Each parameter is _field_ inside of `CENGravatarPluginConfiguration` _typedef struct_.  