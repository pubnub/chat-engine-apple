#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} objects interface extension base class.
 *
 * @discussion Plugins which provide data objects extension support should bundle classes which is
 * subclass of this base class.
 *
 * @discussion Plugin developers should import class category
 * (\c {<CENChatEngine/CEPExtension+Developer.h>}) which provide interface with explanation about
 * how middleware should be written.
 *
 * @ref 7713c4f4-01fa-42ca-a0e1-46c2d96b742f
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CEPExtension : NSObject


#pragma mark -


@end

NS_ASSUME_NONNULL_END
