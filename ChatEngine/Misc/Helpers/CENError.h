#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \a NSError interface extension.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENError : NSObject


#pragma mark - PubNub

/**
 * @brief Create \a NSError from \b PubNub error status object.
 *
 * @param status \b PubNub error status.
 *
 * @return Error based on \b PubNub error status.
 */
+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status;

/**
 * @brief Create \a NSError from \b PubNub error status object.
 *
 * @param status \b PubNub error status.
 * @param description Custom error status description.
 *
 * @return Error based on \b PubNub error status.
 */
+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status withDescription:(NSString *)description;

/**
 * @brief Create \a NSError from \b PubNub error status object.
 *
 * @param status \b PubNub error status.
 * @param userInfo \a NSDictionary which will be merged with data which has been received from
 *     \b PubNub error status object.
 *
 * @return Error based on \b PubNub error status.
 */
+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status withUserInfo:(NSDictionary *)userInfo;

/**
 * @brief Create \a NSError from \b PubNub Function call results.
 *
 * @param responses \a NSArray where one of them should be \c error which has been created using
 *     \b PubNub Function response.
 * @param description String which will be used as localized error description.
 *
 * @return Error based on \b PubNub Function response.
 */
+ (NSError *)errorFromPubNubFunctionError:(nullable NSArray *)responses
                          withDescription:(NSString *)description;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
