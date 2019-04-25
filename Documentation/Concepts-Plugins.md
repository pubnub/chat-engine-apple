### Adding Plugins

It's super easy to use plugins. Just import plugin as any other framework into your classes which use [ChatEngine](reference-chatengine).

ChatEngine provided plugins can be added through CocoaPods by adding corresponding _pod_ line into **Podfile**. In this example we will use [Unread messages](plugins-unread-messages) plugin as reference. First, add it into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/UnreadMessages'
```

Next we need to integrate it into project by running following command:
```
pod install
```  

Now we can import plugin into class which is responsible for work with [ChatEngine](reference-chatengine) client:
```objc
// Import plugin.
#import <CENChatEngine/CENUnreadMessagesPlugin.h>
```

### Register Plugins

Plugin should be registered with required [ChatEngine](reference-chatengine) client so it can be used.  
There is two ways to register plugin: [proto](#register-proto-section) and [object plugin](#register-object-plugin-section).  

All plugin middleware will be called in same order as their plugins have been registered with [ChatEngine](reference-chatengine).  

Plugins can be registered by their default identifier (which is set by developer) or using custom user-provided values.  
Custom identifiers may became helpful, when same plugin should be used on object with different configurations. Also different identifiers can be useful for plugin developers when their plugin depends on another's plugin extensions (custom identifier here will help to avoid collusion with plugins which may be used by another plugins or user on their own).   

<a id="register-proto-section"/>  

##### PROTO

Proto plugins registered for specific object type ([Chat](reference-chat), [User](reference-user), [Me](reference-me) or [Search](reference-search)) and allow [ChatEngine](reference-chatengine) client plugins system to bind specified plugin to each new instance of specified object type.  

<a id="register-proto"/>  

[`@property CENPluginsBuilderInterface * (^proto)(NSString *object, Class plugin)`](#register-proto)  
Property provide access to builder which allow register proto plugin. `store()` API will bind specified plugin to all objects of specified type.  

###### PARAMETERS

Next parameters can be passed to builder:  

| Name            | Type         | Attributes | Default                            | Description |
|:---------------:|:------------:|:----------:|:----------------------------------:| ----------- |
| `object`        | NSString     | | | Name of one of available [ChatEngine](reference-chatengine) objects: [Chat](reference-chat), [User](reference-user), [Me](reference-me) or [Search](reference-search) |  
| `plugin`        | Class        | | | Reference on class of plugin which should be registered. Plugin class should be subclass of [plugin](reference-plugin). |  
| `identifier`    | NSString     | optional | `Identifier provided by plugin developer` | Custom identifier under which initialized plugin will be stored and can be retrieved. |  
| `configuration` | NSDictionary | optional | | Reference on dictionary with plugin configuration (if required by plugin). |  

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).   

###### EXAMPLE

```objc
self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).store();
```

<a id="register-object-plugin-section"/>

##### OBJECT


Register plugin to work with specific object. Following object has interface which allow to register plugins: [Chat](reference-chat), [User](reference-user), [Me](reference-me) and [Search](reference-search).  

<a id="register-object-plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(Class plugin)`](#register-object-plugin)  
Property provide access to builder which allow register plugin for object. `store()` API will instantiate and bind plugin to caller object.  

###### PARAMETERS

Next parameters can be passed to builder:  

| Name            | Type         | Attributes | Default                            | Description |
|:---------------:|:------------:|:----------:|:----------------------------------:| ----------- |
| `plugin`        | Class        | | | Reference on class of plugin which should be registered. Plugin class should be subclass of [plugin](reference-plugin). |  
| `identifier`    | NSString     | optional | `Identifier provided by plugin developer` | Custom identifier under which initialized plugin will be stored and can be retrieved. |  
| `configuration` | NSDictionary | optional | | Reference on dictionary with plugin configuration (if required by plugin). |  

All `optional` parameters can be omitted from API call (API use builder pattern to provide flexibility).   

###### EXAMPLE

```objc
CENChat *chat = self.client.Chat().name(@"simple-chat").create();
chat.plugin([CENUnreadMessagesPlugin class]).store();
```

### Unregister Plugins

To stop plugin operation (middleware for example) it can be removed from specific object or all objects to which it has been added as proto plugin.  
There is two ways to unregister plugin: [proto](#unregister-proto-section) and [object plugin](#unregister-object-plugin-section).  

<a id="unregister-proto-section"/>  

##### PROTO

This API allow to unregister already instantiated plugin instances for object of specified type ([Chat](reference-chat), [User](reference-user), [Me](reference-me) or [Search](reference-search)).  

<a id="unregister-proto"/>  

[`@property CENPluginsBuilderInterface * (^proto)(NSString *object, id plugin)`](#unregister-proto)  
Property provide access to builder which allow unregister proto plugin. `remove()` API will unlink specified plugin from all objects of specified type (including the one, which already has been created and bound with plugin).  

###### PARAMETERS

Next parameters can be passed to builder:  

| Name            | Type         | Attributes | Default                            | Description |
|:---------------:|:------------:|:----------:|:----------------------------------:| ----------- |
| `object`        | NSString     | | | Name of one of available [ChatEngine](reference-chatengine) objects: [Chat](reference-chat), [User](reference-user), [Me](reference-me) or [Search](reference-search) |  
| `plugin`        | id        | | | Reference on class or identifier (which has been used during registration) of plugin which should be removed. |   

###### EXAMPLE

```objc
self.client.proto(@"Chat", @"CustomPluginIdentifier").remove();
```

<a id="unregister-object-plugin-section"/>

##### OBJECT

Unregister plugin from specific object. Following object has interface which allow to unregister plugins: [Chat](reference-chat), [User](reference-user), [Me](reference-me) and [Search](reference-search).  

<a id="unregister-object-plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(id plugin)`](#unregister-object-plugin)  
Property provide access to builder which allow register plugin for object. `remove()` API will instantiate and bind plugin to caller object.  

###### PARAMETERS

Next parameters can be passed to builder:  

| Name            | Type         | Attributes | Default                            | Description |
|:---------------:|:------------:|:----------:|:----------------------------------:| ----------- |
| `plugin`        | id        | | | Reference on class or identifier (which has been used during registration) of plugin which should be removed. |   

###### EXAMPLE

```objc
chat.plugin([CENUnreadMessagesPlugin class]).remove();
```

### Check Plugin Registration

It is possible to check whether plugin has been registered for specific object or for all as proto plugin using it's class or identifier.  
Plugins registered with same identifiers will replace each other and if it is required, it is possible to check whether there is one registered already or not.  

There is two places where plugin registration can be checked: [proto](#check-proto-section) and [object plugin](#check-object-plugin-section).  

<a id="check-proto-section"/>  

##### PROTO

This API allow to check whether specified proto plugin already registered for object of specified type ([Chat](reference-chat), [User](reference-user), [Me](reference-me) or [Search](reference-search)) or not.  

<a id="check-proto"/>  

[`@property CENPluginsBuilderInterface * (^proto)(NSString *object, id plugin)`](#check-proto)  
Property provide access to builder which allow check proto plugin registration. `exists()` API will check whether there is information about plugin for specified object type which can be used for instantiation for new objects or not.  

###### PARAMETERS

Next parameters can be passed to builder:  

| Name            | Type         | Attributes | Default                            | Description |
|:---------------:|:------------:|:----------:|:----------------------------------:| ----------- |
| `object`        | NSString     | | | Name of one of available [ChatEngine](reference-chatengine) objects: [Chat](reference-chat), [User](reference-user), [Me](reference-me) or [Search](reference-search) |  
| `plugin`        | id        | | | Reference on class or identifier (which has been used during registration) of plugin which should be removed. |   

###### EXAMPLE

```objc
if (!self.client.proto(@"Chat", @"CustomPluginIdentifier").exists()) {
    self.client.proto(@"Chat", @"CustomPluginIdentifier").store();
}
```

<a id="check-object-plugin-section"/>

##### OBJECT

This API allow to check whether specified plugin already registered for specific object. Following object has interface which allow to unregister plugins: [Chat](reference-chat), [User](reference-user), [Me](reference-me) and [Search](reference-search).  

<a id="check-object-plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(id plugin)`](#check-object-plugin)  
Property provide access to builder which allow check plugin registration. `exists()` API will check whether there is information about plugin for receiving object.

###### PARAMETERS

Next parameters can be passed to builder:  

| Name     | Type | Attributes | Default                            | Description |
|:--------:|:----:|:----------:|:----------------------------------:| ----------- |
| `plugin` | id   | | | Reference on class or identifier (which has been used during registration) of plugin which should be removed. |   

###### EXAMPLE

```objc
if (!chat.plugin([CENUnreadMessagesPlugin class]).exists()) {
    chat.plugin([CENUnreadMessagesPlugin class]).store();
}
```

### Plugin Extension

Objective-C allow to extend class interfaces only at run-time - so it is impossible to extend it before app run with plugins. As way to solve it, added helper method to objects which can be used with plugins:  
```objc
chat.extension(@"myPlugin", ^(id extension) {
    // 'id' can be replaced with actual plugin's extension class name.
});
```  

It is possible to work with plugin-provided extension only within specified block. _id_ can be replaced with class which represent requested extension - in our case it can be **CENUnreadMessagesExtension**:  
```objc
chat.extension(@"myPlugin", ^(CENUnreadMessagesExtension *extension) {
    // 'id' can be replaced with actual plugin's extension class name.
});
```  

And now we have access to interface which is bound by developer to receiving object (in our case _chat_).  

Plugin developers may provide shortcut for extension operations. For example, instead of requesting extension context and calling `[extension active]` it is possible to use plugin helpers like this: `[CENUnreadMessagesPlugin  setChat:chat active:YES]`