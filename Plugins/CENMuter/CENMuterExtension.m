/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENUser.h>
#import "CENMuterExtension.h"
#import "CENMuterPlugin.h"


#pragma mark Protected interface declaration

@interface CENMuterExtension ()


#pragma mark - Information

/**
 * @brief Set of users which has been silenced by chat local user.
 */
@property (nonatomic, strong) NSMutableSet<CENUser *> *muted;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENMuterExtension


#pragma mark - Extension

- (void)muteUser:(CENUser *)user {
    
    [self.muted addObject:user];
}

- (void)unmuteUser:(CENUser *)user {
    
    [self.muted removeObject:user];
}

- (BOOL)isMutedUser:(CENUser *)user {
    
    return [self.muted containsObject:user];
}


#pragma mark - Handlers

- (void)onCreate {
    
    self.muted = [NSMutableSet new];
}

#pragma mark -


@end
