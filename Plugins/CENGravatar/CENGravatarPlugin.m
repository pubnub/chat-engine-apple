/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENGravatarPlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENMe.h>
#import "CENGravatarExtension.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENGravatarPluginConfigurationKeys CENGravatarPluginConfiguration = {
    .emailKey = @"ek",
    .gravatarURLKey = @"gk"
};


#pragma mark - Interface implementation

@implementation CENGravatarPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.gravatar";
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENMe class]]) {
        extensionClass = [CENGravatarExtension class];
    }
    
    return extensionClass;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    
    if (!configuration[CENGravatarPluginConfiguration.emailKey]) {
        configuration[CENGravatarPluginConfiguration.emailKey] = @"email";
    }
    
    if (!configuration[CENGravatarPluginConfiguration.gravatarURLKey]) {
        configuration[CENGravatarPluginConfiguration.gravatarURLKey] = @"gravatar";
    }
    
    self.configuration = configuration;
}

#pragma mark -


@end
