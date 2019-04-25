# CENSearch

Returned by [Chat.search](reference-chat#search). This is our Search class which allows one to search the backlog of events.  
Powered by [PubNub History](https://www.pubnub.com/docs/ios-objective-c/storage-and-history).  

### Subclass  

* [Object](reference-object)  
* [Emitter](reference-emitter)  

### Properties

<a id="chat"/>

[`@property CENChat *chat`](#chat)  
See: [Chat](reference-chat)  
The [Chat](reference-chat) used for searching.

<br/><a id="count"/>

[`@property NSInteger count`](#count)  
Maximum number of events returned with single search request.  

<br/><a id="end"/>

[`@property NSNumber *end`](#end)  
The timetoken to end searching between.  

<br/><a id="event"/>

[`@property NSString *event`](#event)  
The [Event](reference-event) to search for.  

<br/><a id="hasmore"/>

[`@property BOOL hasMore`](#hasmore)  
Flag which represent whether there is potentially more data available in [Chat](reference-chat) history. This flag can be used for conditional call of [Search.next](reference-search#next).

<br/><a id="limit"/>

[`@property NSInteger limit`](#limit)  
The maximum number of results to return that match search criteria. Search will continue operating until it returns this number of results or it reached the end of history.  
Limit will be ignored in case if both `start` and `end` timetokens has been passed to search configuration.  

<br/><a id="pages"/>

[`@property NSInteger pages`](#pages)  
Maximum number of search request which can be performed to reach specified search end criteria: `limit`.  

<br/><a id="sender"/>

[`@property CENUser *sender`](#sender)  
The [User](reference-user) who sent the message.  

<br/><a id="start"/>

[`@property NSNumber *start`](#start)  
The timetoken to begin searching between.  

### Methods

<a id="next"/>

[`@property CENSearch * (^next)(void)`](#next)  
Search for older events (if possible).  


#### EXAMPLE

```objc
CENSearch *search = chat.search().limit(400).pages(3);
search.on(@"$.search.pause", ^{
    if (search.hasMore) {
        search.next();
    }
});

search.search();
```


<br/><br/><a id="off"/>

[`@property CENSearch * (^off)(NSString *event, id handler)`](#off)  
Inherited From: [Emitter.off](reference-emitter#off)  
Stop a handler block from listening to an event.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | Reference on same handler block which has been used with `on()`. |  

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(NSDictionary *payload) {
    NSLog(@"Something happened!");
};

search.on(@"event", self.eventHandlingBlock);
// .....
search.off(@"event", self.eventHandlingBlock);
```

<br/><br/><a id="offany"/>

[`@property CENSearch * (^offAny)(id handlerBlock)`](#offany)  
Inherited from: [Emitter.offAny](reference-emitter#offany)  
Stop a handler block from listen to any events.   

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | Reference on same handler block which has been used with `onAny()`. |  

#### EXAMPLE

```objc
search.eventHandlingBlock = ^(NSString *event, id data) {
    NSLog(@"Something happened!");
};

search.onAny(self.eventHandlingBlock);
// .....
search.offAny(self.eventHandlingBlock);
```


<br/><br/><a id="on"/>

[`@property CENSearch * (^on)(NSString *event, id handler)`](#on)  
Inherited From: [Emitter.on](reference-emitter#on)  
Listen for a specific event and fire a handler block when it's emitted. Supports wildcard matching.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run when the event is emitted. If `event` contain wildcard block in addition to event payload pass event name. |  

#### EXAMPLE

```objc
// Get notified of 'event' emitted by passed emitter.
search.on(@"event", ^(NSDictionary *payload) {
    NSLog(@"'event' was fired", event);
});

/** 
 * Get notified of $.search.start and $.search.finish emitted by passed emitter. 
 * Handler block include additional argument to which handled event 
 * name will be passed. 
 */
search.on(@"$.search.*", ^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' was fired", event);
});
```


<br/><br/><a id="onany"/>

[`@property CENSearch * (^onAny)(NSString *event, id data)`](#onany)  
Inherited From: [Emitter.onAny](reference-emitter#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | The handler block to run when any event is emitted. Block pass name of event and event data. |  

#### EXAMPLE

```objc
search.onAny(^(NSString *event, id data) {
    NSLog(@"All events trigger this.");
});
```


<br/><br/><a id="once"/>

[`@property CENSearch * (^once)(NSString *event, id handler)`](#once)  
Inherited From: [Emitter.once](reference-emitter#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run once. If `event` contain wildcard block in addition to payload pass event name. |  

#### EXAMPLE

```objc
search.once(@"message", ^(NSDictionary *payload) {
    NSLog(@"This is only fired once!");
});
```
 

<br/><br/><a id="plugin"/>

[`@property CENPluginsBuilderInterface * (^plugin)(id plugin)`](#plugin)  
Tutorials: [Plugins](concepts-plugins)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin ` | id       | The plugin class or identifier. |
 
<br/><br/><a id="extension"/>

[`@property CENSearch * (^extension)(id plugin, void(^block)(id extension))`](#extension)  
Tutorials: [Plugins](concepts-plugins#plugin-extension)  
Binds a plugin to this object.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `plugin` | id       | The plugin class or identifier. |
| `block` | ^(id extension) | Reference on extension execution context block. Block pass one argument - reference on extension instance which can be used. |

<br/><br/><a id="removeall"/>

[`@property CENSearch * (^removeAll)(NSString *event)`](#removeall)  
Inherited from: [Emitter.removeAll](reference-emitter#removeall)  
Stop all handler blocks from listening to an event.  

#### PARAMETERS

| Name    | Type     | Description     |
|:-------:|:--------:| --------------- |
| `event` | NSString | The event name. |

#### EXAMPLE

```objc
search.removeAll(@"message");
```

<br/><br/><a id="search"/>

[`@property CENSearch * (^search)(void)`](#search)  
Search for events which conform to configured search criteria.    

#### EXAMPLE

```objc
chat.search().sender(someUser).event(@"whisper").search();
```


### Events

<a id="event-error-search"/>

[`$.error.search`](#event-error-search)  
There was a problem fetching the history of this chat.

#### PARAMETERS

| Name    | Type    | Description     |
|:-------:|:-------:| --------------- |
| `error` | NSError | Error instance with error information. |

#### EXAMPLE

```objc
search.on(@"$.error.search", ^(NSError *error) {
    NSLog(@"Chat history fetch did fail: %@", error);
});
```

<br/><br/><a id="event-search-finish"/>

[`$.search.finish`](#event-search-finish)  
Search has returned all results or reached the end of history.

#### EXAMPLE

```objc
search.on(@"$.search.finish", ^{
    NSLog(@"Search completed!");
});
```

<br/><br/><a id="event-search-page-request"/>

[`$.search.page.request`](#event-search-page-request)  
Requesting another page from PubNub History.

#### EXAMPLE

```objc
search.on(@"$.search.page.request", ^{
    // Update search progress.
});
```

<br/><br/><a id="event-search-page-response"/>

[`$.search.page.response`](#event-search-page-response)  
PubNub History returned a response.

#### EXAMPLE

```objc
search.on(@"$.search.page.response", ^{
    // Prepare to layout new set of events (if any match search criteria).
});
```

<br/><br/><a id="event-search-pause"/>

[`$.search.pause`](#event-search-pause)  
Search has reached `pages` limit while tried to fetch `limit` events.

#### EXAMPLE

```objc
search.on(@"$.search.pause", ^{
    if (search.hasMore) {
        // Enable next search page button.
    }
});
```

<br/><br/><a id="event-search-start"/>

[`$.search. start `](#event-search-start)  
Search has started.

#### EXAMPLE

```objc
search.on(@"$.search.start", ^{
    NSLog(@"Search started!");
});
```