/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENDummyWithPluggablePropertyStorageIgnoredFields.h"


#pragma mark Interface implementation

@implementation CENDummyWithPluggablePropertyStorageIgnoredFields


#pragma mark - Information

+ (NSArray<NSString *> *)nonbindableProperties {
    
    return @[@"strongString"];
}

#pragma mark -


@end
