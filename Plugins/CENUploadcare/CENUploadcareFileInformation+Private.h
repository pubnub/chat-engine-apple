/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENUploadcareFileInformation.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENUploadcareFileInformation (Private)


#pragma mark - Initialization and configuration

/**
 * @brief Create and configure file information representation model.
 *
 * @param payload \b {Uploadcare https://uploadcare.com} Upload API \c file-info response.
 *
 * @return Configured and ready to use model.
 */
+ (instancetype)fileInformationFromPayload:(NSDictionary *)payload;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
