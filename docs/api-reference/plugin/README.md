# CEPPlugin

Base class for [CENObject](../object) plugins.  
Plugin developers should import class category (`<CENChatEngine/CEPPlugin+Developer.h>`) which 
provide interface with explanation about how plugin should be written.


## Properties

<a id="configuration"/>

[`@property NSDictionary *configuration`](#configuration)  
NSDictionary which is passed during plugin registration and will be passed by 
[CENChatEngine](../chatengine) during extension and/or middleware instantiation.  

<br/><a id="identifier"/>

[`@property (class) NSString *identifier`](#identifier)  
Unique plugin identifier. 


## Methods

<a id="extensionclassfor"/>

[`- (Class)extensionClassFor:(CENObject *)object`](#extensionclassfor)   
Get interface extension class for [object](../object).  
Depending from object type it is possible to setup different extensions by passing corresponding 
class in response.

### Parameters:

| Name     | Type                            | Description |
|:--------:|:-------------------------------:| ----------- |  
| `object` | [CENObject](../object) * | [Object](../object) for which interface extension requested.  |

### Returns:

Interface extension class or `nil` in case if plugin doesn't provide one for passed 
[object](../object).  


<br/><br/><a id="middlewareclassforlocation"/>

[`- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object`](#middlewareclassforlocation)
Get middleware class for [object](../object) at specified `location`.    
Depending from object type it is possible to setup different middleware for specified `location`. 
Available locations explained in [CEPMiddleware.location](../middleware#location).  

#### PARAMETERS

| Name       | Type                            | Description |
|:----------:|:-------------------------------:| ----------- |  
| `location` | NSString *                      | Location at which middleware expected to be used.  |   
|  `object`  | [CENObject](../object) * | [Object](../object) for which middleware at specified \c location requested  |

### Returns:

Middleware class or `nil` in case if plugin doesn't provide middleware for passed 
[object](../object) at specified `location`.



<br/><br/><a id="oncreate"/>

[`- (void)onCreate`](#oncreate)  
Handle plugin instantiation completion.  
Also, this handler is last place where configuration can be modified (for example default values is 
set) before it will be passed to [extensions](../extension) and 
[middleware](../middleware).   

### EXAMPLE

```objc
- (void)onCreate {
    
    // Set default values if nothing has been provided during plugin registration.
    if (!self.configuration.count) {
        self.configuration = @{ CENTypingIndicatorConfiguration.timeout: @(1.f) };
    }
}
```