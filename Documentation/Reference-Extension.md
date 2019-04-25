# CEPExtension

Extension is part of plugin package which provide extension to ChatEngine objects functionality.  

Only developer category on this class provide functionality. These methods should be used by plugin developer to provide client with required information about how it should be used.  

### Properties

<a id="configuration"/>

[`@property NSDictionary *configuration`](#configuration)  
Dictionary which is passed during plugin registration and may contain extension configuration information.   

<a id="object"/>

[`@property CENObject *object`](#object)  
Object for which extended interface has been provided.  

<br/><a id="identifier"/>

[`@property NSString *identifier`](#identifier)  
Unique identifier of plugin which instantiated this extension.  

### Methods

<a id="oncreate"/>

[`- (void)onCreate`](#oncreate)  
Extension initialization completion handler. This method will be called by ChatEngine plugins system when right after extension has been registered with [object](#object).  

This method called from within extension context block and it is safe to get access to [object](#object) for which it has been registered and [configuration](reference-plugin#configuration) with which plugin has been registered.  

#### EXAMPLE

Bellow is code from [unread messages](plugins-unread-messages) plugin initialization completion:  
```objc
- (void)onCreate {
    
    NSString *identifier = self.identifier;
    __weak __typeof__(self) weakSelf = self;
    
    self.eventHandlerBlock = ^(NSDictionary *event) {
        CENChat *chat = event[CENEventData.chat];
        
        [chat extensionWithIdentifier:identifier
                              context:^(CENUnreadMessagesExtension *extension) {

            [weakSelf handleEvent:event];
        }];
    };
}
```

<br/><a id="ondestruct"/>

[`- (void)onDestruct`](#ondestruct)  
Extension destruction handler. This method will be called by ChatEngine plugins system right before extension removal from [object](#object).

This method called from within extension context block and it is safe to get access to [object](#object) for which it has been registered before and [configuration](reference-plugin#configuration) with which plugin has been registered.  

#### EXAMPLE

Bellow is code from [unread messages](plugins-unread-messages) plugin destruction:  
```objc
- (void)onDestruct {
    
    for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
        [self.object removeHandler:self.eventHandlerBlock forEvent:event];
    }
}
```