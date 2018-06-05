/**
 *@author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENSearch.h"


#pragma mark Class forward

@class CENChatEngine, CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENSearch (Private)


#pragma mark - Initialization and Configuration

+ (nullable instancetype)searchForEvent:(nullable NSString *)event
                                 inChat:(CENChat *)chat
                                 sentBy:(nullable CENUser *)sender
                              withLimit:(NSInteger)limit
                                  pages:(NSInteger)pages
                                  count:(NSInteger)count
                                  start:(nullable NSNumber *)start
                                    end:(nullable NSNumber *)end
                             chatEngine:(CENChatEngine *)chatEngine;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
