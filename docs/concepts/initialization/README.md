Once you have access to the [CENChatEngine](../../api-reference/chatengine) object, use constructor 
to create a new instance of ChatEngine.

```objc
CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"mySubscribeKey" 
                                                                   subscribeKey:@"myPublishKey"];
self.client = [CENChatEngine clientWithConfiguration:configuration];
```