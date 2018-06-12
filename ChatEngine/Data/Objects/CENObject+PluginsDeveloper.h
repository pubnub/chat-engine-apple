/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENObject+Plugins.h"
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+Authorization.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+Plugins.h>
#import <CENChatEngine/CENChatEngine+PubNub.h>
#import <CENChatEngine/CENChatEngine.h>


#pragma mark Private interface declaration

@interface CENObject (PluginsDeveloper)


#pragma mark - Information

/**
 * @brief  Stores reference on \b ChatEngine instance which created this object.
 */
@property (nonatomic, readonly, weak) CENChatEngine *chatEngine;


#pragma mark - Events emitting

/**
 * @brief      Emit specified \c event with passed variadic list of arguments locally.
 * @discussion This method is able to handle up to \b 5 parameters forwarding to handling \c block.
 * @discussion Event will be emitted on behalf of receiving object and it's containing \b ChatEngine instance.
 *
 * @param event Reference on name of event which should be emitted.
 * @param ...   Reference on list of parameters which should be passed to listener's handler block.
 */
- (void)emitEventLocally:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -


@end
