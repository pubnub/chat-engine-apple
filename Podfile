install! 'cocoapods', :lock_pod_sources => false
workspace 'ChatEngine.xcworkspace'
inhibit_all_warnings!
use_frameworks!

target '[iOS] Chat' do
  platform :ios, '9.0'
  project 'demo/chat-engine'
  pod "CENChatEngine/BuilderInterfaceOn", :path => "."
  pod "CENChatEngine/Plugin/UnreadMessages", :path => "."
  pod "CENChatEngine/Plugin/TypingIndicator", :path => "."
  pod "CENChatEngine/Plugin/RandomUsername", :path => "."
  pod "CENChatEngine/Plugin/Gravatar", :path => "."
  pod "CENChatEngine/Plugin/Markdown", :path => "."
  pod "CENChatEngine/Plugin/OnlineUserSearch", :path => "."
  pod "CENChatEngine/Plugin/PushNotifications", :path => "."
end
