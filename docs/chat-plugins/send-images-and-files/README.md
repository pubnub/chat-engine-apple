# CENUploadcarePlugin

Uses [UploadCare](https://uploadcare.com) service to upload images and render them in chats.


## Requires

Following actions required to complete plugin integration:
1. Addition to **Podfile**:  
   ```ruby
   pod 'CENChatEngine/Plugin/Uploadcare'
   pod 'Uploadcare'
   ```
2. Added dependency installation:  
   ```text
   pod install
   ```
3. Import plugin into class which is responsible for work with [CENChatEngine](../../api-reference/chatengine) 
   client:  
   ```objc
   #import <CENChatEngine/CENUploadcarePlugin.h>
   #import <Uploadcare/Uploadcare.h>
   ```
4. Follow UploadCare [installation guide](https://github.com/uploadcare/uploadcare-ios#install).

### Example

```objc
NSDictionary *configuration = @{
    CENUploadcareConfiguration.publicKey: @"xxxxxxxxxxxxxxxxx"
};

// Register plugin for every created chat.
self.client.proto(@"Chat", [CENUploadcarePlugin class])
    .configuration(configuration).store();

// or register plugin for particular chat (global), when CENChatEngine will be ready.
self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
    self.client.global.plugin([CENUploadcarePlugin class])
        .configuration(configuration).store();
});
```


### Parameters:

| Name        | Type       | Attributes | Description |
|:-----------:|:----------:| ---------- | ----------- |
| `publicKey` | NSString * |  Required  | Application public key provided available in [Uploadcare Dashboard](https://uploadcare.com/dashboard/) after registration and used with Uploadcare Upload API. |

Each parameter is _field_ inside of `CENUploadcareConfiguration` _typedef struct_.


## Methods

<a id="share-file">

[`+ (void)shareFileWithIdentifier:(NSString *)identifier toChat:(CENChat *)chat`](#share-file)  
Fetch information about [Uploadcare](https://uploadcare.com) file and send it to 
[chat](../../api-reference/chat).  

### Parameters:

| Name         | Type                        | Attributes | Description |
|:------------:|:---------------------------:|:----------:| ----------- |  
| `identifier` | NSString *                  |  Required  | Unique identifier of file uploaded to [Uploadcare](https://uploadcare.com). |
| `chat`       | [CENChat](../../api-reference/chat) * |  Required  | [Chat](../../api-reference/chat) to which file information should be sent. |

### Example

```objc
// This method should be called from UploadCare file share completion handler.
UCMenuViewController *menu = nil;
menu = [[UCMenuViewController alloc] initWithProgress:^(NSUInteger sent, NSUInteger total) {
    // Handle progress here
} completion:^(NSString *fileId, id response, NSError *error) {
    if (!error) {
        [CENUploadcarePlugin shareFileWithIdentifier:fileId toChat:self.chat];
    }
}];

[menu presentFrom:self];
```


## Events

<a id="event-uploadcare-upload"/>

**[`$uploadcare.upload`](#event-uploadcare-upload)**  
Notify locally when received information about [Uploadcare](https://uploadcare.com) file which has 
been shared by remote user.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$uploadcare.upload`        | Name of handled event. |
| `emitter` | id         | [CENChat](../../api-reference/chat) * | Object, which emitted local event. In this case it will be `self.chat` since handler added to listen [chat](../../api-reference/chat) emitted events. |
| `data`    | id         | [CENUploadcareFileInformation](#cenuploadcarefileinformation) | Payload with event, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.chat.on(@"$uploadcare.upload", ^(CENEmittedEvent *event) {
    CENUploadcareFileInformation *info = ((NSDictionary *)event.data)[CENEventData.data];

    NSLog(@"Received file which can be downloaded from: %@", info.url);
});
```


## CENUploadcareFileInformation

Information about [Uploadcare](https://uploadcare.com) file represented by 
`CENUploadcareFileInformation` instance.


### Properties

<a id="property-uuid"/>

[`@property NSString *uuid`](#property-uuid)  
Uploaded file unique identifier.

<br/><a id="property-name"/>

[`@property NSString *name`](#property-name)  
Name of file which has or will be uploaded.

<br/><a id="property-size"/>

[`@property NSNumber *size`](#property-size)  
Size of uploaded file in bytes.

<br/><a id="property-is-stored"/>

[`@property BOOL isStored`](#property-is-stored)  
Whether uploaded files has been stored persistently or not.

<br/><a id="property-is-image"/>

[`@property BOOL isImage`](#property-is-image)  
Whether image file has been uploaded or not.

<br/><a id="property-url"/>

[`@property NSURL *url`](#property-url)  
Public file CDN URL which may contain [CDN operations](https://uploadcare.com/docs/delivery/).

<br/><a id="property-url-modifiers"/>

[`@property NSString *urlModifiers`](#property-url-modifiers)  
URL part with applied [CDN operations](https://uploadcare.com/docs/delivery/) or `null`.

<br/><a id="property-original-url"/>

[`@property NSURL *originalURL`](#property-original-url)  
Public file CDN URL without any operations.

<br/><a id="property-width"/>

[`@property NSNumber *width`](#property-width)  
Original image width.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-height"/>

[`@property NSNumber *height`](#property-height)  
Original image height.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-file-format"/>

[`@property NSString *format`](#property-file-format)  
Original image file format.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-latitude"/>

[`@property NSNumber *latitude`](#property-latitude)  
Original image EXIF latitude.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-longitude"/>

[`@property NSNumber *longitude`](#property-longitude)  
Original image EXIF longitude.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-orientation"/>

[`@property NSString *orientation`](#property-orientation)  
Original image EXIF orientation.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-creation-date"/>

[`@property NSDate *date`](#property-creation-date)  
Original image EXIF creation date.  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).

<br/><a id="property-resolution"/>

[`@property NSArray<NSNumber *> *resolution`](#property-resolution)  
Information about image resolution (DPI).  

**Note:** Information available only if image file has been uploaded ([`isImage`](#property-is-image)).
