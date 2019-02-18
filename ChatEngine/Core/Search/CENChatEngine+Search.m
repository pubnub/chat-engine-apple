/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+Private.h"
#import "CENChatEngine+Search.h"
#import "CENSearch+Private.h"
#import "CENChat.h"


#pragma mark Interface implementation

@implementation CENChatEngine (Search)


#pragma mark - Search

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
    
    // By default restore event sender's state using global chat (pre-0.10.0).
    [search restoreStateForChat:nil];
    
    return search;
}

#pragma mark -


@end
