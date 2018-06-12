/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Publish.h"
#import "CENChatEngine+PluginsPrivate.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+Private.h"
#import "CENChatEngine+User.h"
#import "CENEvent+Private.h"
#import "CENErrorCodes.h"
#import "CENStructures.h"
#import "CENConstants.h"
#import "CENChat.h"
#import "CENMe.h"


#pragma mark Interface implementation

@implementation CENChatEngine (Publish)

- (CENEvent *)publishToChat:(CENChat *)chat eventWithName:(NSString *)eventName data:(NSDictionary *)data {
    
    data = data ?: @{};
    if (![data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: @"The payload should be instance of NSDictionary" };
        NSError *error = [NSError errorWithDomain:kCEErrorDomain code:kCEMalformedPayloadError userInfo:errorInformation];
        
        @throw [NSException exceptionWithName:@"ChatEngine Exception" reason:error.localizedDescription userInfo:@{ NSUnderlyingErrorKey: error }];
    }
    
    NSString *eventID = [NSUUID UUID].UUIDString;
    CENEvent *tracer = [CENEvent eventWithName:eventName chat:chat chatEngine:self];
    NSDictionary *payload = @{
        CENEventData.data: data,
        CENEventData.sender: self.me.uuid,
        CENEventData.chat: chat,
        CENEventData.event: eventName,
        CENEventData.eventID: eventID,
        CENEventData.sdk: [@"objc/" stringByAppendingString:kCELibraryVersion]
    };
    
    [self storeTemporaryObject:tracer];
    [self runMiddlewaresAtLocation:@"emit" forEvent:eventName object:chat withPayload:payload
                        completion:^(__unused BOOL rejected, NSMutableDictionary *processedData) {
        [processedData removeObjectForKey:CENEventData.chat];
        [tracer publish:processedData];
    }];
    
    return tracer;
}

- (void)publishStorable:(BOOL)shouldStoreInHistory
                  event:(CENEvent *)event
              toChannel:(NSString *)channel
               withData:(NSDictionary *)data
             completion:(void(^)(NSNumber *))block {
    
    [self publishStorable:shouldStoreInHistory data:data toChannel:channel withCompletion:^(PNPublishStatus *status) {
        if (status.isError) {
            NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: status.errorData.information };
            NSError *error = [NSError errorWithDomain:kCEPNErrorDomain code:kCEPublishError userInfo:errorInformation];
            
            [self throwError:error forScope:@"emitter" from:event propagateFlow:CEExceptionPropagationFlow.direct];
            
            return;
        }
        
        block(status.data.timetoken);
    }];
}

@end
