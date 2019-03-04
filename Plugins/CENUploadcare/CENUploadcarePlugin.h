#import <CENChatEngine/CEPPlugin.h>
#import "CENUploadcareFileInformation.h"
#import "CENUploadcareExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 54820b6c-21f4-4c8a-b986-35bf76ecf211
 */
typedef struct CENUploadcareConfigurationKeys {
    /**
     * @brief Application public key provided available in
     * \b {Uploadcare Dashboard https://uploadcare.com/dashboard/} after registration and used with
     * Uploadcare Upload API.
     *
     * @ref 386d13ca-483e-400a-8ecc-9f19238a6c5e
     */
    __unsafe_unretained NSString *publicKey;
} CENUploadcareConfigurationKeys;

extern CENUploadcareConfigurationKeys CENUploadcareConfiguration;


#pragma mark - Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} plugin for \b {Uploadcare https://uploadcare.com} files
 * sharing and received events pre-processing.
 *
 * @discussion This plugin allow to share file uploaded by
 * \b {Uploadcare Widget https://github.com/uploadcare/uploadcare-ios} with other \b {chat CENChat}
 * participants using file unique identifier.
 * \b {chat CENChat} participants will receive file with \b {$uploadcare.upload} event and
 * \b {CENUploadcareFileInformation} as model which represent that file.
 *
 * @discussion Setup with public key
 * @code
 * // objc da0a8ac5-a07e-4bde-95e0-65e73461a7ec
 *
 * self.chat.plugin([CENUploadcarePlugin class]).configuration(@{
 *     CENUploadcareConfiguration.publicKey: @"xxxxxxxxxxxxxxxxx"
 * }).store();
 *
 * self.chat.on(@"$uploadcare.upload", ^(CENEmittedEvent *event) {
 *     CENUploadcareFileInformation *info = ((NSDictionary *)event.data)[CENEventData.data];
 *
 *     NSLog(@"Received file which can be downloaded from: %@", info.url);
 * });
 * @endcode
 *
 * @ref e285663a-a86c-447b-b9dd-be9e4320ee3a
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUploadcarePlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Fetch information about \b {Uploadcare https://uploadcare.com} file and send it to
 * \b {chat CENChat}.
 *
 * @discussion This plugin is addition to
 * \b {Uploadcare Widget https://github.com/uploadcare/uploadcare-ios} which responsible for file
 * upload and should be integrated into application before plugin usage by following
 * \b {this https://github.com/uploadcare/uploadcare-ios#install} installation instruction.
 *
 * @discussion Share \b {Uploadcare https://uploadcare.com} file information by it's ID
 * @code
 * // objc bf4e80f8-7046-4fb9-8080-881ff5f06cf6
 *
 * UCMenuViewController *menu = nil;
 * menu = [[UCMenuViewController alloc] initWithProgress:^(NSUInteger sent, NSUInteger total) {
 *     // Handle progress here
 * } completion:^(NSString *fileId, id response, NSError *error) {
 *     if (!error) {
 *         [CENUploadcarePlugin shareFileWithIdentifier:fileId toChat:self.chat];
 *     }
 * }];
 *
 * [menu presentFrom:self];
 * @endcode
 *
 * @param identifier Unique identifier of file uploaded to \b {Uploadcare https://uploadcare.com}.
 * @param chat \b {Chat CENChat} to which file information should be sent.
 *
 * @ref 5540dcf4-8a01-4da2-aa34-af60dc4bc3b0
 */
+ (void)shareFileWithIdentifier:(NSString *)identifier toChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
