# CENMarkdownPlugin

Markdown is used for _formatting_ **important** text and code examples. The ChatEngine Markdown 
plugin enables Markdown rendering in chat messages.

This plugin provide ability to pre-process received messages which contain 
[Markdown](https://daringfireball.net/projects/markdown/syntax) markup language elements to 
[NSAttributedString](https://developer.apple.com/documentation/foundation/nsattributedstring?language=objc) 
which can be UI components which is able to present attributed string.  

To make it easier to integrate into projects, plugin contains simplified 
[Markdown](https://daringfireball.net/projects/markdown/) parser which allow to send messages with 
following markup elements: _italic_, **bold**, `code`, [links](https://pubnub.com) and images.  


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/Markdown'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENMarkdownPlugin.h>
   ```

### Example

Setup with default configuration:
```objc
// Register plugin for every created chat.
self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENMarkdownPlugin class]).store();
});
```

Setup with custom events and bold font:
```objc
NSDictionary *configuration = @{ 
    CENMarkdownConfiguration.events: @[@"ping", @"pong"],  
    CENMarkdownConfiguration.parserConfiguration: @{
        CENMarkdownParserElement.boldAttributes: @{
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f],
            NSForegroundColorAttributeName: [UIColor redColor]
        }
    }
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENMarkdownPlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENMarkdownPlugin class])
        .configuration(configuration).store();
});
```

Access information added by plugin:
```objc
self.chat.on(@"message", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    
    if ([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]) {
        // Use attributed string created from string with Markdown markup.
    } else {
        // There was no Markdown markup in received event.
    }
});
```


### Parameters:

| Name                  | Type                      | Default         | Description |
|:---------------------:|:-------------------------:|:---------------:| ----------- |
| `events`              | NSArray<NSString *> *     | `@[@"message"]` | List of event names for which plugin should be used.|
| `messageKey`          | NSString *                | `text`          | Key or key-path in `data` payload where string with Markdown markup is stored.|
| `parsedMessageKey`    | NSString *                | `text`          | Key or key-path in `data` payload where processed data will be stored. |
| `parser`              | CENMarkdownParserCallback | `nil`           | Block / closure which can be used to call own Markdown markup processor.<br/>Block / closure aside of message with Markdown markup will pass reference on processing completion block / closure which will expect for processed data. Resulting data by default will replace original (if `parsedMessageKey` not configured).|
| `parserConfiguration` | NSDictionary *            | `nil`           | Dictionary with bundled `CENMarkdownParser` configuration options described by `CENMarkdownParserElement` _typedef struct_. |

Each parameter is _field_ inside of `CENMarkdownConfiguration` _typedef struct_.

Bundled parser configuration parameters:

| Name                      | Type           | Default         | Description |
|:-------------------------:|:--------------:|:---------------:| ----------- |
| `defaultAttributes`       | NSDictionary * | `Black 'Helvetica Neue 14'` | Dictionary with [NSAttributedStringKey](https://developer.apple.com/documentation/foundation/nsattributedstringkey?language=objc) keys and values which specify layout for text with out any markup on it.<br/>Should include value for [NSFontAttributeName](https://developer.apple.com/documentation/uikit/nsfontattributename?language=objc) because this font will be used by rest elements. |
| `italicAttributes`        | NSDictionary * | `Helvetica Neue Italic 14` | Dictionary with [NSAttributedStringKey](https://developer.apple.com/documentation/foundation/nsattributedstringkey?language=objc) keys and values which specify layout for text with italic emphasis markup on it (elements which is enclosed into pairs `_` or `*`).<br/>May contain any properties except [NSFontAttributeName](https://developer.apple.com/documentation/uikit/nsfontattributename?language=objc) (this value will be taken from `defaultAttributes`). |
| `boldAttributes`          | NSDictionary * | `Helvetica Neue Bold 14` | Dictionary with [NSAttributedStringKey](https://developer.apple.com/documentation/foundation/nsattributedstringkey?language=objc) keys and values which specify layout for text with bold emphasis markup on it (elements which is enclosed into pairs `__` or `**`).<br/>May contain any properties except [NSFontAttributeName](https://developer.apple.com/documentation/uikit/nsfontattributename?language=objc) (this value will be taken from `defaultAttributes`). |
| `strikethroughAttributes` | NSDictionary * | `Helvetica Neue 14` | Dictionary with [NSAttributedStringKey](https://developer.apple.com/documentation/foundation/nsattributedstringkey?language=objc) keys and values which specify layout for text with strikethrough emphasis markup on it (elements which is enclosed into pairs `~` or `~~`).<br/>May contain any properties except [NSFontAttributeName](https://developer.apple.com/documentation/uikit/nsfontattributename?language=objc) (this value will be taken from `defaultAttributes`). |
| `linkAttributes`          | NSDictionary * | `Helvetica Neue 14` | Dictionary with [NSAttributedStringKey](https://developer.apple.com/documentation/foundation/nsattributedstringkey?language=objc) keys and values which specify layout for text link markup on it.<br/>Attributes for link may specify [NSForegroundColorAttributeName](https://developer.apple.com/documentation/uikit/nsforegroundcolorattributename?language=objc), but it can be ignored by element which is used to represent `Markdown` formatted string.<br/>May contain any properties except [NSFontAttributeName](https://developer.apple.com/documentation/uikit/nsfontattributename?language=objc) (this value will be taken from `defaultAttributes`). |
| `codeAttributes`          | NSDictionary * | `Dark gray 'Courier 14' with light gray background` | Dictionary with [NSAttributedStringKey](https://developer.apple.com/documentation/foundation/nsattributedstringkey?language=objc) keys and values which specify layout for text with inline code markup on it (elements which is enclosed into pairs \` or \`\`).<br/>May contain any properties except [NSFontAttributeName](https://developer.apple.com/documentation/uikit/nsfontattributename?language=objc) (this value will be taken from `defaultAttributes`). |

Each parameter is _field_ inside of `CENMarkdownParserElement` _typedef struct_.