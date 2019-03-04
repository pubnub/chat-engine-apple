# CENObject

Generic [CENChatEngine](../chatengine) class which provide ability to use event emitter and
plugins functionality on it's subclasses like: [CENChat](../chat), 
[CENUser](../user), [CENMe](../me) and [CENSearch](../search).
All emitted events forwarded to [CENChatEngine](../chatengine).

## Subclass  

* [CENEventEmitter](../emitter)  


## Methods

<a id="extension"/>

[`extension(id plugin)`](#extension)  
Tutorials: [Plugins](../../concepts/plugins#plugin-extension)  
Access receiver's interface extensions.

### Parameters:

| Name      | Type | Attributes | Description |
|:---------:|:----:|:----------:| ----------- |
| `plugin`  |  id  |  Required  | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. |

### Returns:

Extension instance which can be used or `nil` if there is no extension for specified class or 
`identifier`.


<br/><br/><a id="off"/>

[`off(NSString *event, CENEventHandlerBlock handler)`](#off)  
Inherited From: [CENEventEmitter.off](../emitter#off)  
Unsubscribe from particular or multiple (wildcard) `events` by removing `handler` from listeners 
list.  


<br/><br/><a id="offany"/>

[`offAny(CENEventHandlerBlock handler)`](#offany)  
Inherited from: [CENEventEmitter.offAny](../emitter#offany)  
Unsubscribe from any events emitted by receiver by removing `handler` from listeners list.  


<br/><br/><a id="on"/>

[`on(NSString *event, CENEventHandlerBlock handler)`](#on)  
Inherited From: [CENEventEmitter.on](../emitter#on)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and handle
it with provided event handler.  


<br/><br/><a id="onany"/>

[`onAny(CENEventHandlerBlock handler)`](#onany)  
Inherited From: [CENEventEmitter.onAny](../emitter#onany)  
Subscribe on any events which will be emitted by receiver and handle them with provided event 
handler.  


<br/><br/><a id="once"/>

[`once(NSString *event, CENEventHandlerBlock handler)`](#once)  
Inherited From: [CENEventEmitter.once](../emitter#once)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and 
handle it once with provided event handler.  


<br/><br/><a id="plugin-exists"/>

[`plugin(id).exists()`](#plugin-exists)  
Tutorial: [Plugins](../../concepts/plugins)  
Check whether plugin / proto plugin exists using specified parameters.  

### Parameters

| Name            | Type               | Attributes | Description |
|:---------------:|:------------------:|:----------:| ----------- |
| `plugin`        | Class / NSString * |  Required  | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. |  

### Returns:

Whether plugin / proto plugin exists or not.


<br/><br/><a id="plugin-remove"/>

[`plugin(id).remove()`](#plugin-remove)  
Tutorial: [Plugins](../../concepts/plugins)  
Remove plugin using specified parameters.  

### Parameters

| Name            | Type               | Attributes | Description |
|:---------------:|:------------------:|:----------:| ----------- |
| `plugin`        | Class / NSString * |  Required  | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. |  


<br/><br/><a id="plugin-store"/>

[`plugin(id).identifier(NSString *).configuration(NSDictionary *).store()`](#plugin-store)  
Tutorial: [Plugins](../../concepts/plugins)  
Create plugin / proto plugin using specified parameters.  

### Parameters

| Name            | Type           | Attributes | Default               | Description |
|:---------------:|:--------------:|:----------:|:---------------------:| ----------- |
| `plugin`        | id             |  Required  |                       | [CEPPlugin](referemce-plugin) subclass class or plugin's unique identifier retrieved. | 
| `identifier`    | NSString *     |            | `Plugin's identifier` | Plugin identifier under which initialized plugin will be stored and can be retrieved. | 
| `configuration` | NSDictionary * |            | `@{}`                 | Dictionary with configuration for plugin. | 

**Note:** Builder parameters can be specified in different variations depending from needs.


<br/><br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)  
Inherited from: [CENEventEmitter.removeAll](../emitter#removeall)  
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  