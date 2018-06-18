/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPPlugablePropertyStorage.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CEPPlugablePropertyStorage (Private)


#pragma mark - Information

/**
 * @brief  Stores reference on dictionary which is used as storage for object's properties.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary *storage;


#pragma mark - Properties binding

/**
 * @brief  Audit subclass properties and re-bind their ivars usage to plugable storage.
 */
+ (void)bindPropertiesIvarToStorage;


#pragma mark - Storage

/**
 * @brief  Create and configure new storage for object's properties.
 *
 * @return Reference on storage which is suitable to store values from all object's properties.
 */
+ (NSMutableDictionary *)newStorageForProperties;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
