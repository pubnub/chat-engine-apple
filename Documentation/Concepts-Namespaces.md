Event names follow a pattern that helps determine where an object originated.

### Custom Events
Custom events are events you defined in out framework, like `message` and `invite`. They are simply string, but they should not include any special characters (expect `.`).

### $ - System Events

System events always begin with a `$`. For example, [$.ready](reference-chatengine#event-ready) and [$.online.join](reference-chat#event-online-join) are examples of events emitted by ChatEngine. They are system events that are automatically emitted when specific things happen. System events are documented in the reference.  

### $plugin - Plugin Events

Plugin events always begin with `$pluginName`. `$typingIndicator.startTyping` is an example of an event emitted by the [TypingIndicator](plugins-typing-indicator) plugin. The `$typingIndicator` string is a plugin namespace and `startTyping` is the plugin event. Namespacing plugins helps ensure that is no collusion between plugins.  

### Event Chidren

Dots (`.`) in an event name indicate that the event is a child of some parent. For example `image.like` indicates that a 'like' event was defined for specific 'image'. You could then subscribe to all `image` events by subscribing to the `image.*` event. See [Wildcards](concepts-wildcards).