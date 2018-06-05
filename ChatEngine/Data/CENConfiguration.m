/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENConfiguration+Private.h"
#import "CENConstants.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENConfiguration () <NSCopying>


#pragma mark - Initialization and Configuration

/**
 * @brief  Initialize configuration instance using minimal required data.
 *
 * @param publishKey   Key which allow client to publish data to chat(s).
 * @param subscribeKey Key which allow client to connect and receive updates from chat(s).
 *
 * @return Configured and ready to se configuration instance.
 */
- (instancetype)initWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey;


#pragma mark - Misc

/**
 * @brief  Compose default \b PubNub Function access endpoint URI.
 *
 * @return URI which allow to get access to \b ChatEngine back-end which is running inside of \b PubNub Function.
 */
- (NSString *)defaultFunctionEndpoint;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENConfiguration


#pragma mark - Information

- (void)setPublishKey:(NSString *)publishKey {
    
    if(![publishKey isKindOfClass:[NSString class]] || !publishKey.length) {
        [NSException raise:NSDestinationInvalidException format:@"Required information is missing or has wrong data type: publish key."];
    }
    
    _publishKey = [publishKey copy];
}

- (void)setSubscribeKey:(NSString *)subscribeKey {
    
    if(![subscribeKey isKindOfClass:[NSString class]] || !subscribeKey.length) {
        [NSException raise:NSDestinationInvalidException format:@"Required information is missing or has wrong data type: subscribe key."];
    }
    
    _subscribeKey = [subscribeKey copy];
}

- (void)setFunctionEndpoint:(NSString *)functionEndpoint {
    
    if (![functionEndpoint isKindOfClass:[NSString class]] || !functionEndpoint.length) {
        functionEndpoint = [self defaultFunctionEndpoint];
    }
    
    _functionEndpoint = [functionEndpoint copy];
}

- (void)setPresenceHeartbeatValue:(NSInteger)presenceHeartbeatValue {
    
    _presenceHeartbeatValue = presenceHeartbeatValue;
    
    if (!self.presenceHeartbeatInterval) {
        _presenceHeartbeatInterval = (NSInteger)(_presenceHeartbeatValue * 0.5f) - 1;
    }
}


#pragma mark - Initialization and Configuration

+ (instancetype)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey {
    
    if (![publishKey isKindOfClass:[NSString class]] || !publishKey.length || ![subscribeKey isKindOfClass:[NSString class]] ||
        !subscribeKey.length) {
        
        NSMutableArray *missingKeys = [NSMutableArray new];
        
        if (![publishKey isKindOfClass:[NSString class]] || !publishKey.length) {
            [missingKeys addObject:@"publishKey"];
        }
        
        if (![subscribeKey isKindOfClass:[NSString class]] || !subscribeKey.length) {
            [missingKeys addObject:@"subscribeKey"];
        }
        
        [NSException raise:NSInternalInconsistencyException
                    format:@"PNConfiguration instance can't be created because required information is missing or has "
                            "wrong data type: %@", missingKeys];
    }
    
    return [[self alloc] initWithPublishKey:publishKey subscribeKey:subscribeKey];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException format:@"-init not implemented, please use: +configurationWithPublishKey:subscribeKey:"];
    
    return nil;
}

- (instancetype)initWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey {
    
    if ((self = [super init])) {
        _publishKey = [publishKey copy];
        _subscribeKey = [subscribeKey copy];
        _presenceHeartbeatValue = kCEDefaultPresenceHeartbeatValue;
        _presenceHeartbeatInterval = kCEDefaultPresenceHeartbeatInterval;
        _globalChannel = [kCEDefaultGlobalChannel copy];
        _synchronizeSession = kCEDefaultShouldSynchronizeSession;
        _enableMeta = kCEDefaultEnableMeta;
        _functionEndpoint = [self defaultFunctionEndpoint];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:self.publishKey subscribeKey:self.subscribeKey];
    configuration.cipherKey = self.cipherKey;
    configuration.presenceHeartbeatValue = self.presenceHeartbeatValue;
    configuration.presenceHeartbeatInterval = self.presenceHeartbeatInterval;
    configuration.functionEndpoint = self.functionEndpoint;
    configuration.globalChannel = self.globalChannel;
    configuration.synchronizeSession = self.shouldSynchronizeSession;
    configuration.enableMeta = self.enableMeta;
    configuration.throwExceptions = self.shouldThrowExceptions;
    
    return configuration;
}


#pragma mark - PubNub helper methods

- (PNConfiguration *)pubNubConfiguration {
    
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey subscribeKey:self.subscribeKey];
    configuration.cipherKey = self.cipherKey;
    configuration.presenceHeartbeatValue = self.presenceHeartbeatValue;
    configuration.presenceHeartbeatInterval = self.presenceHeartbeatInterval;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.stripMobilePayload = NO;
#pragma clang diagnostic pop
    
    return configuration;
}


#pragma mark - Misc

- (NSString *)defaultFunctionEndpoint {
    
    return [@[kCEPNFunctionsBaseURI, _subscribeKey, @"chat-engine-server"] componentsJoinedByString:@"/"];
}

#pragma mark -


@end
