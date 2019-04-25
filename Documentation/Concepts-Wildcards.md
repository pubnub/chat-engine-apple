You can get notified of evert event that a ChatEngine object emits by subscribing to the `*` wildcard event or using `onAny` method.

```objc
chat.on(@"*", ^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' event emitted: %@", event, payload);
});

chat.onAny(^(NSString *event, NSDictionary *payload) {
    NSLog(@"'%@' event emitted: %@", event, payload);
});
```

### Namespaced Wildcards

Wildcards also work within namespaces.

#### SYSTEM EVENTS

You could subscribe to all system events with `$.*`. See [Namespaces](concepts-namespaces).  

#### PLUGIN

You can get notified of all `plugin` events by subscribing to `$plugin.*`.

### All Events Everywhere

All events any object in ChatEngine fires is also emitted from the ChatEngine object. You can get notified of every event by subscribing to [ChatEngine.onAny](reference-chatengine#onany).  

This is helpful for debugging and notifying interface to be updated.   
```objc
self.client.onAny(^(NSString *event, id emitted, NSDictionary *payload) {
    NSLog(@"'%@' event emitted: %@", event, payload);
});
```