#import "CENChatEngine.h"


#pragma mark Class forward

@class CENSearch;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client interface for events searching.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Search)


- (CENSearch *)searchEventsInChat:(CENChat *)chat
                          sentBy:(nullable CENUser *)sender
                        withName:(nullable NSString *)event
                           limit:(NSInteger)limit
                           pages:(NSInteger)pages
                           count:(NSInteger)count
                           start:(nullable NSNumber *)start
                             end:(nullable NSNumber *)end;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
