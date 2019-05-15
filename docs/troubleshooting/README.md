# Troubleshooting

Sometimes it can be difficult to understand exactly what's happening in ChatEngine. ChatEngine includes some handy utilities to make debugging and profiling easier.

## Debug Mode  

This mode will output every event happening within ChatEngine system and it's payload. The event log tells a story about what's happening inside. Events are logged as they are triggered locally.  

You can turn on debug mode by setting [CENConfiguration.debugevents](../api-reference/configuration#debugevents) to `YES` before passing it to [ChatEngine.clientWithConfiguration:](../api-reference/chatengine#constructor).  

### Example

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo"];
configuration.debugevents = YES;
self.client = [CENChatEngine clientWithConfiguration:configuration];
```

This will output every event that occurs within ChatEngine. Note that not every event is a network event.  

```
<ChatEngine::Debug> $.created.chat ▸ <CENChat:0x60c00008c800 name: 'chatEngine'; group: 'system'; channel: 'chatEngine'; private: NO; asleep: NO; <ChatEngine::Debug> $.connected ▸ <CENChat:0x60c00008c800 name: 'chatEngine'; group: 'system'; channel: 'chatEngine'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.created.chat ▸ <CENChat:0x60c00000d240 name: 'direct'; group: 'system'; channel: 'chatEngine#user#stephen#write.#direct'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.created.chat ▸ <CENChat:0x60c00000d9c0 name: 'feed'; group: 'system'; channel: 'chatEngine#user#stephen#read.#feed'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.created.me ▸ <CENMe:0x60b00001eff0 uuid: 'stephen'>.
<ChatEngine::Debug> $.connected ▸ <CENChat:0x60c00000d240 name: 'direct'; group: 'system'; channel: 'chatEngine#user#stephen#write.#direct'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.connected ▸ <CENChat:0x60c00000d9c0 name: 'feed'; group: 'system'; channel: 'chatEngine#user#stephen#read.#feed'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.state ▸ <CENMe:0x60b00001eff0 uuid: 'stephen'>.
<ChatEngine::Debug> $.ready ▸ <CENMe:0x60b00001eff0 uuid: 'stephen'>.
<ChatEngine::Debug> $.online.join ▸ <CENChat:0x60c00008c800 name: 'chatEngine'; group: 'system'; channel: 'chatEngine'; private: NO; asleep: NO; participants: 1>
Event payload: <CENMe:0x60b00001eff0 uuid: 'stephen'>
<ChatEngine::Debug> $.online.join ▸ <CENChat:0x60c00000d9c0 name: 'feed'; group: 'system'; channel: 'chatEngine#user#stephen#read.#feed'; private: NO; asleep: NO; participants: 1>
Event payload: <CENMe:0x60b00001eff0 uuid: 'stephen'>
<ChatEngine::Debug> $.online.join ▸ <CENChat:0x60c00000d240 name: 'direct'; group: 'system'; channel: 'chatEngine#user#stephen#write.#direct'; private: NO; asleep: NO; participants: 1>
Event payload: <CENMe:0x60b00001eff0 uuid: 'stephen'>
<ChatEngine::Debug> $.created.chat ▸ <CENChat:0x60c000082540 name: 'chat-history'; group: 'custom'; channel: 'chatEngine#chat#public.#chat-history'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.connected ▸ <CENChat:0x60c000082540 name: 'chat-history'; group: 'custom'; channel: 'chatEngine#chat#public.#chat-history'; private: NO; asleep: NO; participants: 0>.
<ChatEngine::Debug> $.online.join ▸ <CENChat:0x60c000082540 name: 'chat-history'; group: 'custom'; channel: 'chatEngine#chat#public.#chat-history'; private: NO; asleep: NO; participants: 1>
Event payload: <CENMe:0x60b00001eff0 uuid: 'stephen'>
```  

This is effectively the same as writing:  
```objc
[self.client handleEvent:@"*" withHandlerBlock:^(NSString *event, id emitterOrData, id parameters) {
    NSLog(@"<ChatEngine::Debug> %@ ▸ %@%@", event, emitterOrData, 
          parameters ? [@[@"\nEvent payload: ", parameters] componentsJoinedByString:@""] : @".");
}];
```

**IMPORTANT:** **This should not be enabled in production.**  It is very verbose and will have negative performance implications.  

## Increase logger verbosity

Along with [PubNub logger](https://www.pubnub.com/docs/ios-objective-c/pubnub-objective-c-troubleshooting-guide) it is possible to configure own ChatEngine logger to output information about used API or network requests to PubNub Function.  
You can change verbosity level like this:  
```objc
self.client.logger.enabled = YES;
[self.client.logger setLogLevel:CENVerboseLogLevel];
```
