# CENOpenGraphPlugin

ChatEngine Open Graph unfurls URLs sent in chat messages and transforms them into more interactive 
pieces of media.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/OpenGraph'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENOpenGraphPlugin.h>
   ```

### Example

Setup with default configuration and application ID:
```objc
NSDictionary *configuration = @{
    CENOpenGraphConfiguration.appID: @"xxxxxxxxxxxxxxxxx"
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENOpenGraphPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENOpenGraphPlugin class])
        .configuration(configuration).store();
});
```

Setup with custom event text location, OpenGraph store location and events:
```objc
NSDictionary *configuration = @{
    CENOpenGraphConfiguration.appID: @"xxxxxxxxxxxxxxxxx",
    CENOpenGraphConfiguration.events: @[@"ping", @"pong", @"message"],
    CENRandomUsernameConfiguration.openGraphKey: @"attachment.openGraph"
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENOpenGraphPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENOpenGraphPlugin class])
        .configuration(configuration).store();
});
```

Access information added by plugin:
```objc
self.chat.on(@"message", ^(CENEmittedEvent *event) {
    NSDictionary *eventPayload = ((NSDictionary *)event.data)[CENEventData.data];
    NSDictionary *openGraphPayload = [eventPayload valueForKeyPath:@"attachment.openGraph"];

    if (openGraphPayload) {
        NSLog(@"Received OpenGraph object for %@\n\tTitle: %@\n\tDescription: %@\ntImage: %@",
            openGraphPayload[CENOpenGraphData.url],
            openGraphPayload[CENOpenGraphData.title],
            openGraphPayload[CENOpenGraphData.description],
            openGraphPayload[CENOpenGraphData.image]);
    }
});
```


### Parameters:

| Name           | Type                  | Attributes | Default         | Description |
|:--------------:|:---------------------:|:----------:|:---------------:| ----------- |
| `events`       | NSArray<NSString *> * |            | `@[@"message"]` | List of event names for which plugin should be used. |
| `appID`        | NSString *            |  Required  |                 | Unique application ID provided by [Open Graph](https://www.opengraph.io) after registration registration and used with Open Graph data processing API. |
| `messageKey`   | NSString *            |            | `text`          | Key or key-path in `data` payload where string which should be pre-processed. |
| `openGraphKey` | NSString *            |            | `openGraph`     | Key or key-path in `data` payload where received OpenGraph data will be stored. |

Each parameter is _field_ inside of `CENOpenGraphConfiguration` _typedef struct_.