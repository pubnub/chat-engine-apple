/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSearch+Private.h"
#import "CENSearch+Interface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENSearch+BuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENSenderAugmentationPlugin.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatAugmentationPlugin.h"
#import "CENObject+PluginsPrivate.h"
#import "CENEventEmitter+Private.h"
#import "CENSearchFilterPlugin.h"
#import "CENChatEngine+Private.h"
#import "CEPPlugin+Developer.h"
#import "CENObject+Private.h"
#import "CENErrorCodes.h"
#import "CENLogMacro.h"
#import "CENError.h"
#import "CENChat.h"
#import "CENUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENSearch ()


#pragma mark - Information

/**
 * @brief Whether search performed between two dates or not.
 *
 * @discussion If \c YES, then searcher will ignore \b {limit} requirement.
 */
@property (nonatomic, assign) BOOL messagesBetweenTimetokens;

@property (nonatomic, nullable, strong) NSNumber *start;
@property (nonatomic, nullable, strong) CENUser *sender;
@property (nonatomic, nullable, strong) NSNumber *end;
@property (nonatomic, nullable, copy) NSString *event;

/**
 * @brief The timetoken from which next search request should search backward.
 */
@property (nonatomic, strong) NSNumber *referenceDate;

/**
 * @brief Number of automatically fetched pages.
 */
@property (nonatomic, assign) NSInteger fetchedPages;

/**
 * @brief The maximum number of history requests same as \b {pages}
 */
@property (nonatomic, assign) NSInteger maximumPages;

/**
 * @brief Number of events which conform to specified criteria.
 */
@property (nonatomic, assign) NSUInteger needleCount;

/**
 * @brief Whether currently performing search requests or not.
 */
@property (nonatomic, assign) BOOL searchingEvents;

@property (nonatomic, assign) BOOL hasMoreData;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) CENChat *chat;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize \b {chat CENChat} searcher.
 *
 * @param event Name of event to search for.
 * @param chat \b {Chat CENChat} inside of which events search should be performed.
 * @param sender \b {User CENUser} who sent the message.
 * @param limit The maximum number of results to return that match search criteria. Search will
 *     continue operating until it returns this number of results or it reached the end of history.
 *     Limit will be ignored in case if both 'start' and 'end' timetokens has been passed in search
 *     configuration.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 20
 * @param pages The maximum number of history requests which \b {CENChatEngine} will do
 *     automatically to fulfill \c limit requirement.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 10
 * @param count The maximum number of messages which can be fetched with single history request.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 100
 * @param start The timetoken to begin searching between.
 * @param end The timetoken to end searching between.
 * @param chatEngine \b {CENChatEngine} client which will manage this chat instance.
 *
 * @return Initialized and ready to use history searcher.
 */
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

/**
 * @brief Fetch next history page using reference timetoken.
 *
 * @param block Block / closure which will be called at the end of history fetch process and pass
 *     service response or error (if any).
 */
- (void)fetchSearchPageWithCompletion:(void(^)(id response, BOOL isError))block;


#pragma mark - Filtering

/**
 * @brief Emit events which conform to search requirements.
 *
 * @param events \a NSArray with event payloads which should be filtered and emitted.
 * @param block Block / closure which should be called at the end of emitting process.
 */
- (void)emitLocallyEvents:(NSArray *)events withCompletion:(dispatch_block_t)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENSearch


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.search;
}

- (CENChat *)defaultStateChat {
    
    return self.chatEngine.global;
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
    
    if ((!event || ([event isKindOfClass:[NSString class]] && event.length)) &&
        (!chat || [chat isKindOfClass:[CENChat class]]) &&
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
        _messagesBetweenTimetokens = ([start compare:@0] != NSOrderedSame &&
                                      [end compare:@0] != NSOrderedSame);
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
        
        [self registerPlugin:[CENChatAugmentationPlugin class]
              withIdentifier:CENChatAugmentationPlugin.identifier
               configuration:@{ }
                 firstInList:NO];
        [self registerPlugin:[CENSenderAugmentationPlugin class]
              withIdentifier:CENSenderAugmentationPlugin.identifier
               configuration:@{ }
                 firstInList:NO];
    }
    
    return self;
}


#pragma mark - State

- (void)restoreStateForChat:(CENChat *)chat {
    
    [super restoreStateForChat:chat];
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
                
                [self.chatEngine throwError:response
                                   forScope:@"search"
                                       from:self
                              propagateFlow:CEExceptionPropagationFlow.middleware];
                
                return;
            }

            [self emitLocallyEvents:response withCompletion:^{
                dispatch_async(self.resourceAccessQueue, ^{
                    self.searchingEvents = NO;
                    self.fetchedPages++;

                    if (self.hasMoreData && self.fetchedPages == self.maximumPages) {
                        [self emitEventLocally:@"$.search.pause", nil];
                    } else if (self.hasMoreData && (self.needleCount < self.limit ||
                                                    self.messagesBetweenTimetokens)) {
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
                self.hasMoreData = (result.data.messages.count == self.count &&
                                    [self.referenceDate compare:@0] != NSOrderedSame);
                NSString *sortKey = CENEventData.timetoken;
                
                NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortKey
                                                                           ascending:YES];
                NSArray *messages = [result.data.messages sortedArrayUsingDescriptors:@[descriptor]];
                NSNumber *timetoken = messages.lastObject[CENEventData.timetoken];
                
                if (self.start && [self.referenceDate compare:self.start] == NSOrderedAscending) {
                    self.hasMoreData = NO;
                    
                    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(%K >= %@)",
                                                    CENEventData.timetoken, self.start];
                    messages = [messages filteredArrayUsingPredicate:filterPredicate];
                }
                
                if (self.end && timetoken && [self.end compare:timetoken] == NSOrderedAscending) {
                    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(%K <= %@)",
                                                    CENEventData.timetoken, self.end];
                    messages = [messages filteredArrayUsingPredicate:filterPredicate];
                }
                
                block(messages, NO);
            } else {
                block([CENError errorFromPubNubStatus:status], YES);
            }
        }];
    }
}


#pragma mark - Filtering

- (void)emitLocallyEvents:(NSArray *)events withCompletion:(dispatch_block_t)block {

    if (!events.count) {
        block();
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [events enumerateObjectsWithOptions:NSEnumerationReverse
                                 usingBlock:^(id data,
                                              __unused NSUInteger idx,
                                              __unused BOOL *stop) {
                                     
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            if (self.needleCount < self.limit || self.messagesBetweenTimetokens) {
                NSMutableDictionary *eventData = [(data[@"message"] ?: @{}) mutableCopy];
                eventData[@"timetoken"] = data[@"timetoken"];
                
                [self.chatEngine triggerEventLocallyFrom:self
                                                   event:eventData[CENEventData.event]
                                          withParameters:@[eventData]
                                              completion:^(__unused NSString *event,
                                                           __unused id processedData,
                                                           BOOL rejected) {
                                
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
    
    return [NSString stringWithFormat:@"<CENSearch:%p chat: '%@'; event: '%@'; sender: '%@'; "
            "limit: %@ (fetched: %@); pages: %@ (fetched: %@); count: %@; start: %@; end: %@; "
            "has more: %@>", self, self.chat.name, self.event ?: @"all", self.sender.uuid ?: @"all",
            @(self.limit), @(self.needleCount), @(self.maximumPages), @(self.fetchedPages),
            @(self.count), (id)self.start ?: @"none", (id)self.end ?: @"current",
            self.hasMoreData ? @"YES" : @"NO"];
}

#pragma mark -


@end
