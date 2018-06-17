/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENOnlineUserSearchExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import "CENOnlineUserSearchPlugin.h"
#import <CENChatEngine/CENChat.h>
#import <CENChatEngine/CENUser.h>


#pragma mark Interface implementation

@implementation CENOnlineUserSearchExtension


#pragma mark - Search

- (void)searchFor:(NSString *)criteria withCompletion:(void(^)(NSArray<CENUser *> *users))block {
    
    NSString *propertyName = self.configuration[CENOnlineUserSearchConfiguration.propertyName];
    BOOL isState = [[propertyName componentsSeparatedByString:@"."].firstObject isEqualToString:@"state"];
    NSDictionary<NSString *, CENUser *> *users = ((CENChat *)self.object).users;
    NSMutableArray<CENUser *> *filteredUsers = [NSMutableArray new];
    
    if (isState) {
        propertyName = [propertyName substringFromIndex:([propertyName rangeOfString:@"."].location + 1)];
    }
    
    if (!((NSNumber *)self.configuration[CENOnlineUserSearchConfiguration.caseSensitive]).boolValue) {
        criteria = criteria.lowercaseString;
    }
    
    for (NSString *uuid in users) {
        CENUser *user = users[uuid];
        NSString *data = !isState ? [user valueForKey:propertyName] : [user.state valueForKeyPath:propertyName];
        
        if (!((NSNumber *)self.configuration[CENOnlineUserSearchConfiguration.caseSensitive]).boolValue) {
            data = data.lowercaseString;
        }
        
        if (data && [data rangeOfString:criteria].location != NSNotFound) {
            [filteredUsers addObject:user];
        }
    }
    
    block(filteredUsers);
}

#pragma mark -


@end
