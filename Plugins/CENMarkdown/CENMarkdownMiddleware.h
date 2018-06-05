#import <CENChatEngine/CEPMiddleware.h>


/**
 * @brief      \b CENChat events Markdown markup parser.
 * @discussion Middleware pre-process received events, for which it has been configured. If Markdown markup has been found in
 *             message payload under configured key, middleware will replace original data with \a NSAttributedString.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMarkdownMiddleware : CEPMiddleware


#pragma mark -


@end
