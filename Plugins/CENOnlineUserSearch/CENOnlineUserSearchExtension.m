/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENOnlineUserSearchExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import "CENOnlineUserSearchPlugin.h"
#import <CENChatEngine/CENChat.h>
#import <CENChatEngine/CENUser.h>


#pragma mark Interface implementation

@implementation CENOnlineUserSearchExtension


#pragma mark - Search

- (NSArray<CENUser *> *)usersMatchingCriteria:(NSString *)criteria {

    NSString *propertyName = self.configuration[CENOnlineUserSearchConfiguration.propertyName];
    NSString *propertyNameRootPath = [propertyName componentsSeparatedByString:@"."].firstObject;
    NSNumber *caseSensitive = self.configuration[CENOnlineUserSearchConfiguration.caseSensitive];
    NSDictionary<NSString *, CENUser *> *users = ((CENChat *)self.object).users;
    NSMutableArray<CENUser *> *filteredUsers = [NSMutableArray new];
    BOOL isState = [propertyNameRootPath isEqualToString:@"state"];

    if (isState) {
        NSUInteger nameLocation = [propertyName rangeOfString:@"."].location + 1;
        propertyName = [propertyName substringFromIndex:nameLocation];
    }

    if (!caseSensitive.boolValue) {
        criteria = criteria.lowercaseString;
    }

    for (NSString *uuid in users) {
        CENUser *user = users[uuid];
        NSString *data = nil;

        if (isState) {
            data = [user.state valueForKeyPath:propertyName];
        } else {
            data = [user valueForKey:propertyName];
        }

        if (!caseSensitive.boolValue) {
            data = data.lowercaseString;
        }

        if (data && [data rangeOfString:criteria].location != NSNotFound) {
            [filteredUsers addObject:user];
        }
    }

    return filteredUsers;
}

- (void)searchFor:(NSString *)criteria withCompletion:(void(^)(NSArray<CENUser *> *users))block {

    block([self usersMatchingCriteria:criteria]);
}

#pragma mark -


@end
