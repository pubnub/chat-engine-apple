# CEPMiddleware

Middleware is part of plugin package which provide data modification ability.  
With middleware it is possible to pre-process and modify payload which has been emitted by user or received from another chat users.

Only developer category on this class provide functionality. These methods should be used by plugin developer to provide client with required information about how it should be used.

### Properties

<a id="configuration"/>

[`@property NSDictionary *configuration`](#configuration)  
Dictionary which is passed during plugin registration and may contain middleware configuration information.   

<br/><a id="events"/>

[`@property NSArray<NSString *> *events`](#events)  
Class level property which should provide list of events for which middleware should be triggered.  

##### EXAMPLE

Following example allow to handle any events which is go through configured [location](#location):  
```objc
+ (NSArray<NSString *> *)events {
    return @[@"*"];
}
```

Following example allow to handle group of events which is go through configured [location](#location):  
```objc
+ (NSArray<NSString *> *)events {
    return @[@"detector.*"];
}
```

Middleware with such configuration will be triggered for events like: `detector.online`, `detector.alarm` and others.

Also it is possible to specify concrete event names for which middleware should trigger.

<br/><a id="location"/>

[`@property NSString *location`](#identifier)  
Class level property which define middleware mounting location.   
Available locations described [here](reference-middleware-locations).  

##### EXAMPLE

Example below instruct plugins system what middleware should be mounted at events which goes through [on](reference-middleware-locations#location-on) location:  
```objc
+ (NSString *)location {
    return CEPMiddlewareLocation.on;
}
```

<br/><a id="identifier"/>

[`@property NSString *identifier`](#identifier)  
Unique identifier of plugin which instantiated this middleware.  

### Methods

<a id="runforevent/>

[`- (void)runForEvent:(NSString *)event withData:(NSMutableDictionary *)data completion:(void(^)(BOOL rejected))block`](#runforevent)  
Middleware trigger method. This method called each time when plugins system identify this middleware as the one which should handle event. 
Middleware should use this opportunity to modify provided `data` payload as it required (by plugin logic). Data in `data` object described by [event data keys](reference-event-data).

**WARNING:** Middleware shouldn't remove any keys added which is already part of provided payload.  

#### PARAMETERS

| Name       | Type         | Description        |
|:----------:|:------------:| ------------------ |  
| `event` | NSString | One of events to which middleware has been registered by providing corresponding information with class [property](#events). |   
|  `data`  | NSMutableDictionary | Reference on object which has been processed.  |   
|  `block`  | ^(BOOL rejected) | Reference on block which should be called by middleware at the end of data processing. Additionally possible to pass whether middleware doesn't want to handle payload and pass `YES` into called block.  |   

<br/><a id="oncreate"/>

[`- (void)onCreate`](#oncreate)  
Middleware initialization completion handler. This method will be called by ChatEngine plugins system when right after middleware has been registered.    

#### EXAMPLE

Bellow is code from [markdown](plugins-markdown) plugin initialization completion block:  
```objc
- (void)onCreate {
    
    NSDictionary *configuration = self.configuration[CENMarkdownConfiguration.parserConfiguration] ?: @{};
    self.parser = [CENMarkdownParser parserWithConfiguration:configuration];
}
```

<br/><a id="ondestruct"/>

[`- (void)onDestruct`](#ondestruct)  
Middleware removal handler. This method will be called by ChatEngine plugins system right before middleware will be unregistered.    