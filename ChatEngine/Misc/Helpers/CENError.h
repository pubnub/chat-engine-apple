#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  Useful NSError additions collection.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENError : NSObject


#pragma mark - PubNub

/**
 * @brief  Construct \a NSError instance from \b PubNub error status object.
 *
 * @param status Reference on \b PubNub error status.
 *
 * @return Reference on initialized error.
 */
+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status;

/**
 * @brief  Construct \a NSError instance from \b PubNub error status object.
 *
 * @param status      Reference on \b PubNub error status.
 * @param description Reference on custom error status description.
 *
 * @return Reference on initialized error.
 */
+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status withDescription:(NSString *)description;

/**
 * @brief  Construct \a NSError instance from \b PubNub error status object.
 *
 * @param status   Reference on \b PubNub error status.
 * @param userInfo Reference on dictionary which will be merged with data which has been received from \b PubNub error status object.
 *
 * @return Reference on initialized error.
 */
+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status withUserInfo:(NSDictionary *)userInfo;

/**
 * @brief  Construct \a NSError instance from \b PubNub error status object.
 *
 * @param functionError Reference on \c error instance which has been created using \b PubNub Function response.
 * @param description   Reference on string which will be used as localized error description.
 *
 * @return Reference on initialized error.
 */
+ (NSError *)errorFromPubNubFunctionError:(nullable NSError *)functionError withDescription:(NSString *)description;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
