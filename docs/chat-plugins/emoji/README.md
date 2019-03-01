# CENEmojiPlugin

Turns `:pizza:` into 🍕 within chats.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/Emoji'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENEmojiPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for every created chat.
self.client.proto(@"Chat", [CENEmojiPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENEmojiPlugin class]).store();
});
```

Setup with custom events and system emoji:
```objc
NSDictionary *configuration = @{
    CENEmojiConfiguration.events: @[@"ping", @"pong"],
    CENEmojiConfiguration.useNative: @YES
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENEmojiPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENEmojiPlugin class])
        .configuration(configuration).store();
});
```


### Parameters:

| Name         | Type                  | Default         | Description |
|:------------:|:---------------------:|:---------------:| ----------- |
| `events`     | NSArray<NSString *> * | `@[@"message"]` | List of event names for which plugin should be used.|
| `messageKey` | NSString *            | `text`          | Key or key-path in `data` payload where string which should be pre-processed. |
| `useNative`  | BOOL                  | `NO`            | Boolean which specify whether system emoji should be used during translation from text.<br/>Native Apple's emoji doesn't have representation for: `bowtie`, `octocat`, `squirrel`, `gun`, `neckbeard`, `feelsgood`, `finnadie`, `goberserk`, `godmode`, `hurtrealbad`, `rage1`, `rage2`, `rage3`, `rage4`, `suspect`, `trollface`, `shipit`.|
| `emojiURL`   | NSString *            | [`www.webpagefx.com`](https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis) | URL where emoji PNG images is stored.<br/>By default plugin uses `NSAttributedString` to render emoji images from their text representation. If required, it is possible to change host from which images is pulled out using this configuration property.|

Each parameter is _field_ inside of `CENEmojiConfiguration` _typedef struct_.


## Methods

<a id="emoji-from">

[`+ (NSString *)emojiFrom:(NSString *)string usingChat:(CENChat *)chat`](#emoji-from)  
Translate text emoji representation to native emoji (if enabled) or generate URL for remote emoji 
PNG download.  

### Parameters:

| Name     | Type                        | Attributes | Description |
|:--------:|:---------------------------:|:----------:| ----------- |  
| `string` | NSString *                  |  Required  | Stringified emoji representation for which visual representation should be retrieved. |
| `chat`   | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) which is used to get extension with proper configuration. |

### Returns:

URL or native emoji representation (if configured by setting `CENEmojiConfiguration.useNative` to 
`YES`).

### Example

```objc
/**
 * If 'CENEmojiConfiguration.useNative' set to NO, it will log out this URL:
 *     https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis/gift.png
 * or use value from native Emoji keyboard if value set to YES.
 */
NSLog(@"URL for ':gift:': %@", [CENEmojiPlugin emojiFrom:@":gift:" usingChat:self.chat]);
```


<br/><br/><a id="emoji-with-name">

[`+ (NSArray<NSString *> *)emojiWithName:(NSString *)name usingChat:(CENChat *)chat`](#emoji-with-name)  
Find emoji names which fully or partly match to passed `name`.  

### Parameters:

| Name   | Type                        | Attributes | Description |
|:------:|:---------------------------:|:----------:| ----------- |  
| `name` | NSString *                  |  Required  | Full or partial name of emoji which should be found. |
| `chat` | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) which is used to get extension with proper configuration. |

### Returns:

List of emoji names which match to passed `name`.

### Example

```objc
/**
 * This method call will log out all smile names which has 'smil' prefix in their name:
 *     :smile:, :smiley:, :smiling_imp:, :smiley_cat: and :smile_cat:.
 */
NSArray<NSString *> *emoji = [CENEmojiPlugin emojiWithName:@":smil" usingChat:self.chat];

NSLog(@"Emoji which starts with ':smil': %@", emoji);
```