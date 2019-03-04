# CEPExtension

[CENChatEngine](../chatengine) objects interface extension base class.  
Plugins which provide data objects extension support should bundle classes which is subclass of this
base class. 

Plugin developers should import class category (`<CENChatEngine/CEPExtension+Developer.h>`) which 
provide interface with explanation about how extension should be written.  

## Properties

<a id="configuration"/>

[`@property NSDictionary *configuration`](#configuration)  
`NSDictionary` which is passed during plugin registration and contain extension required 
configuration information.   

<br/><a id="identifier"/>

[`@property NSString *identifier`](#identifier)  
Unique identifier of plugin which instantiated this extension.    

<a id="object"/>

[`@property CENObject *object`](#object)  
[CENObject](../object) subclass instance for which extended interface has been provided.

## Methods

<a id="oncreate"/>

[`- (void)onCreate`](#oncreate)  
Handle extension instantiation and registration completion for specific [object](#object).  

### Example

Bellow is code from [unread messages](../../chat-plugins/unread-messages) plugin initialization completion:  
```objc
- (void)onCreate {

    __weak __typeof(self) weakSelf = self;
    self.eventHandlerBlock = ^(CENEmittedEvent *localEvent) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSDictionary *event = localEvent.data;
        
        [strongSelf handleEvent:event];
    };
    
    for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
        [self.object handleEvent:event withHandlerBlock:self.eventHandlerBlock];
    }
}
```

<br/><a id="ondestruct"/>

[`- (void)onDestruct`](#ondestruct)  
Handle extension destruction and unregister from specific [object](#object).    

### Example

Bellow is code from [unread messages](../../chat-plugins/unread-messages) plugin destruction:  
```objc
- (void)onDestruct {
    
    for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
        [self.object removeHandler:self.eventHandlerBlock forEvent:event];
    }
}
```