/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENEvent.h"


#pragma mark Class forward

@class CENChatEngine, CENChat;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENEvent (Private)


#pragma mark - Initialization and Configuration

+ (instancetype)eventWithName:(NSString *)event chat:(CENChat *)chat chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Publishing

- (void)publish:(NSMutableDictionary *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
