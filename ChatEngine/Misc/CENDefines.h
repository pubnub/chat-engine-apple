/**
 * @brief Set of defines which is used by \b {CENChatEngine} client internally.
 *
 * @author Serhii Mamontov
 * @since 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#ifndef CENDefines_h
#define CENDefines_h


#pragma once

#define CENWeakify(variable) __weak __typeof(variable) CENWeak_##variable = variable;
#define CENStrongify(variable) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof(variable) variable = CENWeak_##variable; \
_Pragma("clang diagnostic pop")

#endif
