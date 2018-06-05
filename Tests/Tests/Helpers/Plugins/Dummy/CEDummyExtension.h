#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENObject;


#pragma mark Interface declaration

@interface CEDummyExtension : CEPExtension


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 * @brief  Stores reference on property which will be set by \c extension's constructor
 *         (\c onCreate handler).
 */
@property (nonatomic, assign) BOOL constructWorks;


///------------------------------------------------
/// @name Extension methods
///------------------------------------------------

/**
 * @brief  Stores reference on method which provided by extension.
 * @discussion To prove ability to work, method will retrun reference on parent for which it has
 *             been registered.
 */
- (CENObject *)testMethodReturningParentObject;


#pragma mark -


@end
