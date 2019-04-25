The [ChatEngine](reference-chatengine) object is `CENEventEmitter` subclass. Configures an event emitter that other [ChatEngine](reference-chatengine) objects inherit. Adds shortcut methods for `self.on()`, `self.emit()`, etc.

### Methods

<a id="off"/>

[`@property CENEventEmitter * (^off)(NSString *event, id handler)`](#off)  
Stop a handler block from listening to an event.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | Reference on same handler block which has been used with `on()` or `onAny`. |  

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(NSDictionary *payload) {
    NSLog(@"Something happened!");
};

object.on(@"event", self.eventHandlingBlock);
// .....
object.off(@"event", self.eventHandlingBlock);
```


<br/><br/><a id="offany"/>

[`@property CENEventEmitter * (^offAny)(id handlerBlock)`](#offany)  
Stop a handler block from listen to any events.   

#### EXAMPLE

```objc
self.eventHandlingBlock = ^(NSString *event, NSDictionary *payload) {
    NSLog(@"Something happened!");
};

object.onAny(self.eventHandlingBlock);
// .....
object.offAny(self.eventHandlingBlock);
```


<br/><br/><a id="on"/>

[`@property CENEventEmitter * (^on)(NSString *event, id handler)`](#on)  
Listen for a specific event and fire a handler block when it's emitted. Supports wildcard matching.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run when the event is emitted. |  

#### EXAMPLE

```objc
// Get notified of 'event'.
object.on(@"event", ^(NSDictionary *payload) {
    NSLog(@"'event' was fired");
});

/**
 * Get notified of event.a and event.b.
 * Handler block include additional argument to which handled event 
 * name will be passed. 
 */
object.on(@"event.*", ^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' was fired", event);
});
```


<br/><br/><a id="onany"/>

[`@property CENEventEmitter * (^onAny)(id handler)`](#onany)  
Listen for any event on this object and fire a handler block when it's emitted.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `handler` | id       | The handler block to run when any event is emitted. First parameter. |  

#### EXAMPLE

```objc
object.onAny(^(NSString *event, NSDictionary *payload) {
    NSLog(@"All events trigger this.");
});
```


<br/><br/><a id="once"/>

[`@property CENEventEmitter * (^once)(NSString *event, id handler)`](#once)  
Listen for an event and only fire the handler block a single time.  

#### PARAMETERS

| Name      | Type     | Description |
|:---------:|:--------:| ----------- |
| `event`   | NSString | The event name. |
| `handler` | id       | The handler block to run once. |  

#### EXAMPLE

```objc
object.once(@"message", ^(NSDictionary *payload) {
    NSLog(@"This is only fired once!");
});
```

<br/><a id="removeall"/>

[`@property CENObject * (^removeAll)(NSString *event)`](#removeall)  
Stop all handler blocks from listening to an event.  

#### EXAMPLE

```objc
object.removeAll(@"message");
```
 