# CEPPlugin

Plugins is objects which allow to augment ChatEngine objects data flow and functionality.  
This is main class which is used by plugin system to figure out what extensions and middleware should be used for various ChatEngine object.  

Only developer category on these class provide functionality. This methods should be used by plugin developer to provide client with required information about how it should be used.  

### Properties

<a id="configuration"/>

[`@property NSDictionary *configuration`](#configuration)  
Dictionary which is passed during plugin registration and will be passed by ChatEngine during extension and/or middleware instantiation.  

<br/><a id="identifier"/>

[`@property NSString *identifier`](#identifier)  
Default plugin identifier.  

### Methods

<a id="extensionclassfor"/>

[`- (nullable Class)extensionClassFor:(CENObject *)object`](#extensionclassfor)  
When implemented by plugin, it provide information about [extension](reference-extension) class which should be used for passed `object` instance.  

#### PARAMETERS

| Name    | Type         | Description        |
|:-------:|:------------:| ------------------ |  
| `object` | [CENObject](reference-object) | ChatEngine object for which interface extension requested.  |   

#### EXAMPLE

```objc
- (Class)extensionClassFor:(CENObject *)object {

    if ([object isKindOfClass:[CENChat class]]) {
        return [PluginChatExtension class];
    } else if ([object isKindOfClass:[CENMe class]]) { 
        return [PluginMeExtension class];
    }

    return nil;
}
```

<br/><a id="middlewareclassforlocation"/>

[`- (nullable Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object`](#middlewareclassforlocation)  
When implemented by plugin, it provide information about [middleware](reference-middleware) class which should be used for passed `object` instance at specific location (possible values described [here](reference-middleware-locations)).  

#### PARAMETERS

| Name       | Type         | Description        |
|:----------:|:------------:| ------------------ |  
| `location` | NSString | One of middleware mount [locations](reference-middleware-locations).  |   
|  `object`  | [CENObject](reference-object) | ChatEngine object for which interface extension requested.  |    

#### EXAMPLE

```objc
- (Class)middlewareClassForLocation:(NSString *)location 
                             object:(CENObject *)object {
    
    if ([location isEqualToString:CEPMiddlewareLocations.on] && 
        [object isKindOfClass:[CENChat class]]) {

        return [PluginChatDataParserMiddleware class];
    }

    return nil;
}
```

<br/><a id="oncreate"/>

[`- (void)onCreate`](#oncreate)  
Plugin initialization completion handler. This method will be called by ChatEngine plugins system right before plugin will be bound to object.  

From within this method it is possible to get access to [configuration](reference-plugin#configuration) which has been passed during registration. Also, this handler is last place where configuration can be modified (for example default values is set) before it will be passed to [extensions](reference-extension) and [middleware](reference-middleware).   

#### EXAMPLE

```objc
- (void)onCreate {
    
    // Set default values if nothing has been provided during plugin registration.
    if (!self.configuration.count) {
        self.configuration = @{ CENTypingIndicatorConfiguration.timeout: @(1.f) };
    }
}
```