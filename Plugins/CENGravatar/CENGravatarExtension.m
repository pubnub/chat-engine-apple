/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENGravatarExtension.h"
#import <CommonCrypto/CommonDigest.h>
#import <CENChatEngine/CENObject+PluginsDeveloper.h>
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENMe+Interface.h>
#import "CENGravatarPlugin.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENGravatarExtension ()


#pragma mark - Information

/**
 * @brief  Stores reference on events handling block.
 * @note   Reference on block required to make it possible to remove it from event listeners.
 */
@property (nonatomic, copy, nullable) void(^eventHandlerBlock)(CENUser *user);


#pragma mark - Handlers

/**
 * @brief  Handle local user state change.
 *
 * @param user Reference on instance of user which changed his state.
 */
- (void)handleUserStateChange:(CENUser *)user;


#pragma mark - Misc

/**
 * @brief  Generate hash from email which is required by Gravatar REST API.
 *
 * @param email Reference on email from which hash should be created.
 *
 * @return Email address hash value.
 */
- (NSString *)hashFromEmail:(NSString *)email;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENGravatarExtension


#pragma mark - Handlers

- (void)onCreate {
    
    NSString *identifier = self.identifier;
    self.eventHandlerBlock = ^(CENUser * user) {
        [user extensionWithIdentifier:identifier context:^(CENGravatarExtension *extension) {
            [extension handleUserStateChange:user];
        }];
    };
    
    [self.object.chatEngine handleEvent:@"$.state" withHandlerBlock:self.eventHandlerBlock];
    [self handleUserStateChange:(CENUser *)self.object];
}

- (void)onDestruct {
    
    [self.object removeHandler:self.eventHandlerBlock forEvent:@"$.state"];
}

- (void)handleUserStateChange:(CENUser *)user {
    
    NSDictionary *userState = user.state;
    NSString *email = userState[self.configuration[CENGravatarPluginConfiguration.emailKey]];
    
    if (![user isKindOfClass:[CENMe class]] || !email) {
        return;
    }
    
    NSString *gravatarURL = [@"https://www.gravatar.com/avatar" stringByAppendingPathComponent:[self hashFromEmail:email]];
    
    // Check whether there is any need to update local user state information or not.
    if (![gravatarURL isEqualToString:userState[self.configuration[CENGravatarPluginConfiguration.gravatarURLKey]]]) {
        NSMutableDictionary *state = [NSMutableDictionary dictionaryWithDictionary:userState];
        state[self.configuration[CENGravatarPluginConfiguration.gravatarURLKey]] = gravatarURL;
        
        [(CENMe *)user updateState:state];
    }
}


#pragma mark - Misc

- (NSString *)hashFromEmail:(NSString *)email {
    
    const char *emailCString = [email UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(emailCString, (CC_LONG)strlen(emailCString), digest);
    
    NSMutableString *emailHash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [emailHash appendFormat:@"%02x", digest[i]];
    }
    
    return emailHash;
}

#pragma mark -


@end
