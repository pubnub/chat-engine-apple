## [0.9.3](https://github.com/pubnub/chat-engine-apple/releases/tag/v0.9.3)
March 1 2019

#### Added
- Added plugins: Event Status, Emoji, Mute, OpenGraph, Uploadcare.
  - Added by [parfeon](https://github.com/parfeon) in Pull Request [#24](https://github.com/pubnub/chat-engine-apple/pull/24).

#### Updated
- Improved event handler to make it easy to use with Swift.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#24](https://github.com/pubnub/chat-engine-apple/pull/24).
- Updated search filters to work via plugin structure.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#24](https://github.com/pubnub/chat-engine-apple/pull/24).
- Typing indicator plugin will reset 'typing' state as soon as user emit message to chat.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#24](https://github.com/pubnub/chat-engine-apple/pull/24).

#### Removed
- Deprecated 'group' parameter during CENChat instance creation in favor of usage simplicity since all user-made chats should be part of 'custom' group.
  - Removed by [parfeon](https://github.com/parfeon) in Pull Request [#24](https://github.com/pubnub/chat-engine-apple/pull/24).

#### Fixed
- Fixed middleware execution queue.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#24](https://github.com/pubnub/chat-engine-apple/pull/24).

## [0.9.2](https://github.com/pubnub/chat-engine-apple/releases/tag/v0.9.2)
August 23 2018

#### Added
- Added VCR and fixtures for integration tests and updated existing unit tests.
  - Added by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).

#### Updated
- Disabled presence heartbeat by default and switched _heartbeat interval_ to **300** seconds by default.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Ordered connection to user's personal chats and state refresh bound to it.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Ordered user connection steps in part of: updating state followed by connection to PubNub network and synchronization of chats if required.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Improved received events processing in part of sender name resolution - user's state won't be fetched if it is local user.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Improved connection to chats in part of session synchronization - synchronization events won't be sent for _system_ chats.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Improved connection to chats in part of participants fetch - now only one request after small delay will be done only for user's chats ignoring _system_ chats.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Updated `onAny` emitter logic to unify handling block signature.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Updated default logger configuration to verbose for `DEBUG` environment and shutdown by default for any other.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).

#### Removed
- Removed outdated code from `CEPMiddleware`.
  - Removed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).

#### Fixed
- Fixed crash which has been caused by attempt to publish using not connected `ChatEngine` instance.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed cross-thread race of condition in access to synchronized chats and groups in `CENSession`.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed issue with error created from multiple requests to _PubNub Function_.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed queue dead-lock when awakening chat.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed queue dead-lock when tried to print out information about user from one of callbacks.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed _pluggable instance_ property storage getters for _float_ and _doubles_.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed pluggable instance property storage setter for C string to remove them when NULL passed.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed _middleware_ check for whether registered for specific event or not.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed extension's `configuration` property to be strong, because sometimes it became `nil` during usage.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).
- Fixed random tests from usage of `OCMock` library.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#19](https://github.com/pubnub/chat-engine-apple/pull/19).


## [0.9.1](https://github.com/pubnub/chat-engine-apple/releases/tag/v0.9.1)
June 22 2018

#### Added
- Missing `CENNotificationsPlugin` integration test.
  - Added by [parfeon](https://github.com/parfeon) in Pull Request [#3](https://github.com/pubnub/chat-engine-apple/pull/3).

#### Removed
- Removed redundant `ignoredChats` configuration option from `CENNotificationsPlugin`.
  - Removed by [parfeon](https://github.com/parfeon) in Pull Request [#3](https://github.com/pubnub/chat-engine-apple/pull/3).

#### Fixed
- Missing `CHATENGINE_USE_BUILDER_INTERFACE` macro redefinition error.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#3](https://github.com/pubnub/chat-engine-apple/pull/3).


## [0.9.0](https://github.com/pubnub/chat-engine-apple/releases/tag/v0.9.0)
June 6 2018

#### Added
- Initial release of `ChatEngine`.
  - Added by [parfeon](https://github.com/parfeon).