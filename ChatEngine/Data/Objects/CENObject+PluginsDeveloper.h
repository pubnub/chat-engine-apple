/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENObject+Plugins.h"
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+Authorization.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+Plugins.h>
#import <CENChatEngine/CENChatEngine+PubNub.h>
#import <CENChatEngine/CENChatEngine.h>


#pragma mark Developer interface declaration

@interface CENObject (PluginsDeveloper)


#pragma mark - Information

/**
 * @brief \b {ChatEngine CENChatEngine} instance which manage instantiated subclass.
 *
 * @ref 9fd7aa4b-7907-41f3-a1eb-67c28f39306c
 */
@property (nonatomic, readonly, weak) CENChatEngine *chatEngine;


#pragma mark - Events emitting

/**
 * @brief Emit specific \c event locally to all listeners.
 *
 * @param event Name of event for which listeners should be notified.
 * @param ... Dynamic list of arguments which should be passed along with emitted event (maximum can
 *     be passed one value terminated by \c nil).
 */
- (void)emitEventLocally:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -


@end
