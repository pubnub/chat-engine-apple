/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Private.h"
#import "CENChatEngine+ConnectionInterface.h"
#import "CENChatEngine+PluginsPrivate.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+UserPrivate.h"
#import "CENConfiguration+Private.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Session.h"
#import "CENSession+Private.h"
#import "CENStructures.h"
#import "CENConstants.h"
#import "CENLogMacro.h"


#pragma mark Externs

CEExceptionPropagationFlows CEExceptionPropagationFlow = { .direct = @"d", .middleware = @"m" };


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENChatEngine ()


#pragma mark - Information

@property (nonatomic, nullable, strong) CENTemporaryObjectsManager *temporaryObjectsManager;
@property (nonatomic, getter = isReady, assign) BOOL ready NS_SWIFT_NAME(ready);
@property (nonatomic, nullable, strong) CENSession *synchronizationSession;
@property (nonatomic, strong) dispatch_queue_t pubNubResourceAccessQueue;
@property (nonatomic, strong) PNConfiguration *pubNubConfiguration;
@property (nonatomic, strong) dispatch_queue_t pubNubCallbackQueue;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, strong) CENPluginsManager *pluginsManager;
@property (nonatomic, strong) CENPNFunctionClient *functionsClient;
@property (nonatomic, strong) CENUsersManager *usersManager;
@property (nonatomic, strong) CENChatsManager *chatsManager;
@property (nonatomic, copy) CENConfiguration *configuration;
@property (nonatomic, assign) BOOL connectedToPubNub;
@property (nonatomic, strong) PNLLogger *logger;
@property (nonatomic, strong) PubNub *pubnub;


#pragma mark - Initialization

- (instancetype)initWithConfiguration:(CENConfiguration *)configuration;


#pragma mark - Misc

/**
 * @brief      Setup events debugger if required.
 * @discussion Configure 'any' events handler to print out them to IDE console.
 *
 * @since 0.9.2
 */
- (void)setupDebugger;

/**
 * @brief  Complete logger instance configuration for this client.
 */
- (void)setupClientLogger;
- (void)printLogVerbosityInformation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Public interface implementation

@implementation CENChatEngine


#pragma mark - Information

+ (NSString *)sdkVersion {
    
    static NSString *_chatEngineVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatEngineVersion = kCELibraryVersion;
    });
    
    return _chatEngineVersion;
}

- (BOOL)isReady {
    
    __block BOOL isReady = NO;
    dispatch_sync(self.resourceAccessQueue, ^{
        isReady = self->_ready;
    });
    
    return isReady;
}

- (CENConfiguration *)currentConfiguration {
    
    return [self.configuration copy];
}


#pragma mark - Initialization and Configuration

+ (instancetype)clientWithConfiguration:(CENConfiguration *)configuration {
    
    return [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(CENConfiguration *)configuration {
    
    if ((self = [super init])) {
        [self setupClientLogger];
        
        _configuration = [configuration copy];
        _pubNubConfiguration = [_configuration pubNubConfiguration];
        _functionsClient = [CENPNFunctionClient clientWithEndpoint:configuration.functionEndpoint logger:self.logger];
        _pluginsManager = [CENPluginsManager managerForChatEngine:self];
        _temporaryObjectsManager = [CENTemporaryObjectsManager new];
        _usersManager = [CENUsersManager managerForChatEngine:self];
        _chatsManager = [CENChatsManager managerForChatEngine:self];
        if (configuration.shouldSynchronizeSession) {
            _synchronizationSession = [CENSession sessionWithChatEngine:self];
        }
        
        _pubNubResourceAccessQueue = dispatch_queue_create("com.chatengine.core.pubnub", DISPATCH_QUEUE_CONCURRENT);
        _pubNubCallbackQueue = dispatch_queue_create("com.chatengine.pubnub", DISPATCH_QUEUE_SERIAL);
        _resourceAccessQueue = dispatch_queue_create("com.chatengine.core", DISPATCH_QUEUE_SERIAL);
        
        [self setupDebugger];
    }
    
    return self;
}


#pragma mark - Temporary objects

- (void)storeTemporaryObject:(id)object {
    
    [self.temporaryObjectsManager storeTemporaryObject:object];
}


#pragma mark - Clean up

- (void)unregisterAllFromObjects:(CENObject *)object {
    
    [self unregisterAllPluginsFromObjects:object];
}

- (void)destroy {
    
    [self destroySession];
    [self disconnectUser];
    [self destroyPubNub];
    [self destroyPlugins];
    [self destroyUsers];
    [self destroyChats];
    
    [self.temporaryObjectsManager destroy];
    self.temporaryObjectsManager = nil;
    
    [super destruct];
}


#pragma mark - Misc

- (void)setupDebugger {
    
    if (!self.configuration.shouldDebugEvents) {
        return;
    }
    
    [self handleEvent:@"*" withHandlerBlock:^(NSString *event, id emittedBy, id parameters) {
        NSLog(@"<ChatEngine::Debug> %@ ▸ %@%@", event, emittedBy,
              parameters ? [@[@"\nEvent payload: ", parameters] componentsJoinedByString:@""] : @".");
    }];
}

- (void)setupClientLogger {
    
#if TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSSearchPathDirectory searchPath = NSCachesDirectory;
#else
    NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSDocumentDirectory : NSApplicationSupportDirectory);
#endif // TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSArray<NSString *> *documents = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
    NSString *logsPath = documents.lastObject;
    
#if TARGET_OS_OSX || TARGET_OS_SIMULATOR
    logsPath = [logsPath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
#endif // TARGET_OS_OSX || TARGET_OS_SIMULATOR
    logsPath = [logsPath stringByAppendingPathComponent:@"Logs"];
    self.logger = [PNLLogger loggerWithIdentifier:@"com.chatengine.client" directory:logsPath logExtension:@"log"];
    
#if DEBUG
    self.logger.enabled = YES;
#else
    self.logger.enabled = NO;
#endif
    self.logger.writeToConsole = YES;
    self.logger.writeToFile = YES;
#if DEBUG
    [self.logger setLogLevel:CENVerboseLogLevel];
#else
    [self.logger setLogLevel:CENSilentLogLevel];
#endif
    self.logger.logFilesDiskQuota = (50 * 1024 * 1024);
    self.logger.maximumLogFileSize = (5 * 1024 * 1024);
    self.logger.maximumNumberOfLogFiles = 5;
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        weakSelf.logger.logLevelChangeHandler = ^{
            CELogClientInfo(self.logger, @"<ChatEngine> ChatEngine SDK %@ (%@)", kCELibraryVersion, kCECommit);
            CELogResourceAllocation(self.logger, @"<ChatEngine::%@> %p instance allocation", NSStringFromClass([self class]), self);
            [weakSelf printLogVerbosityInformation];
        };
        [weakSelf printLogVerbosityInformation];
#pragma clang diagnostic pop
    });
}

- (void)printLogVerbosityInformation {
    
    NSUInteger verbosityFlags = self.logger.logLevel;
    NSMutableArray *enabledFlags = [NSMutableArray new];
    
    if (verbosityFlags & CENInfoLogLevel) {
        [enabledFlags addObject:@"Info"];
    }
    
    if (verbosityFlags & CENExceptionsLogLevel) {
        [enabledFlags addObject:@"Exceptions"];
    }
    
    if (verbosityFlags & CENRequestLogLevel) {
        [enabledFlags addObject:@"Requests"];
    }
    
    if (verbosityFlags & CENRequestErrorLogLevel) {
        [enabledFlags addObject:@"Request errors"];
    }
    
    if (verbosityFlags & CENResponseLogLevel) {
        [enabledFlags addObject:@"Responses"];
    }
    
    if (verbosityFlags & CENEventEmitLogLevel) {
        [enabledFlags addObject:@"Emited events"];
    }
    
    if (verbosityFlags & CENResourcesAllocationLogLevel) {
        [enabledFlags addObject:@"Resources allocation"];
    }
    
    if (verbosityFlags & CENAPICallLogLevel) {
        [enabledFlags addObject:@"API calls"];
    }
    
    CELogClientInfo(self.logger, @"<ChatEngine::Logger> Enabled verbosity level flags: %@", [enabledFlags componentsJoinedByString:@", "]);
}

- (void)dealloc {
    
    CELogResourceAllocation(self.logger, @"<ChatEngine::%@> %p instance deallocation", NSStringFromClass([self class]), self);
}

#pragma mark -


@end
