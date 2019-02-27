/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENRandomUsernamePlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENMe.h>


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENRandomUsernameConfigurationKeys CENRandomUsernameConfiguration = {
    .propertyName = @"pn"
};


#pragma mark - Interface implementation

@implementation CENRandomUsernamePlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.random-username";
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENMe class]]) {
        extensionClass = [CENRandomUsernameExtension class];
    }
    
    return extensionClass;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    
    if (!configuration[CENRandomUsernameConfiguration.propertyName]) {
        configuration[CENRandomUsernameConfiguration.propertyName] = @"username";
    }
    
    self.configuration = configuration;
}

#pragma mark - 


@end
