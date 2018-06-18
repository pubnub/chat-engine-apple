#import "CENChatEngine.h"


#pragma mark Class forward

@class CENUser, CENMe;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client interface for \c user instance management.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (User)


#pragma mark - Information

/**
 * @brief  Reference on map of active user(s) stored under their unique identifiers.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENUser *> *users;

/**
 * @brief  Stores reference on \b CENUser subclass which represent local user for which \b ChatEngine has been configured.
 */
@property (nonatomic, nullable, readonly, strong) CENMe *me;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
