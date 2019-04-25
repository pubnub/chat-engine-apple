# CENRandomUsernamePlugin

This plugin adds ability to set random name for [local](reference-me) user by update his state.  

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/RandomUsername'
```

Next we need to integrate it into project by running following command:
```
pod install
```  

Now we can import plugin into class which is responsible for work with [ChatEngine](reference-chatengine) client:
```objc
// Import plugin.
#import <CENChatEngine/CENGravatarPlugin.h>
```

### Configuration

Plugin provide pretty simple configuration options - name of key in user's [state](reference-user#state) where generated name will be stored. This option passed to plugin configuration under `CENRandomUsernameConfiguration.propertyName` key.  

Default configuration shown below:
```objc
@{
    CENRandomUsernameConfiguration.propertyName: @"username"
}
```

##### EXAMPLE

```objc
NSDictionary *configuration = @{
    CENRandomUsernameConfiguration.propertyName = @"innerAnimal"
};
```

With this configuration, plugin will store generated name in user's [state](reference-user#state) object under `innerAnimal` key.  

### Register plugin

Plugin can be registered only for [Me](reference-me) explicitly or implicitly by client when [Me](reference-me) will be created (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin using non-default [configuration](#configuration):  
```objc
NSDictionary *configuration = @{
    CENRandomUsernameConfiguration.propertyName = @"innerAnimal"
};

self.client.on(@"$.ready", ^(CENMe *me) {
    me.plugin([CENRandomUsernamePlugin class]).configuration(configuration).store();
});
```  

After registration, we can audit random name when client will be ready:  
```objc
self.client.once(@"$.ready", ^(CENMe *me) {
    NSLog(@"Username: %@", me.state[@"innerAnimal"]);
});
```  