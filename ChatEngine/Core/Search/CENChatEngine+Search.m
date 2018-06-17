/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Private.h"
#import "CENChatEngine+Search.h"
#import "CENSearch+Private.h"
#import "CENChat.h"


#pragma mark Interface implementation

@implementation CENChatEngine (Search)

- (CENSearch *)searchEventsInChat:(CENChat *)chat
                          sentBy:(CENUser *)sender
                        withName:(NSString *)event
                           limit:(NSInteger)limit
                           pages:(NSInteger)pages
                           count:(NSInteger)count
                           start:(NSNumber *)start
                             end:(NSNumber *)end {
    
    if (![chat isKindOfClass:[CENChat class]]) {
        return nil;
    }
    
    CENSearch *search = [CENSearch searchForEvent:event
                                         inChat:chat
                                         sentBy:sender
                                      withLimit:limit
                                          pages:pages
                                          count:count
                                          start:start
                                            end:end
                                     chatEngine:self];
    
    [self storeTemporaryObject:search];
    
    return search;
}

#pragma mark -


@end
