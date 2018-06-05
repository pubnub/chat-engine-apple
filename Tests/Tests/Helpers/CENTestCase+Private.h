/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Private interface declaration

@interface CENTestCase (Private)


///------------------------------------------------
/// @name Classes
///------------------------------------------------

/**
 * @brief      Get reference on class which should be used to instantiate \b ChatEngine instance.
 * @discussion This method allow to provide stub'ed classes to control client's execution flow.
 *
 * @return Reference on class which should be used to instantiate \b ChatEngine.
 */
- (Class)chatEngineClass;

/**
 * @brief      Get reference on class which should be used to instantiate user synchronization
 *             \c session instance.
 * @discussion This method allow to provide stub'ed classes to control sessions's execution flow.
 *
 * @return Reference on class which should be used to instantiate synchronization \c session.
 */
- (Class)sessionClass;

/**
 * @brief      Get reference on class which should be used to instantiate \b ChatEngine chat
 *             instance.
 * @discussion This method allow to provide stub'ed classes to control chat's execution flow.
 *
 * @return Reference on class which should be used to instantiate \b ChatEngine chat.
 */
- (Class)chatClass;

/**
 * @brief      Get reference on class which should be used to instantiate \b ChatEngine user
 *             instance.
 * @discussion This method allow to provide stub'ed classes to control user's execution flow.
 *
 * @return Reference on class which should be used to instantiate \b ChatEngine user.
 */
- (Class)userClass;

/**
 * @brief      Get reference on class which should be used to instantiate \b ChatEngine local user
 *             instance.
 * @discussion This method allow to provide stub'ed classes to control local user execution flow.
 *
 * @return Reference on class which should be used to instantiate \b ChatEngine local user.
 */
- (Class)meClass;

#pragma mark -

@end
