#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for \b {Uploadcare https://uploadcare.com} data
 * share support.
 *
 * @ref 07e89ef4-ef47-4aed-8771-af0a87b55138
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUploadcareExtension : CEPExtension


#pragma mark - File share

/**
 * @brief Fetch information about \b {Uploadcare https://uploadcare.com} file and send it to
 * \b {chat CENChat}.
 *
 * @discussion Share \b {Uploadcare https://uploadcare.com} file information by it's ID
 * @code
 * // objc 7d140375-1e56-426d-bd34-3a5e5ac09b53
 *
 * CENUploadcareExtension *extension = self.chat.extension([CENUploadcarePlugin class]);
 * [extension shareFileWithIdentifier:@"8e92b914-93a6-490d-84ae-b8a7077aa957"];
 * @endcode
 *
 * @param identifier Unique identifier of file uploaded to \b {Uploadcare https://uploadcare.com}.
 *
 * @ref 98a3784d-3e8c-4558-b8e1-836fb33a476c
 */
- (void)shareFileWithIdentifier:(NSString *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
