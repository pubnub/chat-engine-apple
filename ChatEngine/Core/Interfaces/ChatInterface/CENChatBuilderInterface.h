#import "CENInterfaceBuilder.h"

#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Chat instance creation/audition API interface builder.
 * @discussion Class describe interface which allow to create new \b CENChat instances or retrieve previously created.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2017 PubNub, Inc.
 */
@interface CENChatBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief      Specify chat name.
 * @discussion This name later will be used to get reference on chat instance and will be visible to invited users.
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^name)(NSString *name);

/**
 * @brief      Specify whether chat require owner's authorization to get access to it.
 * @discussion Public chat(s) can be accessed by any user, but \c private require it's owner to grant access rights to read
 *             and write.
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^private)(BOOL isPrivate);

/**
 * @brief      Specify whether chat should start receive updates on creation or not.
 * @discussion If set to \c YES, \b ChatEngine will subscribe for real-time updates for this chat.
 * @note       This parameter can be set only during chat instance creation.
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^autoConnect)(BOOL shouldAutoConnect);

/**
 * @brief      Meta data which should be appended to this chat.
 * @discussion Metadata publicly available for all chat participants.
 *             This option require to set \a enableMeta to \c YES in \b CENConfiguration which used for \b ChatEngine
 *             configuration.
 * @note       This parameter can be set only during chat instance creation.
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^meta)(NSDictionary * __nullable meta);

/**
 * @brief      Specify chat aggregation group name.
 * @discussion \b ChatEngine aggregate list of chats into group to help \b PubNub client to subscribe to them. Available
 *             values descrived by \c CENChatGroup structure.
 * @note       This parameter can be set only during chat instance creation.
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^group)(NSString * _Nullable group);


#pragma mark - Call

/**
 * @brief      Create new chat instance using passed parameters.
 * @discussion If \b CENChat with same parameters exists, it will be returned instead of new instance. Newly created instances
 *             are stored within \b ChatEngine and can be requested later with \c get method or using \b CENChatEngine
 *             property called 'chats'.
 */
@property (nonatomic, readonly, strong) CENChat * (^create)(void);

/**
 * @brief  Search for chat instance basing on passed parameters (name and \c isPrivate flag).
 */
@property (nonatomic, readonly, strong) CENChat * __nullable (^get)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
