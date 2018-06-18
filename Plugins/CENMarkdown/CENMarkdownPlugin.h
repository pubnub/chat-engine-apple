#import <CENChatEngine/CEPPlugin.h>
#import "CENMarkdownParser.h"


#pragma mark Structures

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CENMarkdownConfigurationKeys {
    
    /**
     * @brief  Stores reference on name of key under which stored list of event names for which plugin should be used.
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief  Stores reference on name of key under which stored name of key in \a data payload where string with Markdown
     *         markup is stored.
     */
    __unsafe_unretained NSString *messageKey;
    
    /**
     * @brief      Stores reference on name of key under which stored dictionary with \b CENMarkdownParser configuration
     *             options.
     * @discussion \b CENMarkdownParser allow to configure fonts which should be used for various traits by specifying keys
     *             used by \a NSAttributedString. Please see \b CENMarkdownParser header for more information about
     *             configuration options.
     */
    __unsafe_unretained NSString *parserConfiguration;
} CENMarkdownConfigurationKeys;

extern CENMarkdownConfigurationKeys CENMarkdownConfiguration;


/**
 * @brief      \b CEChat typing indicator plugin.
 * @discussion This plugin adds the ability to send updates when user start / stop typing message.
 *
 * @discussion Register plugin which by default handle 'message' events with 'text' message key:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();
 * @endcode
 *
 * @discussion Register plugin for custom events and bold font:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENMarkdownConfiguration.events: @[@"ping", @"pong"],
 *     CENMarkdownConfiguration.parserConfiguration: @{
 *         CENMarkdownParserElement.boldAttributes: @{
 *             // For macOS use corresponding classes.
 *             NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f],
 *             NSForegroundColorAttributeName: [UIColor redColor]
 *         }
 *     }
 * }).store();
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMarkdownPlugin : CEPPlugin


#pragma mark -


@end
