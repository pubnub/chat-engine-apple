/**
 * @brief Set of defines which is used by \b {ChatEngine CENChatEngine} client internally.
 *
 * @author Serhii Mamontov
 * @since 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
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


