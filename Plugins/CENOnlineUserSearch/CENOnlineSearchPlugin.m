/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENOnlineSearchPlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENOnlineSearchExtension.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Externs

CENOnlineSearchConfigurationKeys CENOnlineSearchConfiguration = { .propertyName = @"pn", .caseSensitive = @"cs" };


#pragma mark - Interface implementation

@implementation CENOnlineSearchPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.online-user-search";
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENOnlineSearchExtension class];
    }
    
    return extensionClass;
}

+ (void)search:(NSString *)criteria inChat:(CENChat *)chat withCompletion:(void(^)(NSArray<CENUser *> *))block {
    
    [chat extensionWithIdentifier:[self identifier] context:^(CENOnlineSearchExtension *extension) {
        [extension searchFor:criteria withCompletion:block];
    }];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithDictionary:self.configuration];
    
    if (!configuration[CENOnlineSearchConfiguration.propertyName]) {
        configuration[CENOnlineSearchConfiguration.propertyName] = @"uuid";
    }
    
    if (!configuration[CENOnlineSearchConfiguration.caseSensitive]) {
        configuration[CENOnlineSearchConfiguration.caseSensitive] = @NO;
    }
    
    self.configuration = configuration;
}

#pragma mark -


@end
