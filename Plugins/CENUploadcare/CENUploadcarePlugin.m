/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENUploadcareMiddleware.h"
#import "CENUploadcareExtension.h"
#import <CENChatEngine/CENChat.h>
#import "CENUploadcarePlugin.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENUploadcareConfigurationKeys CENUploadcareConfiguration = {
    .publicKey = @"pk"
};


#pragma mark - Interface implementation

@implementation CENUploadcarePlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.uploadcare";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if (isOnLocation && [object isKindOfClass:[CENChat class]]) {
        middlewareClass = [CENUploadcareMiddleware class];
    }
    
    return middlewareClass;
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENUploadcareExtension class];
    }
    
    return extensionClass;
}

+ (void)shareFileWithIdentifier:(NSString *)identifier toChat:(CENChat *)chat {
    
    CENUploadcareExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    [extension shareFileWithIdentifier:identifier];
}


#pragma mark - Handlers

- (void)onCreate {
    
    if (!self.configuration[CENUploadcareConfiguration.publicKey]) {
        NSString *reason = @"Uploadcare public key not set during plugin registration.";
        
        @throw [NSException exceptionWithName:@"CENUploadcarePlugin" reason:reason userInfo:nil];
    }
}

#pragma mark -


@end
