/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENOnlineUserSearchPlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENOnlineUserSearchExtension.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENOnlineUserSearchConfigurationKeys CENOnlineUserSearchConfiguration = {
    .caseSensitive = @"cs",
    .propertyName = @"pn"
};


#pragma mark - Interface implementation

@implementation CENOnlineUserSearchPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.online-user-search";
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENOnlineUserSearchExtension class];
    }
    
    return extensionClass;
}

+ (NSArray<CENUser *> *)search:(NSString *)criteria inChat:(CENChat *)chat {

    CENOnlineUserSearchExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    return [extension usersMatchingCriteria:criteria];
}

+ (void)search:(NSString *)criteria
            inChat:(CENChat *)chat
    withCompletion:(void(^)(NSArray<CENUser *> *))block {

    CENOnlineUserSearchExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    block([extension usersMatchingCriteria:criteria]);
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    
    if (!configuration[CENOnlineUserSearchConfiguration.propertyName]) {
        configuration[CENOnlineUserSearchConfiguration.propertyName] = @"uuid";
    }
    
    if (!configuration[CENOnlineUserSearchConfiguration.caseSensitive]) {
        configuration[CENOnlineUserSearchConfiguration.caseSensitive] = @NO;
    }
    
    self.configuration = configuration;
}

#pragma mark -


@end
