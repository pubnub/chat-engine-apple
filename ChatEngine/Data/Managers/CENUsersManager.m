/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENUsersManager.h"
#import "CENChatEngine+PluginsPrivate.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+Private.h"
#import "CENObject+Private.h"
#import "CENUser+Private.h"
#import "CENLogMacro.h"
#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENUsersManager ()


#pragma mark - Information

/**
 * @brief Map of user identifiers to \b {user CENUser} instance which they represent.
 */
@property (nonatomic, strong) NSMapTable<NSString *, CENUser *> *usersMap;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief \b {CENChatEngine} instance which instantiated this manager.
 */
@property (nonatomic, nullable, weak) CENChatEngine *chatEngine;

/**
 * @brief Currently active local user.
 */
@property (nonatomic, nullable, strong) CENMe *me;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENUsersManager


#pragma mark - Information

- (NSDictionary<NSString *,CENUser *> *)users {
    
    __block NSDictionary<NSString *,CENUser *> *users = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        users = [self.usersMap dictionaryRepresentation];
    });
    
    return users;
}

- (CENMe *)me {
    
    __block CENMe *me = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        me = self->_me;
    });
    
    return me;
}


#pragma mark - Initialization and Configuration

+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine {
    
    return [[self alloc] initWithChatEngine:chatEngine];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException
                format:@"-init not implemented, please use: +managerForChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        NSString *identifier = [NSString stringWithFormat:@"com.chatengine.manager.users.%p", self];
        const char *cIdentifier = [identifier UTF8String];
        _resourceAccessQueue = dispatch_queue_create(cIdentifier, DISPATCH_QUEUE_CONCURRENT);
                                                      
        _usersMap = [NSMapTable strongToStrongObjectsMapTable];
        _chatEngine = chatEngine;
        
        CELogResourceAllocation(self.chatEngine.logger,
            @"<ChatEngine::Manager::Users> %p instance allocation", self);
    }
    
    return self;
}


#pragma mark - Creation

- (CENUser *)createUserWithUUID:(NSString *)uuid state:(NSDictionary *)state {
    
    __block BOOL userCreated = NO;
    __block CENUser *user = nil;
    
    if (![uuid isKindOfClass:[NSString class]] || !uuid.length) {
        return nil;
    }
    
    if (state && ![state isKindOfClass:[NSDictionary class]]) {
        state = nil;
    }
    
    BOOL isLocalUser = [uuid isEqualToString:[self.chatEngine pubNubUUID]];
    dispatch_barrier_sync(self.resourceAccessQueue, ^{
        user = isLocalUser ? (id)self->_me : [self.usersMap objectForKey:uuid];

        if (!user && self.chatEngine) {
            CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Create %@ '%@' user%@",
                isLocalUser ? @"local" : @"remote", uuid,
                state.count ? [@[@" with state: ", state] componentsJoinedByString:@""] : @".");
            
            userCreated = YES;
            Class cls = isLocalUser ? [CENMe class] : [CENUser class];
            user = [cls userWithUUID:uuid state:state chatEngine:self.chatEngine];
            
            if (isLocalUser) {
                self.me = (CENMe *)user;
            } else {
                [self.usersMap setObject:user forKey:uuid];
            }
        }
    });
    
    if (user && userCreated) {
        [self.chatEngine setupProtoPluginsForObject:user withCompletion:^{
            [user onCreate];
        }];
    }
    
    return user;
}

- (NSArray<CENUser *> *)createUsersWithUUID:(NSArray<NSString *> *)uuids {
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:uuids.count];
    
    for (NSString *uuid in uuids) {
        [users addObject:[self createUserWithUUID:uuid state:nil]];
    }
    
    return users.count ? users : nil;
}


#pragma mark - Audition

- (CENUser *)userWithUUID:(NSString *)uuid {
    
    __block CENUser *user = nil;
    
    if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
        BOOL isLocalUser = [uuid isEqualToString:[self.chatEngine pubNubUUID]];
        
        dispatch_sync(self.resourceAccessQueue, ^{
            user = isLocalUser ? (id)self->_me : [self.usersMap objectForKey:uuid];
        });
    }
    
    return user;
}


#pragma mark - Clean up

- (void)destroy {
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        NSArray<CENUser *> *users = [self.usersMap objectEnumerator].allObjects;
        [users makeObjectsPerformSelector:@selector(destruct)];
        [self.usersMap removeAllObjects];
        [self->_me destruct];
        self->_me = nil;
    });
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger,
        @"<ChatEngine::Manager::Users> %p instance deallocation", self);
}

#pragma mark -


@end
