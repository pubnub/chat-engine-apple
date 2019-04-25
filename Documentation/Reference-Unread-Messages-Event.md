# CENUnreadMessagesEvent

Unread event payload has pre-defined structure described by `CENUnreadMessagesEvent` typedef.   

<a id="unreadmessagesevent-chat"/>

[`CENUnreadMessagesEvent.chat`](#unreadmessagesevent-chat)  
Key under which stored inactive [Chat](reference-chat) instance which received event.  

<a id="unreadmessagesevent-sender"/>

[`CENUnreadMessagesEvent.sender`](#unreadmessagesevent-sender)  
Key under which stored [User](reference-user) instance which represent user which sent event. 

<a id="unreadmessagesevent-event"/>

[`CENUnreadMessagesEvent.event`](#unreadmessagesevent-event)  
Key under which stored name of received event.  

<a id="unreadmessagesevent-count"/>

[`CENUnreadMessagesEvent.count`](#unreadmessagesevent-count)  
Key under which stored data number of messages which has been received so far while [chat](#unreadmessagesevent-chat) inactive.  