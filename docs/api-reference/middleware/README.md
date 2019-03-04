# CEPMiddleware

[CENChatEngine](../chatengine) objects events processing middleware base class.  
Plugins which provide middleware support should bundle classes which is subclass of this base class.

Plugin developers should import class category (`<CENChatEngine/CEPMiddleware+Developer.h>`) which 
provide interface with explanation about how middleware should be written.  


## Properties

<a id="configuration"/>

[`@property NSDictionary *configuration`](#configuration)  
`NSDictionary` which is passed during plugin registration and contain extension required 
configuration information.


<br/><br/><a id="events"/>

[`@property NSArray<NSString *> *events`](#events)  
`NSArray` of event names for which middleware should be used.  
List may consist from exact event names or use paths with wildcard (*) or handle all events by 
passing only '*' in returned list.


<br/><br/><a id="identifier"/>

[`@property NSString *identifier`](#identifier)  
Unique identifier of plugin which instantiated this middleware.  


<br/><br/><a id="object"/>

[`@property CENObject *object`](#object)  
[CENObject](../object) subclass instance for which middleware has been associated.


<br/><br/><a id="location"/>

[`@property NSString *location`](#location)  
Middleware installation location.   
Middleware will be called each time when data will pass through specified location. Available 
locations (each is field inside of `CEPMiddlewareLocation` _typedef struct_):
* `emit` - location which is triggered when [CENChatEngine](../chatengine) is about to send 
  any name of emitted event data to [PubNub](https://pubnub.com) real-time network,
* `on` - location which is triggered when [CENChatEngine](../chatengine) receive any data 
  from [PubNub](https://pubnub.com) real-time network.
  

## Methods

<a id="oncreate"/>

[`- (void)onCreate`](#oncreate)  
Handle middleware instantiation and registration completion for specific [object](#object).  

### Example

Bellow is code from [markdown](../../chat-plugins/markdown-support) plugin initialization completion block:  
```objc
- (void)onCreate {
    
    NSDictionary *configuration = self.configuration[CENMarkdownConfiguration.parserConfiguration];
    void(^parser)(NSString *, void(^)(id)) = self.configuration[CENMarkdownConfiguration.parser];
    
    if (!parser) {
        self.parser = [CENMarkdownParser parserWithConfiguration:(configuration ?: @{})];
    }
```

<br/><br/><a id="ondestruct"/>

[`- (void)onDestruct`](#ondestruct)  
Handle middleware destruction and unregister from specific [object](#object).  


<br/><br/><a id="replaceevents/>

[`+ (void)replaceEventsWith:(NSArray<NSString *> *)events`](#replaceevents)  
Replace pre-defined by `events` class property list of events on which middleware should be used.  
This method is useful for cases, when plugin allow to configure list of events on which it should 
trigger middleware.

### Parameters:

| Name     | Type                  | Description |
|:--------:|:---------------------:| ----------- |  
| `events` | NSArray<NSString *> * | `NSArray` of event names for which middleware should be used. |   


<br/><br/><a id="runforevent/>

[`- (void)runForEvent:(NSString *)event withData:(NSMutableDictionary *)data completion:(void(^)(BOOL rejected))block`](#runforevent)
Run middleware's code which will update \c data as it required by it's logic.  
When multiple middleware(s) process same event, `data` is output of previous middleware and after 
processing/update will be sent to next one.

### Parameters:

| Name    | Type                  | Description |
|:-------:|:---------------------:| ----------- |  
| `event` | NSString *            | Name of event for which middleware should adjust `data` content. |   
| `data`  | NSMutableDictionary * | `NSMutableDictionary` which contain information about event and result of previous middleware execution. |   
| `block` | ^(BOOL rejected)      | Payload processing completion block /closure which pass information on whether middleware rejected received (causes further processing termination) data or not.  |   
