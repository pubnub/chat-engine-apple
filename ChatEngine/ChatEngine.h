#ifndef ChatEngine_h
#define ChatEngine_h


#pragma mark Core

#import "CENChatEngine.h"
#import "CENChatEngine+Connection.h"
#import "CENChatEngine+PubNub.h"
#import "CENChatEngine+Chat.h"
#import "CENChatEngine+User.h"
#import "CENEmittedEvent.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENChatEngine+BuilderInterface.h"

    #import "CENChatEngine+ChatBuilderInterface.h"
    #import "CENChatBuilderInterface.h"

    #import "CENChatEngine+AuthorizationBuilderInterface.h"

    #import "CENChatEngine+ConnectionBuilderInterface.h"
    #import "CENUserConnectBuilderInterface.h"

    #import "CENChatEngine+PluginsBuilderInterface.h"
    #import "CENPluginsBuilderInterface.h"

    #import "CENChatEngine+UserBuilderInterface.h"
    #import "CENUserBuilderInterface.h"
#else
    #import "CENChatEngine+ChatInterface.h"

    #import "CENChatEngine+Authorization.h"

    #import "CENChatEngine+ConnectionInterface.h"

    #import "CENChatEngine+Plugins.h"

    #import "CENChatEngine+UserInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE


#pragma mark - Data

#import "CENConfiguration.h"
#import "CENSession.h"
#import "CENEvent.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENEventEmitter+BuilderInterface.h"

    #import "CENChat+BuilderInterface.h"
    #import "CENChatSearchBuilderInterface.h"
    #import "CENChatEmitBuilderInterface.h"

    #import "CENEvent+BuilderInterface.h"
    #import "CENSearch+BuilderInterface.h"

    #import "CENObject+PluginsBuilderInterface.h"
    #import "CENUser+BuilderInterface.h"

    #import "CENMe+BuilderInterface.h"
    #import "CENSession+BuilderInterface.h"
#else
    #import "CENEventEmitter+Interface.h"

    #import "CENChat+Interface.h"

    #import "CENSearch+Interface.h"

    #import "CENObject+Plugins.h"
    #import "CENMe+Interface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENErrorCodes.h"
#import "CENStructures.h"
#import "CENLogMacro.h"

#endif // ChatEngine_h
