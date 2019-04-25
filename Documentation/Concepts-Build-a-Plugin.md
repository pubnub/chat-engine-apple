Check out [markdown](plugins-markdown) and [typing indicator](plugins-typing-indicator) plugins for some examples of plugins.  

### What is Plugin?  

A plugin is set of classes which allow to augment ChatEngine objects functionality and data flow within.  

### Plugin Anatomy

Plugin package consist from two or three components (depending from plugin requirements): [plugin](#plugin), [extension](#extension) and [middleware](#middleware).  
The plugin system use subclass of [Plugin](reference-plugin) as entry point. This class using developer-available interface provide information which is required by plugin system to identify where and how plugin's package components should be used.  

<a id="plugin"/>

##### PLUGIN

After you create class which will be entry point, import corresponding header and use it as super class:  
```objc
#import <CENChatEngine/CEPPlugin.h>

@interface MyPlugin : CEPPlugin

@end
```

In your _MyPlugin_ implementation file import developer's category for plugin:  

```objc
#import <CENChatEngine/CEPPlugin+Developer.h>
```

Available methods from developer interface described [here](reference-plugin).

<a id="extension"/>

##### EXTENSION

After you create class which will one of extension included into plugin, import corresponding header and use it as super class:  
```objc
#import <CENChatEngine/CEPExtension.h>

@interface MyPluginExtension : CEPExtension

@end
```

In your _MyPluginExtension_ implementation file import developer's category for extension:  

```objc
#import <CENChatEngine/CEPExtension+Developer.h>
```

Available methods from developer interface described [here](reference-extension).

<a id="middleware"/>

##### MIDDLEWARE

After you create class which will one of middleware included into plugin, import corresponding header and use it as super class:  
```objc
#import <CENChatEngine/CEPMiddleware.h>

@interface MyPluginMiddleware : CEPMiddleware

@end
```

In your _MyPluginMiddleware_ implementation file import developer's category for extension:  

```objc
#import <CENChatEngine/CEPMiddleware+Developer.h>
```

Available methods from developer interface described [here](reference-middleware).