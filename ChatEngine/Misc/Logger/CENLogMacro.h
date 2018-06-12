/**
 * @brief  Define list of macro which used by clien't component to print out messages using
 *         \b PNLLogger.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <PubNub/PNLLogger.h>
#import "CENStructures.h"

#pragma once

#define CENLOG(logger, level, frmt, ...) [logger log:level format:frmt, ##__VA_ARGS__]
#define CELogClientInfo(logger, frmt, ...) CENLOG(logger, CENInfoLogLevel, frmt, ##__VA_ARGS__)
#define CELogClientExceptions(logger, frmt, ...) CENLOG(logger, CENExceptionsLogLevel, frmt, ##__VA_ARGS__)
#define CELogEventEmit(logger, frmt, ...) CENLOG(logger, CENEventEmitLogLevel, frmt, ##__VA_ARGS__)
#define CELogResourceAllocation(logger, frmt, ...) CENLOG(logger, CENResourcesAllocationLogLevel, frmt, ##__VA_ARGS__)


