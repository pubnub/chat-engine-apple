/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMarkdownPlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENChat.h>
#import "CENMarkdownMiddleware.h"

#pragma mark Externs

CENMarkdownConfigurationKeys CENMarkdownConfiguration = { .events = @"ens", .messageKey = @"mk", .parserConfiguration = @"pc" };


#pragma mark - Interface implementation

@implementation CENMarkdownPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.markdown";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {
    
    Class middlewareClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        middlewareClass = [CENMarkdownMiddleware class];
    }
    
    return middlewareClass;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithDictionary:self.configuration];
    
    if (!((NSArray *)configuration[CENMarkdownConfiguration.events]).count) {
        configuration[CENMarkdownConfiguration.events] = @[@"message"];
    }
    
    if (!((NSString *)configuration[CENMarkdownConfiguration.messageKey]).length) {
        configuration[CENMarkdownConfiguration.messageKey] = @"text";
    }
    
    self.configuration = configuration;
}

#pragma mark -


@end
