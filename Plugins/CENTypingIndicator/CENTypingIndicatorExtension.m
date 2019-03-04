/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENTypingIndicatorExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENEmittedEvent.h>
#import "CENTypingIndicatorPlugin.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENTypingIndicatorExtension ()


#pragma mark - Information

/**
 * @brief Events handling block.
 */
@property (nonatomic, copy, nullable) CENEventHandlerBlock eventHandlerBlock;

/**
 * @brief Whether user currently typing or not.
 */
@property (nonatomic, assign, getter = isTyping) BOOL typing;

/**
 * @brief Typing indicator idle timer.
 */
@property (nonatomic, nullable, strong) NSTimer *idleTimer;


#pragma mark - Handler

/**
 * @brief Handle idle timer.
 *
 * @param timer Timer which triggered this callback.
 */
- (void)handleTypingIdleTimer:(NSTimer *)timer;


#pragma mark - Misc

/**
 * @brief Create and configure typing idle timer.
 */
- (void)startIdleTimer;

/**
 * @brief Invalidate any active typing idle timers.
 */
- (void)stopIdleTimer;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENTypingIndicatorExtension


#pragma mark - Chat activity management

- (void)startTyping {
    
    if (!self.isTyping) {
        [(CENChat *)self.object emitEvent:@"$typingIndicator.startTyping" withData:nil];
    }
    
    self.typing = YES;
    
    [self startIdleTimer];
}

- (void)stopTyping {
    
    if (self.isTyping) {
        [(CENChat *)self.object emitEvent:@"$typingIndicator.stopTyping" withData:nil];
    }
    
    [self stopIdleTimer];
    
    self.typing = NO;
}


#pragma mark - Handlers

- (void)handleTypingIdleTimer:(NSTimer *)__unused timer {
    
    [self stopTyping];
}


#pragma mark - Misc

- (void)startIdleTimer {
    
    [self stopIdleTimer];
    
    NSNumber *timeout = self.configuration[CENTypingIndicatorConfiguration.timeout];
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout.doubleValue
                                                      target:self
                                                    selector:@selector(handleTypingIdleTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:self.idleTimer forMode:NSRunLoopCommonModes];
}

- (void)stopIdleTimer {
    
    if ([self.idleTimer isValid]) {
        [self.idleTimer invalidate];
    }
    
    self.idleTimer = nil;
}

#pragma mark -


@end
