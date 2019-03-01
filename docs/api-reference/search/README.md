# CENSearch

[CENChat](../chat) room history search.  


## Subclass  

* [CENEventEmitter](../emitter)  
* [CENObject](../object)  

## Properties

<a id="chat"/>

[`@property CENChat *chat`](#chat)  
See: [CENChat](../chat)  
[Chat](../chat) for which search has been performed.

<br/><a id="count"/>

[`@property NSInteger count`](#count)  
The maximum number of messages which can be fetched with single history request.  

<br/><a id="end"/>

[`@property NSNumber *end`](#end)  
The timetoken to end searching between.  

<br/><a id="event"/>

[`@property NSString *event`](#event)  
Name of [event](../event) to search for.  

<br/><a id="hasmore"/>

[`@property BOOL hasMore`](#hasmore)  
Whether there is potentially more events available for fetch.  
This flag can be used for conditional call of [CENSearch.next](#next).

<br/><a id="limit"/>

[`@property NSInteger limit`](#limit)  
The maximum number of results to return that match search criteria.  
Search will continue operating until it returns this number of results or it reached the end of 
history.  
Limit will be ignored in case if both 'start' and 'end' timetokens has been passed in search 
configuration.

<br/><a id="pages"/>

[`@property NSInteger pages`](#pages)  
The maximum number of history requests which [CENChatEngine](../chatengine) will do 
automatically to fulfill [limit](#limit) requirement.  

<br/><a id="sender"/>

[`@property CENUser *sender`](#sender)  
See: [CENUser](../user)  
[User](../user) who sent the message.  

<br/><a id="start"/>

[`@property NSNumber *start`](#start)  
The timetoken to begin searching between.  


## Methods

<a id="extension"/>

[`extension(id plugin)`](#extension)  
Inherited from: [CENObject.extension](../object#extension)  
Access receiver's interface extensions.


<br/><br/><a id="next"/>

[`next()`](#next)  
Search for older events (if possible).  

### Returns:

[Receiver](../search) which can be used to chain other methods call.  


### Example

```objc
CENSearch *search = self.chat.search().event(@"announcement").create();

search.search().once(@"$.search.pause", ^(CENEmittedEvent *event) {
    // Handle search pause because any of specified limits has been reached.
    search.next();
});
```


<br/><br/><a id="off"/>

[`off(NSString *event, CENEventHandlerBlock handler)`](#off)  
Inherited From: [CENEventEmitter.off](../emitter#off)  
Unsubscribe from particular or multiple (wildcard) `events` by removing `handler` from listeners 
list.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event for which handler should be removed. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

Stop specific event handling.
```objc
self.pingHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle 'ping' event from chat's history.
};

self.search.off(@"ping", self.pingHandlingBlock);
```

Stop multiple events handling.
```objc
self.errorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any first emitted error.
};

self.search.off(@"$.error.*", self.errorHandlingBlock);
```

<br/><br/><a id="offany"/>

[`offAny(CENEventHandlerBlock handler)`](#offany)  
Inherited from: [CENEventEmitter.offAny](../emitter#offany)  
Unsubscribe from any events emitted by receiver by removing `handler` from listeners list.   

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

```objc
self.anyHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle event.
};

self.search.offAny(self.anyHandlingBlock);
```


<br/><br/><a id="on"/>

[`on(NSString *event, CENEventHandlerBlock handler)`](#on)  
Inherited From: [CENEventEmitter.on](../emitter#on)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and handle
it with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
self.search.on(@"ping", ^(CENEmittedEvent *event) {
    // Handle 'ping' event from chat's history.
});
```

Handle multiple events using wildcard.
```objc
self.search.on(@"$typingIndicator.*", ^(CENEmittedEvent *event) {
    // Handle '$typingIndicator.startTyping' and / or '$typingIndicator.stopTyping' event from
    // chat's history.
});
```


<br/><br/><a id="onany"/>

[`onAny(CENEventHandlerBlock handler)`](#onany)  
Inherited From: [CENEventEmitter.onAny](../emitter#onany)  
Subscribe on any events which will be emitted by receiver and handle them with provided event 
handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle any events. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

```objc
self.search.onAny(^(CENEmittedEvent *event) {
    // Handle emitted event.
});
```


<br/><br/><a id="once"/>

[`once(NSString *event, CENEventHandlerBlock handler)`](#once)  
Inherited From: [CENEventEmitter.once](../emitter#once)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and 
handle it once with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
self.search.once(@"ping", ^(CENEmittedEvent *event) {
    // Handle 'ping' event from chat's history once.
});
```

Handle one of multiple events once using wildcard.
```objc
self.search.once(@"$.error.*", ^(CENEmittedEvent *event) {
    // Handle any first emitted error.
});
```


<br/><br/><a id="plugin-exists"/>

[`plugin(id).exists()`](#plugin-exists)  
Inherited From: [CENObject.plugin](../object#plugin-exists)  
Check whether plugin exists using specified parameters.  
 

<br/><br/><a id="plugin-remove"/>

[`plugin(id).remove()`](#plugin-remove)  
Inherited From: [CENObject.plugin](../object#plugin-remove)  
Remove plugin using specified parameters.  
 

<br/><br/><a id="plugin-store"/>

[`plugin(id).identifier(NSString *).configuration(NSDictionary *).store()`](#plugin-store)  
Inherited From: [CENObject.plugin](../object#plugin-store)  
Create plugin using specified parameters.  

<br/><br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)  
Inherited from: [CENEventEmitter.removeAll](../emitter#removeall)  
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  

### Parameters:

| Name    | Type       | Attributes | Description     |
|:-------:|:----------:|:----------:| --------------- |
| `event` | NSString * |  Required  | Name of event for which has been used to register handler blocks. | 

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

Remove specific event handlers
```objc
self.search.removeAll(@"ping");
```

Remove multiple event handlers
```objc
self.search.removeAll(@"$.error.*");
```

<br/><br/><a id="search"/>

[`search()`](#search)  
Search through previously emitted events.  

### Returns:

[Receiver](../search) which can be used to chain other methods call.  

### Example

```objc
self.chat.search().event(@"announcement").create().search();
```


## Events

<a id="event-error-search"/>

[`$.error.search`](#event-error-search)  
There was a problem fetching the history of this chat.

### Properties:

| Name      | Type       |  Value                          | Description |
|:---------:|:----------:|:-------------------------------:| ----------- |
| `event`   | NSString * | `$.error.search`                | Name of handled event. |
| `emitter` | id         | [CENSearch](../search) * | Object, which emitted local event. In this case it will be `self.search` since handler added to listen [search](../search) emitted events. |
| `data`    | id         | `NSError *`                     | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.search.on(@"$.error.search", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
    
    NSLog(@"Chat history fetch did fail: %@", error);
});
```

<br/><br/><a id="event-search-finish"/>

[`$.search.finish`](#event-search-finish)  
Search has returned all results or reached the end of history.

### Properties:

| Name      | Type       |  Value                          | Description |
|:---------:|:----------:|:-------------------------------:| ----------- |
| `event`   | NSString * | `$.search.finish`               | Name of handled event. |
| `emitter` | id         | [CENSearch](../search) * | Object, which emitted local event. In this case it will be `self.search` since handler added to listen [search](../search) emitted events. |
| `data`    | id         | `nil`                           | `$.search.finish` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.search.on(@"$.search.finish", ^(CENEmittedEvent *event) {
    NSLog(@"Search completed!");
});
```

<br/><br/><a id="event-search-page-request"/>

[`$.search.page.request`](#event-search-page-request)  
Requesting another page from PubNub History.

### Properties:

| Name      | Type       |  Value                          | Description |
|:---------:|:----------:|:-------------------------------:| ----------- |
| `event`   | NSString * | `$.search.page.request`         | Name of handled event. |
| `emitter` | id         | [CENSearch](../search) * | Object, which emitted local event. In this case it will be `self.search` since handler added to listen [search](../search) emitted events. |
| `data`    | id         | `nil`                           | `$.search.page.request` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.search.on(@"$.search.page.request", ^(CENEmittedEvent *event) {
    // Update search progress.
});
```

<br/><br/><a id="event-search-page-response"/>

[`$.search.page.response`](#event-search-page-response)  
PubNub History returned a response.

### Properties:

| Name      | Type       |  Value                          | Description |
|:---------:|:----------:|:-------------------------------:| ----------- |
| `event`   | NSString * | `$.search.page.response`        | Name of handled event. |
| `emitter` | id         | [CENSearch](../search) * | Object, which emitted local event. In this case it will be `self.search` since handler added to listen [search](../search) emitted events. |
| `data`    | id         | `nil`                           | `$.search.page.response` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.search.on(@"$.search.page.response", ^(CENEmittedEvent *event) {
    // Prepare to layout new set of events (if any match search criteria).
});
```

<br/><br/><a id="event-search-pause"/>

[`$.search.pause`](#event-search-pause)  
Search has reached `pages` limit while tried to fetch `limit` events.

### Properties:

| Name      | Type       |  Value                          | Description |
|:---------:|:----------:|:-------------------------------:| ----------- |
| `event`   | NSString * | `$.search.pause`                | Name of handled event. |
| `emitter` | id         | [CENSearch](../search) * | Object, which emitted local event. In this case it will be `self.search` since handler added to listen [search](../search) emitted events. |
| `data`    | id         | `nil`                           | `$.search.pause` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.search.on(@"$.search.pause", ^(CENEmittedEvent *event) {
    CENSearch *search = event.emitter;
    
    if (search.hasMore) {
        // Enable next search page button.
    }
});
```

<br/><br/><a id="event-search-start"/>

[`$.search.start`](#event-search-start)  
Search has started.

### Properties:

| Name      | Type       |  Value                          | Description |
|:---------:|:----------:|:-------------------------------:| ----------- |
| `event`   | NSString * | `$.search.start`                | Name of handled event. |
| `emitter` | id         | [CENSearch](../search) * | Object, which emitted local event. In this case it will be `self.search` since handler added to listen [search](../search) emitted events. |
| `data`    | id         | `nil`                           | `$.search.start` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.search.on(@"$.search.start", ^(CENEmittedEvent *event) {
    NSLog(@"Search started!");
});
```