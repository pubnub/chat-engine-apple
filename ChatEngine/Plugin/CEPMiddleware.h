#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} objects events processing middleware base class.
 *
 * @discussion Plugins which provide middleware support should bundle classes which is subclass of
 * this base class.
 *
 * @discussion Plugin developers should import class category
 * (\c {<CENChatEngine/CEPMiddleware+Developer.h>}) which provide interface with explanation about how
 * middleware should be written.
 *
 * @ref af3a9e8a-6162-4a7b-98f4-88764f8bccf1
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CEPMiddleware : NSObject


#pragma mark -


@end

NS_ASSUME_NONNULL_END
