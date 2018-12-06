/**
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENGravatarExtension.h"
#import <CommonCrypto/CommonDigest.h>
#import <CENChatEngine/CENObject+PluginsDeveloper.h>
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENUser+Interface.h>
#import <CENChatEngine/CENMe+Interface.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENGravatarPlugin.h"


#pragma mark Contants

/**
 * @brief Gravatar API endpoint URI.
 *
 * @since 1.1.0
 */
static NSString * const kCENGravatarAPI = @"https://www.gravatar.com/avatar";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENGravatarExtension ()


#pragma mark - Information

/**
 * @brief Events handling block.
 */
@property (nonatomic, copy, nullable) CENEventHandlerBlock eventHandlerBlock;


#pragma mark - Handlers

/**
 * @brief Handle local user state change.
 *
 * @param user \b {User CENUser} which changed his state.
 */
- (void)handleUserStateChange:(CENUser *)user;


#pragma mark - Misc

/**
 * @brief Generate hash from email which is required by Gravatar REST API.
 *
 * @param email Email address from which hash should be created.
 *
 * @return Email address hash value.
 */
- (NSString *)hashFromEmail:(NSString *)email;

/**
 * @brief Update value in \c dictionary.
 *
 * @param value Object which should be stored at specified location.
 * @param keyPath Key or path to location where \c value should be stored.
 * @param dictionary \a NSMutableDictionary with mutable content which should be modified.
 */
- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary;

/**
 * @brief Create mutable copy from \a NSDictionary by replacing other \a NSDictionary values in it
 * with \a NSMutableDictionary.
 *
 * @param dictionary \a NSDictionary from which deep mutable copy should be created.
 *
 * @return Mutable dictionary with mutable content.
 *
 * @since 1.1.0
 */
- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENGravatarExtension


#pragma mark - Handlers

- (void)onCreate {
    
    __weak __typeof(self) weakSelf = self;
    self.eventHandlerBlock = ^(CENEmittedEvent *event) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        CENUser *user = event.data;
        
        [strongSelf handleUserStateChange:user];
    };
    
    [self.object.chatEngine handleEvent:@"$.state" withHandlerBlock:self.eventHandlerBlock];
    [self handleUserStateChange:(CENUser *)self.object];
}

- (void)onDestruct {
    
    [self.object.chatEngine removeHandler:self.eventHandlerBlock forEvent:@"$.state"];
}

- (void)handleUserStateChange:(CENUser *)user {
    
    NSString *gravatarKey = self.configuration[CENGravatarPluginConfiguration.gravatarURLKey];
    NSString *emailKey = self.configuration[CENGravatarPluginConfiguration.emailKey];
    CENChat *chat = self.configuration[CENGravatarPluginConfiguration.chat];
    NSDictionary *userState = [user stateForChat:chat] ?: @{};
    NSString *email = [userState valueForKeyPath:emailKey];
    
    if (![user isKindOfClass:[CENMe class]] || !email) {
        return;
    }
    
    NSString *hash = [self hashFromEmail:email];
    NSString *gravatarURL = [@[kCENGravatarAPI, hash] componentsJoinedByString:@"/"];
    
    // Check whether there is any need to update local user state information or not.
    if (![gravatarURL isEqualToString:[userState valueForKeyPath:gravatarKey]]) {
        NSMutableDictionary *state = [self dictionaryDeepMutableFrom:userState];
        [self setValue:gravatarURL forKeyPath:gravatarKey inDictionary:state];
        
        [(CENMe *)user updateState:state forChat:chat];
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

- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary {
    
    NSArray<NSString *> *pathComponents = [keyPath componentsSeparatedByString:@"."];
    
    if (pathComponents.count > 1) {
        NSRange pathSubRange = NSMakeRange(0, pathComponents.count - 1);
        NSArray *pathSubComponents = [pathComponents subarrayWithRange:pathSubRange];
        NSMutableDictionary *currentRoot = dictionary;
        
        for (NSString *key in pathSubComponents) {
            if (!currentRoot[key]) {
                currentRoot[key] = [NSMutableDictionary new];
            }
            
            currentRoot = currentRoot[key];
        }
        
        [currentRoot setValue:value forKeyPath:pathComponents.lastObject];
    } else {
        [dictionary setValue:value forKeyPath:keyPath];
    }
}

- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary {
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    for (NSString *key in dictionary) {
        if ([dictionary[key] isKindOfClass:[NSDictionary class]]) {
            mutable[key] = [self dictionaryDeepMutableFrom:dictionary[key]];
        }
    }
    
    return mutable;
}

#pragma mark -


@end
