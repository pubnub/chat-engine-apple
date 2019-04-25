# CENEventData

Received / emitted event payload has pre-defined structure described by `CENEventData` typedef.  

<a id="eventdata-data"/>

[`CENEventData.data`](#eventdata-data)  
Key under which stored data emitted by [sender](#eventdata-sender).  

<a id="eventdata-sender"/>

[`CENEventData.sender`](#eventdata-sender)  
Key under which stored [User](reference-user) instance which represent user which sent this event.  

<a id="eventdata-chat"/>

[`CENEventData.chat`](#eventdata-chat)  
Key under which stored [Chat](reference-chat) instance which received [event](eventdata-event).  

<a id="eventdata-event"/>

[`CENEventData.event`](#eventdata-event)  
Key under which stored name of emitted event.  

<a id="eventdata-eventid"/>

[`CENEventData.eventID`](#eventdata-eventid)  
Key under which stored unique event identifier.  

<a id="eventdata-timetoken"/>

[`CENEventData.timetoken`](#eventdata-timetoken)  
Key under which stored timetoken representing date when event has been `emitted`.  

<a id="eventdata-sdk"/>

[`CENEventData.sdk`](#eventdata-sdk)  
Key under which stored version of [ChatEngine](reference-chatengine) SDK which `emitted` this [event](#eventdata-event).  