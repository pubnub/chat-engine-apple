### Online List

A list of all the clients who have joined the chatroom is available from [Chat.users](reference-chat#users).  
```objc
NSLog(@"Users: %@", chat.users);
```  

It returns a list of [User](reference-user)s who have also joined this [Chat](reference-chat).  
```objc 
Users: {
    "serhii": <CENMe::0x000000 uuid: 'serhii'>,
    "nick": <CENUser::0x000000 uuid: 'nick'; state set: NO>,
}
```  

This property is kept in sync as [User](reference-user)s join and leave the [Chat](reference-chat)s.  

### Online Events

The list of  
* Any time a new [User](reference-user) joins, the [Chat](reference-chat) emits [$.online.join](reference-chat#event-online-join).
* When known [User](reference-user) came back online, the [Chat](reference-chat) will emit [$.online.here](reference-chat#event-online-here).  
```objc
chat.on(@"$.online.*", ^(NSString *event, CENUser *user) {
    NSLog(@"'%@' emitted for '%@'", event, user.uuid);
})
```  
