# CENEventEmitter

Events signalling.  
Provides interface to subscribe and emit events for it's subclasses.


## Properties

<a id="eventnames"/>

[`@property NSArray<NSString *> *eventNames`](#eventnames)  
List of event names on which object has registered handler block.


## Methods

<a id="off"/>

[`off(NSString *event, CENEventHandlerBlock handler)`](#off)  
Unsubscribe from particular or multiple (wildcard) `events` by removing `handler` from listeners 
list.  

**Note:** To be able to remove handler block / closure, it is required to store reference on it in
instance which listens for updates.

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event for which handler should be removed. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../emitter) which can be used to chain other methods call.  

### Example

Stop specific event handling
```objc
self.handlingBlock = ^(CENEmittedEvent *event) {
    // Handle 'event' emitted by object.
};

// Later, when event handling not required anymore.
self.object.off(@"event", self.handlingBlock);
```

Stop multiple events handling
```objc
self.handlingBlock = ^(CENEmittedEvent *event) {
    // Handle 'event.a' and / or 'event.b' or emitted by object.
};

// Later, when event handling not required anymore.
self.object.off(@"event.*", self.handlingBlock);
```


<br/><br/><a id="offany"/>

[`offAny(CENEventHandlerBlock handler)`](#offany)  
Unsubscribe from any events emitted by receiver by removing `handler` from listeners list.  

**Note:** To be able to remove handler block / closure, it is required to store reference on it in
instance which listens for updates.

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../emitter) which can be used to chain other methods call.  

### Example

```objc
self.anyHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any event emitted by object.
};

// Later, when event handling not required anymore.
self.client.offAny(self.invitationHandlingBlock);
```


<br/><br/><a id="on"/>

[`on(NSString *event, CENEventHandlerBlock handler)`](#on)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and handle
it with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../emitter) which can be used to chain other methods call.  

### Example

Handle specific event
```objc
self.object.on(@"event", ^(CENEmittedEvent *event) {
    // Handle 'event' emitted by object.
});
```

Handle multiple events using wildcard
```objc
self.object.on(@"event.*", ^(CENEmittedEvent *event) {
    // Handle 'event.a' and / or 'event.b' or emitted by object.
});
```


<br/><br/><a id="onany"/>

[`onAny(CENEventHandlerBlock handler)`](#onany)  
Subscribe on any events which will be emitted by receiver and handle them with provided event 
handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle any events. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../emitter) which can be used to chain other methods call.  

### Example

```objc
self.object.onAny(^(CENEmittedEvent *event) {
    // Handle any event emitted by object.
});
```


<br/><br/><a id="once"/>

[`once(NSString *event, CENEventHandlerBlock handler)`](#once)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and 
handle it once with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../emitter) which can be used to chain other methods call.  

### Example

Handle specific event once
```objc
self.object.once(@"event", ^(CENEmittedEvent *event) {
    // Handle 'event' emitted by object once.
});
```

Handle one of multiple events once using wildcard
```objc
self.object.once(@"event.*", ^(CENEmittedEvent *event) {
    // Handle 'event.a' and / or 'event.b' or emitted by object once.
});
```

<br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)    
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  

### Parameters:

| Name    | Type       | Attributes | Description     |
|:-------:|:----------:|:----------:| --------------- |
| `event` | NSString * |  Required  | Name of event for which has been used to register handler blocks. | 

### Returns:

[Receiver](../emitter) which can be used to chain other methods call.  

### Example

Remove specific event handlers
```objc
self.object.removeAll(@"event");
```

Remove multiple event handlers
```objc
self.object.removeAll(@"event.*");
```
 