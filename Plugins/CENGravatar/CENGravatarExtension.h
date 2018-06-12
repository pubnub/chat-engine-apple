#import <CENChatEngine/CEPExtension.h>


/**
 * @brief      \b CENMe email address to Gravatar image URL extension.
 * @discussion Plugin workhorse which use provided configuration to identify user's email storage location in \c state and generate Gravatar
 *             URL for it. After URL generated extension will use configuration to figure out under which key it should be stored in \b CENMe
 *             state.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENGravatarExtension : CEPExtension


#pragma mark -


@end
