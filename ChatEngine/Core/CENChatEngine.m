/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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
#import "CENEmittedEvent.h"
#import "CENStructures.h"
#import "CENConstants.h"
#import "CENLogMacro.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CEExceptionPropagationFlows CEExceptionPropagationFlow = {
    .direct = @"d",
    .middleware = @"m"
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENChatEngine ()


#pragma mark - Information

@property (nonatomic, nullable, strong) CENTemporaryObjectsManager *temporaryObjectsManager;
@property (nonatomic, nullable, strong) CENSession *synchronizationSession;
@property (nonatomic, nullable, copy) dispatch_block_t pubNubSubscribeCompletion;
@property (nonatomic, strong) PNConfiguration *pubNubConfiguration;
@property (nonatomic, strong) dispatch_queue_t pubNubCallbackQueue;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, strong) CENPNFunctionClient *functionClient;
@property (nonatomic, strong) CENPluginsManager *pluginsManager;
@property (nonatomic, strong) CENUsersManager *usersManager;
@property (nonatomic, strong) CENChatsManager *chatsManager;
@property (nonatomic, copy) CENConfiguration *configuration;
@property (nonatomic, getter = isReady, assign) BOOL ready;
@property (nonatomic, assign) BOOL connectedToPubNub;
@property (nonatomic, strong) PNLLogger *logger;
@property (nonatomic, strong) PubNub *pubnub;


#pragma mark - Initialization

/**
 * @brief Initialize \b {CENChatEngine} client.
 
 * @param configuration User-provided information about how client should operate and handle events.
 *
 * @return Initialized and ready to use \b {CENChatEngine} client.
 */
- (instancetype)initWithConfiguration:(CENConfiguration *)configuration;


#pragma mark - Misc

/**
 * @brief Setup events debug output if \b {CENConfiguration.debugEvents} is set to \c YES.
 *
 * @since 0.9.3
 */
- (void)setupDebugger;

/**
 * @brief Complete \b {ChatEngine's CENChatEngine} logger configuration.
 */
- (void)setupClientLogger;

/**
 * @brief Print out current \b {ChatEngine's CENChatEngine} logger configuration.
 */
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
        _chatEngineVersion = kCENLibraryVersion;
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
        NSString *endpoint = _configuration.functionEndpoint;
        _pubNubConfiguration = [_configuration pubNubConfiguration];
        _functionClient = [CENPNFunctionClient clientWithEndpoint:endpoint logger:self.logger];
        _pluginsManager = [CENPluginsManager managerForChatEngine:self];
        _temporaryObjectsManager = [CENTemporaryObjectsManager new];
        _usersManager = [CENUsersManager managerForChatEngine:self];
        _chatsManager = [CENChatsManager managerForChatEngine:self];

        if (configuration.shouldSynchronizeSession) {
            _synchronizationSession = [CENSession sessionWithChatEngine:self];
        }

        _pubNubCallbackQueue = dispatch_queue_create("com.chatengine.pubnub",
                                                     DISPATCH_QUEUE_SERIAL);
        _resourceAccessQueue = dispatch_queue_create("com.chatengine.core",
                                                     DISPATCH_QUEUE_SERIAL);
        
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
    
    [self handleEvent:@"*" withHandlerBlock:^(CENEmittedEvent *event) {
        NSLog(@"<ChatEngine::Debug> %@ ▸ %@%@", event.event, event.emitter,
            event.data ? [@[@"\nEvent payload: ", event.data] componentsJoinedByString:@""] : @".");
    }];
}

- (void)setupClientLogger {
    
#if TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSSearchPathDirectory searchPath = NSCachesDirectory;
#else
    NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSDocumentDirectory
                                                         : NSApplicationSupportDirectory);
#endif // TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSArray *documents = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
    NSString *logsPath = documents.lastObject;
    
#if TARGET_OS_OSX || TARGET_OS_SIMULATOR
    logsPath = [logsPath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
#endif // TARGET_OS_OSX || TARGET_OS_SIMULATOR
    logsPath = [logsPath stringByAppendingPathComponent:@"Logs"];
    self.logger = [PNLLogger loggerWithIdentifier:@"com.chatengine.client"
                                        directory:logsPath
                                     logExtension:@"log"];
    
#if DEBUG
    self.logger.enabled = YES;
#else
    self.logger.enabled = NO;
#endif
    self.logger.writeToConsole = self.logger.enabled;
    self.logger.writeToFile = self.logger.enabled;
#if DEBUG
    [self.logger setLogLevel:CENVerboseLogLevel];
#else
    [self.logger setLogLevel:CENSilentLogLevel];
#endif
    self.logger.logFilesDiskQuota = (50 * 1024 * 1024);
    self.logger.maximumLogFileSize = (5 * 1024 * 1024);
    self.logger.maximumNumberOfLogFiles = 5;
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), queue, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        weakSelf.logger.logLevelChangeHandler = ^{
            CELogClientInfo(weakSelf.logger, @"<ChatEngine> ChatEngine SDK %@ (%@)",
                kCENLibraryVersion, kCENCommit);
            CELogResourceAllocation(weakSelf.logger, @"<ChatEngine::%@> %p instance allocation",
                NSStringFromClass([weakSelf class]), weakSelf);

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
        [enabledFlags addObject:@"Emitted events"];
    }
    
    if (verbosityFlags & CENResourcesAllocationLogLevel) {
        [enabledFlags addObject:@"Resources allocation"];
    }
    
    if (verbosityFlags & CENAPICallLogLevel) {
        [enabledFlags addObject:@"API calls"];
    }
    
    CELogClientInfo(self.logger, @"<ChatEngine::Logger> Enabled verbosity level flags: %@",
        [enabledFlags componentsJoinedByString:@", "]);
}

- (void)dealloc {
    
    CELogResourceAllocation(self.logger, @"<ChatEngine::%@> %p instance deallocation",
        NSStringFromClass([self class]), self);
}

#pragma mark -


@end
