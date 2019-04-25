Base class for all [ChatEngine](reference-chatengine) objects which provide support for [plugins](concepts-plugins) and forward events to [ChatEngine](reference-chatengine).

### Subclass  

* [Emitter](reference-emitter)  

### Methods

<a id="off"/>

[`@property CENObject * (^off)(NSString *event, id handlerBlock)`](#off)  
Inherited from: [Emitter.off](reference-emitter#off)  
Stop a handler block from listening to an event.  

<a id="offany"/>

[`@property CENObject * (^offAny)(id handlerBlock)`](#offany)  
Inherited from: [Emitter.offAny](reference-emitter#offany)  
Stop a handler block from listen to any events.   

<a id="on"/>

[`@property CENObject * (^on)(NSString *event, id handlerBlock)`](#on)  
Inherited from: [Emitter.on](reference-emitter#on)  
Listen for a specific event and fire a handler block when it's emitted. Supports wildcard matching.  

<a id="onany"/>

[`@property CENObject * (^onAny)(id handlerBlock)`](#onany)  
Inherited from: [Emitter.onAny](reference-emitter#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  

<a id="once"/>

[`@property CENObject * (^once)(NSString *event, id handlerBlock)`](#once)  
Inherited from: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

<a id="removeall"/>

[`@property CENObject * (^removeAll)(NSString *event)`](#removeall)  
Inherited from: [Emitter.removeAll](reference-emitter#removeall)  
Stop all handler blocks from listening to an event.  
 
<a id="plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(id plugin)`](#plugin)  
Tutorials: [Plugins](concepts-plugins)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin` | id       | The plugin class or identifier. |
 
<br/><a id="extension"/>

[`@property CENObject * (^extension)(id plugin, void(^block)(id extension))`](#extension)  
Tutorials: [Plugins](concepts-plugins#plugin-extension)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin` | id       | The plugin class or identifier. |
| `block` | ^(id extension) | Reference on extension execution context block. Block pass one argument - reference on extension instance which can be used. |