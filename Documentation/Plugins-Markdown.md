# CENMarkdownPlugin

This plugin provide ability to pre-process received messages which contain [Markdown](https://daringfireball.net/projects/markdown/syntax) markup language elements to [NSAttributedString](https://developer.apple.com/documentation/foundation/nsattributedstring?language=objc) which can be UI components which is able to present attributed string.  

To make it easier to integrate into projects, plugin contains simplified [Markdown](https://daringfireball.net/projects/markdown/) parser which allow to send messages with following markup elements: _italic_, **bold**, `code`, [links](https://pubnub.com) and images.  
More advanced [Markdown](https://daringfireball.net/projects/markdown/) processors should be added as dependencies and add another `<library>.framework` which can be problem if [ChatEngine](reference-chatengine) is bundled inside of another library.

### Integration

To integrate plugin with you project, it should be added into **Podfile**:  
```ruby
pod 'CENChatEngine/Plugin/Markdown'
```

Next we need to integrate it into project by running following command:
```
pod install
```  

Now we can import plugin into class which is responsible for work with [ChatEngine](reference-chatengine) client:
```objc
// Import plugin.
#import <CENChatEngine/CENMarkdownPlugin.h>
```

### Configuration

Markdown plugin allow to customize fonts which should be used to known traits and keys from which data should be pulled out from message payload.  

Configuration dictionary root may contain data under keys specified in `CENMarkdownConfiguration` typedef described [here](reference-markdown-configuration).  

Default configuration shown below:
```objc
// iOS
@{
    CENMarkdownConfiguration.events: @[@"message"],
    CENMarkdownConfiguration.messageKey: @"text",
    CENMarkdownConfiguration.parserConfiguration: @{
        CENMarkdownParserElement.defaultAttributes: {
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14.f],
            NSForegroundColorAttributeName: [UIColor blackColor]
        },
        CENMarkdownParserElement.italicAttributes: {
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:14.f],
            NSForegroundColorAttributeName: [UIColor blackColor]
        },
        CENMarkdownParserElement.boldAttributes: {
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f],
            NSForegroundColorAttributeName: [UIColor blackColor]
        },
        CENMarkdownParserElement.strikethroughAttributes: {
            NSStrikethroughStyleAttributeName: @(NSUnderlineStyleThick)
        },
        CENMarkdownParserElement.linkAttributes: {
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14.f]
        },
        CENMarkdownParserElement.codeAttributes: {
            NSFontAttributeName: [UIFont fontWithName:@"Courier" size:14.f],
            NSBackgroundColorAttributeName: [UIColor lightGrayColor],
            NSForegroundColorAttributeName: [UIColor darkGrayColor]
        }
    }
}

// macOS
@{
    CENMarkdownConfiguration.events: @[@"message"],
    CENMarkdownConfiguration.messageKey: @"text",
    CENMarkdownConfiguration.parserConfiguration: @{
        CENMarkdownParserElement.defaultAttributes: {
            NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:14.f],
            NSForegroundColorAttributeName: [NSColor blackColor]
        },
        CENMarkdownParserElement.italicAttributes: {
            NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Italic" size:14.f],
            NSForegroundColorAttributeName: [NSColor blackColor]
        },
        CENMarkdownParserElement.boldAttributes: {
            NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:14.f],
            NSForegroundColorAttributeName: [NSColor blackColor]
        },
        CENMarkdownParserElement.strikethroughAttributes: {
            NSStrikethroughStyleAttributeName: @(NSUnderlineStyleThick)
        },
        CENMarkdownParserElement.linkAttributes: {
            NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:14.f]
        },
        CENMarkdownParserElement.codeAttributes: {
            NSFontAttributeName: [NSFont fontWithName:@"Courier" size:14.f],
            NSBackgroundColorAttributeName: [NSColor lightGrayColor],
            NSForegroundColorAttributeName: [NSColor darkGrayColor]
        }
    }
}
```

##### EXAMPLE

```objc
NSDictionary *configuration = @{
    CENMarkdownConfiguration.messageKey: @"msg",
    CENMarkdownConfiguration.parserConfiguration: @{
        CENMarkdownParserElement.italicAttributes: @{
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.f],
            NSForegroundColorAttributeName: [UIColor lightGrayColor]
        }
    }
};
```


### Register plugin

Plugin can be registered for specific [Chat](reference-chat) instance or for all [Chat](reference-chat) instances created by client (as proto plugin). More about plugins registration explained [here](concepts-plugins).  

In example we will register plugin for [global](reference-chatengine#global) chat for simplicity with some non-default [configuration](#configuration):  
```objc
NSDictionary *configuration = @{ 
    CENMarkdownConfiguration.events: @[@"announcement"], 
    CENMarkdownConfiguration.messageKey: @"msg" 
};

self.client.on(@"$.ready", ^(CENMe *me) {
    self.client.global.plugin([CENMarkdownPlugin class])
        .configuration(configuration).store();
});
```  

After registration, we can listen for registered `announcement` events and use UI component to show formatted message:  
```objc
self.client.global.on(@"announcement", ^(NSDictionary *payload) {
    id announcement = payload[CENEventData.data][@"msg"];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([announcement isKindOfClass:[NSAttributedString class]]) {
            self.popUpTextView.attributedText = announcement;
        } else {
            /**
             * Print out plain string because published message didn't have
             * Markdown markup in it. 
             */
            self.popUpTextView.text = announcement;
        }
    });
});

// This will be ignored by Markdown plugin because of unknown event: message.
self.client.global.emit(@"message")
    .data(@{ @"msg": @"**Bold** text" }).perform();

/**
 * This will be accepted but not processed, because string doesn't contain 
 * Markdown markup.
 */
self.client.global.emit(@"announcement")
    .data(@{ @"msg": @"Simple text" }).perform();

// This will be accepted and processed.
self.client.global.emit(@"announcement")
    .data(@{ @"msg": @"Powered by [PubNub](https://pubnub.com)" }).perform();
```