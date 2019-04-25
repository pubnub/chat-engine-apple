# CENMarkdownConfiguration

[Markdown](plugins-markdown) plugin allow to configure set of options which described in `CENMarkdownConfiguration` typedef.  


<a id="configuration-events"/>

[`CENMarkdownConfiguration.events`](#configuration-events)  
Value passed for this configuration key represent list of event names for which markdown should process received payload.  

<a id="configuration-messagekey"/>

[`CENMarkdownConfiguration.messageKey`](#configuration-messagekey)  
Name of key under which stored string in event [data payload](reference-event-data#eventdata-data). After pre-processing, updated value will replace data at specified key.

<a id="configuration-parserconfiguration"/>

[`CENMarkdownConfiguration.parserConfiguration`](#configuration-parserconfiguration)  
Dictionary passed for this key contain information about custom formatting of traits. Each trait stores reference on dictionary which contain same values which is required to configure layout in [NSAttributedString](https://developer.apple.com/documentation/foundation/nsattributedstring?language=objc).  
Subkeys described in `CENMarkdownParserElement` typedef [here](reference-markdown-parser-element).  

##### EXAMPLE

```objc
@{
    CENMarkdownConfiguration.parserConfiguration: @{
        CENMarkdownParserElement.italicAttributes: @{
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.f],
            NSForegroundColorAttributeName: [UIColor lightGrayColor]
        }
    }
};
```