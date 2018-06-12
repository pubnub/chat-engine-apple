/**
 *@author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENSearch+Private.h"
#import "CENSearch+Interface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENSearch+BuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENObject+PluginsPrivate.h"
#import "CENEventEmitter+Private.h"
#import "CENSearchFilterPlugin.h"
#import "CENChatEngine+Private.h"
#import "CEPPlugin+Developer.h"
#import "CENObject+Private.h"
#import "CENErrorCodes.h"
#import "CENLogMacro.h"
#import "CENChat.h"
#import "CENUser.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENSearch ()


#pragma mark - Information

@property (nonatomic, assign) BOOL messagesBetweenTimetokens;
@property (nonatomic, nullable, strong) NSNumber *start;
@property (nonatomic, nullable, strong) CENUser *sender;
@property (nonatomic, nullable, strong) NSNumber *end;
@property (nonatomic, nullable, copy) NSString *event;
@property (nonatomic, strong) NSNumber *referenceDate;
@property (nonatomic, assign) NSInteger fetchedPages;
@property (nonatomic, assign) NSInteger maximumPages;
@property (nonatomic, assign) NSUInteger needleCount;
@property (nonatomic, assign) BOOL searchingEvents;
@property (nonatomic, assign) BOOL hasMoreData;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) CENChat *chat;


#pragma mark - Initialization and Configuration

- (instancetype)initWithEvent:(nullable NSString *)event
                       inChat:(CENChat *)chat
                       sentBy:(nullable CENUser *)sender
                    withLimit:(NSInteger)limit
                        pages:(NSInteger)pages
                        count:(NSInteger)count
                        start:(nullable NSNumber *)start
                          end:(nullable NSNumber *)end
                   chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Searching

- (void)fetchSearchPageWithCompletion:(void(^)(id response, BOOL isError))block;


#pragma mark - Filtering

- (void)emitLocalyEvents:(NSArray *)events withCompletion:(dispatch_block_t)block;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENSearch


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.search;
}

- (BOOL)hasMore {
    
    __block BOOL hasMore = NO;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        hasMore = self->_hasMoreData;
    });
    
    return hasMore;
}


#pragma mark - Initialization and Configuration

+ (instancetype)searchForEvent:(NSString *)event
                        inChat:(CENChat *)chat
                        sentBy:(CENUser *)sender
                     withLimit:(NSInteger)limit
                         pages:(NSInteger)pages
                         count:(NSInteger)count
                         start:(NSNumber *)start
                           end:(NSNumber *)end
                    chatEngine:(CENChatEngine *)chatEngine {
    
    CENSearch *search = nil;
    
    if ((!event || ([event isKindOfClass:[NSString class]] && event.length)) && (!chat || [chat isKindOfClass:[CENChat class]]) &&
        (!sender  || [sender isKindOfClass:[CENUser class]])) {
        
        limit = limit <= 0 ? 20 : limit;
        count = count <= 0 ? 100 : count;
        pages = pages <= 0 ? 10 : pages;
        
        search = [[self alloc] initWithEvent:event
                                      inChat:chat
                                      sentBy:sender
                                   withLimit:limit
                                       pages:pages
                                       count:count
                                       start:start
                                         end:end
                                  chatEngine:chatEngine];
    }
    
    return search;
}

- (instancetype)initWithEvent:(NSString *)event
                       inChat:(CENChat *)chat
                       sentBy:(CENUser *)sender
                    withLimit:(NSInteger)limit
                        pages:(NSInteger)pages
                        count:(NSInteger)count
                        start:(NSNumber *)start
                          end:(NSNumber *)end
                   chatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super initWithChatEngine:chatEngine])) {
        _messagesBetweenTimetokens = ([start compare:@0] != NSOrderedSame && [end compare:@0] != NSOrderedSame);
        _referenceDate = end;
        _maximumPages = pages;
        _fetchedPages = 0;
        _needleCount = 0;
        _hasMoreData = YES;
        _sender = sender;
        _event = [event copy];
        _count = count;
        _start = start;
        _limit = limit;
        _pages = pages;
        _chat = chat;
        _end = end;
        
        if (sender || event) {
            NSMutableDictionary *configuration = [NSMutableDictionary new];
            if (sender) {
                configuration[@"sender"] = sender.uuid;
            }
            
            if (event) {
                configuration[@"event"] = event;
            }
            
            [self registerPlugin:[CENSearchFilterPlugin class]
                  withIdentifier:CENSearchFilterPlugin.identifier
                   configuration:configuration
                     firstInList:YES];
        }
    }
    
    return self;
}


#pragma mark - Searching

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENSearch * (^)(void))search {
    
    return ^CENSearch * {
        [self searchEvents];
        
        return self;
    };
}

- (CENSearch * (^)(void))next {
    
    return ^CENSearch * {
        [self searchOlder];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)searchEvents {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (!self.fetchedPages) {
            [self emitEventLocally:@"$.search.start", nil];
        }
        
        [self fetchSearchPageWithCompletion:^(id response, BOOL isError) {
            if (isError) {
                dispatch_async(self.resourceAccessQueue, ^{
                    self.searchingEvents = NO;
                });
                
                [self.chatEngine throwError:response forScope:@"search" from:self propagateFlow:CEExceptionPropagationFlow.middleware];
                
                return;
            }
            
            [self emitLocalyEvents:response withCompletion:^{
                dispatch_async(self.resourceAccessQueue, ^{
                    self.searchingEvents = NO;
                    
                    if (self.hasMoreData && self.fetchedPages == self.maximumPages) {
                        [self emitEventLocally:@"$.search.pause", nil];
                    } else if (self.hasMoreData && (self.needleCount < self.limit || self.messagesBetweenTimetokens)) {
                        self.fetchedPages++;
                        [self searchEvents];
                    } else {
                        if (self.needleCount >= self.limit && !self.messagesBetweenTimetokens) {
                            self.hasMoreData = NO;
                        }
                        [self emitEventLocally:@"$.search.finish", nil];
                    }
                });
            }];
        }];
    });
}

- (void)searchOlder {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (self.hasMoreData) {
            self.maximumPages = self.maximumPages + self.pages;
            
            [self searchEvents];
        } else {
            [self emitEventLocally:@"$.search.finish", nil];
        }
    });
}

- (void)fetchSearchPageWithCompletion:(void(^)(id response, BOOL isError))block {
    
    if (!self.searchingEvents) {
        [self emitEventLocally:@"$.search.page.request", nil];
        self.searchingEvents = YES;
        
        [self.chatEngine searchMessagesIn:self.chat.channel
                                withStart:self.referenceDate
                                    limit:self.count
                               completion:^(PNHistoryResult *result, PNErrorStatus *status) {
                                   
            [self emitEventLocally:@"$.search.page.response", nil];
                        
            if (!status) {
                self.referenceDate = result.data.start;
                self.hasMoreData = (result.data.messages.count == self.count && [self.referenceDate compare:@0] != NSOrderedSame);
                
                NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:CENEventData.timetoken ascending:YES];
                NSArray *messages = [result.data.messages sortedArrayUsingDescriptors:@[descriptor]];
                
                if (self.start && [self.referenceDate compare:self.start] == NSOrderedAscending) {
                    self.hasMoreData = NO;
                    
                    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(%K >= %@)",
                                                    CENEventData.timetoken, self.start];
                    messages = [messages filteredArrayUsingPredicate:filterPredicate];
                }
                
                block(messages, NO);
            } else {
                NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: status.errorData.information };
                NSError *error = [NSError errorWithDomain:kCEPNErrorDomain code:-1 userInfo:errorInformation];
                
                block(error, YES);
            }
        }];
    }
}


#pragma mark - Filtering

- (void)emitLocalyEvents:(NSArray *)events withCompletion:(dispatch_block_t)block {

    if (!events.count) {
        block();
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [events enumerateObjectsWithOptions:NSEnumerationReverse
                                 usingBlock:^(id messageData, __unused NSUInteger idx, __unused BOOL *stop) {
                                     
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            if (self.needleCount < self.limit || self.messagesBetweenTimetokens) {
                NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithDictionary:messageData[@"message"]];
                eventData[@"timetoken"] = messageData[@"timetoken"];
                
                [self.chatEngine triggerEventLocallyFrom:self
                                                   event:eventData[CENEventData.event]
                                          withParameters:@[eventData]
                                              completion:^(__unused NSString *event, __unused id data, BOOL rejected) {
                                
                    if (!rejected) {
                        self.needleCount++;
                    }
                            
                    *stop = (!self.messagesBetweenTimetokens && self.needleCount >= self.limit);
                    dispatch_semaphore_signal(semaphore);
                }];
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }];
        
        block();
    });
}


#pragma mark - Misc

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<CENSearch:%p chat: '%@'; event: '%@'; sender: '%@'; limit: %@ (fetched: %@); pages: %@ "
                                       "(fetched: %@); count: %@; start: %@; end: %@; has more: %@>",
            self, self.chat.name, self.event ?: @"all", self.sender.uuid ?: @"all", @(self.limit), @(self.needleCount),
            @(self.maximumPages), @(self.fetchedPages), @(self.count), self.start ?: @"none", self.end ?: @"current",
            self.hasMoreData ? @"YES" : @"NO"];
}

#pragma mark -


@end
