# CENGravatarPlugin

This plugin adds ability to get Gravatars basing on [local](reference-me) user `email` address and update his state.  

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/Gravatar'
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

Plugin can be instructed with information about location of `email` in user's `state` and where gravitas URL should be stored in `state`.  

Configuration dictionary root may contain data under keys specified in `CENGravatarPluginConfiguration` typedef described [here](reference-gravatar-configuration).  

Default configuration shown below:
```objc
@{
    CENGravatarPluginConfiguration.emailKey: @"email",
    CENGravatarPluginConfiguration.gravatarURLKey: @"gravatar"
}
```

##### EXAMPLE

```objc
NSDictionary *configuration = @{
    CENGravatarPluginConfiguration.gravatarURLKey: @"imgURL"
};
```

With this configuration, plugin will store Garavatar URL in user's [state](reference-user#state) object under `imgURL` key.  

### Register plugin

Plugin can be registered only for [Me](reference-me) explicitly or implicitly by client when [Me](reference-me) will be created (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin using non-default [configuration](#configuration):  
```objc
NSDictionary *configuration = @{
    CENGravatarPluginConfiguration.gravatarURLKey: @"imgURL"
};

self.client.on(@"$.ready", ^(CENMe *me) {
    me.plugin([CENGravatarPlugin class]).configuration(configuration).store();
});
```  

After registration, we can listen for state change events and audit for `imgURL` key in users' state:  
```objc
self.client.on(@"$.state", ^(CENUser *user) {
    if (user.state[@"imgURL"]) {
        NSLog(@"'%@' profile image can be downloaded here: %@", user.uuid, user.state[@"imgURL"]);
    }
});

```  

Also, plugin automatically refresh Gravatar URL in case, if user change his `email` address in [state](reference-user#state).  