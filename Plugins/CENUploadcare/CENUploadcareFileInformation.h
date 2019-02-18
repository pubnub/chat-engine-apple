#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Uploadcare https://uploadcare.com} uploaded file representation model.
 *
 * @ref 09763e4c-9d45-40ac-9d0e-425534ad0450
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUploadcareFileInformation : NSObject


#pragma mark - Information

/**
 * @brief Uploaded file unique identifier.
 *
 * @ref c1132e26-f2a0-426b-8e94-3701b54832f3
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 * @brief Name of file which has or will be uploaded.
 *
 * @ref 86a5391e-2084-4654-9690-8074341d0b08
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * @brief Size of uploaded file in bytes.
 *
 * @ref 87ea9e75-d8dc-4e7b-bbf8-6d5e31a1fd97
 */
@property (nonatomic, readonly, strong) NSNumber *size;

/**
 * @brief Whether uploaded files has been stored persistently or not.
 *
 * @ref f2f4f967-59b8-4933-99c1-4b52223765bf
 */
@property (nonatomic, readonly, assign) BOOL isStored;

/**
 * @brief Whether image file has been uploaded or not.
 *
 * @ref a7da1a09-c7a3-4790-88f2-a78defb4c5c8
 */
@property (nonatomic, readonly, assign) BOOL isImage;

/**
 * @brief Public file CDN URL which may contain
 * \b {CDN operations https://uploadcare.com/docs/delivery/}
 *
 * @ref 023c998e-ab61-48ea-a4e2-bcb9625b35f9
 */
@property (nonatomic, readonly, strong) NSURL *url;

/**
 * @brief URL part with applied \b {CDN operations https://uploadcare.com/docs/delivery/} or
 * null.
 *
 * @ref 56717bba-2553-4505-9ec4-525df784b5b2
 */
@property (nonatomic, nullable, readonly, copy) NSString *urlModifiers;

/**
 * @brief Public file CDN URL without any operations.
 *
 * @ref 9c313770-048f-4386-92ef-2fc54885d649
 */
@property (nonatomic, readonly, strong) NSURL *originalURL;

/**
 * @brief Original image width.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref e201c01a-ce04-4a0d-91a1-fea6be184b39
 */
@property (nonatomic, nullable, readonly, strong) NSNumber *width;

/**
 * @brief Original image height.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref 30773755-e3d7-4e6d-aed7-954fe32184b1
 */
@property (nonatomic, nullable, readonly, strong) NSNumber *height;

/**
 * @brief Original image file format.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref 315bdb19-0ba4-4b0b-a314-151d0b3b8b88
 */
@property (nonatomic, nullable, readonly, copy) NSString *format;

/**
 * @brief Original image EXIF latitude.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref 9977ec76-ed0b-4208-be9f-1d68796ca0eb
 */
@property (nonatomic, nullable, readonly, strong) NSNumber *latitude;

/**
 * @brief Original image EXIF longitude.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref e46fd795-3407-4daf-ba19-9b5fc5e3756e
 */
@property (nonatomic, nullable, readonly, strong) NSNumber *longitude;

/**
 * @brief Original image EXIF orientation.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref e11ae125-32f3-45b1-88e8-9093760cffef
 */
@property (nonatomic, nullable, readonly, copy) NSString *orientation;

/**
 * @brief Original image EXIF creation date.
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref 0541d3d8-c6b6-46b9-a4df-7fbce2077451
 */
@property (nonatomic, nullable, readonly, strong) NSDate *date;

/**
 * @brief Information about image resolution (DPI).
 *
 * @note Information available only if image file has been uploaded.
 *
 * @ref cf4c29f2-dfa8-44c8-b7de-abf13a30e1e5
 */
@property (nonatomic, nullable, readonly, strong) NSArray<NSNumber *> *resolution;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
