# CENMarkdownParserElement

[Markdown](plugins-markdown) plugin parser allow to specify layout of different traits by specifying font, colors and other options available in [NSAttributedString](https://developer.apple.com/documentation/foundation/nsattributedstring?language=objc).  

<br/><a id="element-default"/>

[`CENMarkdownParserElement.defaultAttributes`](#element-default)  
Dictionary passed for this key represent default text layout and used by plugin to set defaults for other traits layout. Passed dictionary should contain UIFont instance for `NSFontAttributeName` key.  
Provided attributes will be applied on all text which not enclosed into markdown [markup elements](https://daringfireball.net/projects/markdown/syntax).  

<a id="element-italicattributes"/>

[`CENMarkdownConfiguration.italicAttributes`](#element-italicattributes)  
Dictionary passed for this key allow to specify layout for elements which is enclosed into pairs `_` or `*` (suffixed with same chars as suffix) markup elements and represent italic text.  

<a id="element-boldttributes"/>

[`CENMarkdownConfiguration.boldAttributes`](#element-boldttributes)  
Dictionary passed for this key allow to specify layout for elements which is enclosed into pairs `__` or `**` (suffixed with same chars as suffix) markup elements and represent bold text.  

<a id="element-strikethroughattributes"/>

[`CENMarkdownConfiguration.strikethroughAttributes`](#element-boldttributes)  
Dictionary passed for this key allow to specify layout for elements which is enclosed into pairs `~` or `~~` (suffixed with same chars as suffix) markup elements and represent strikethrough decoration. This dictionary should contain only information about strikethrough decoration layout (`NSFontAttributeName` will be ignored).  

<a id="element-linkattributes"/>

[`CENMarkdownConfiguration.linkAttributes`](#element-linkattributes)  
Dictionary passed for this key allow to specify layout for elements which use link markup elements. `NSFontAttributeName` will be taken from [CENMarkdownParserElement.defaultAttributes](#element-default). Link color should be specified using properties of UI component which will layout attributed string.  

<a id="element-codeattributes"/>

[`CENMarkdownConfiguration.codeAttributes`](#element-codeattributes)  
Dictionary passed for this key allow to specify layout for elements which is enclosed into pairs ` or `` (suffixed with same chars as suffix) markup elements and represent code.  