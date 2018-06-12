Pod::Spec.new do |spec|
    spec.name     = 'CENChatEngine'
    spec.version  = '0.9.13'
    spec.summary  = 'Framework for building chat applications.'
    spec.homepage = 'https://github.com/pubnub/chat-engine-apple'

    spec.authors = {
        'PubNub, Inc.' => 'support@pubnub.com'
    }
    spec.social_media_url = 'https://twitter.com/pubnub'
    spec.source = {
        :git => 'https://github.com/pubnub/chat-engine-apple.git',
        :tag => "v#{spec.version}"
    }

    spec.ios.deployment_target = '8.0'
    spec.osx.deployment_target = '10.9'
    spec.tvos.deployment_target = '9.0'
    spec.requires_arc = true

    spec.subspec 'Core' do |core|
        core.source_files = 'ChatEngine/{Core,Data,Misc,Network,Plugin}/**/*', 'ChatEngine/ChatEngine.h'
        core.private_header_files = [
            'ChatEngine/Core/{Emitter,Publish,Search,Session}/*.h',
            'ChatEngine/Data/Managers/*.h',
            'ChatEngine/**/*Private.h',
            'ChatEngine/Misc/{CENConstants,CENPrivateStructures}.h',
            'ChatEngine/Misc/Helpers/*.h',
            'ChatEngine/Network/**/*.h',
            'ChatEngine/Plugin/CEPPrivateStructures.h'
        ]
        core.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    end
    
    spec.subspec 'BuilderInterfaceOn' do |bulderInterface|
        bulderInterface.dependency 'CENChatEngine/Core'
        bulderInterface.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'CHATENGINE_USE_BUILDER_INTERFACE=1' }
        bulderInterface.pod_target_xcconfig = { 
            'APPLICATION_EXTENSION_API_ONLY' => 'YES',
            'GCC_PREPROCESSOR_DEFINITIONS' => 'CHATENGINE_USE_BUILDER_INTERFACE=1' 
        }
    end


    spec.subspec 'BuilderInterfaceOff' do |bulderInterface|
        bulderInterface.dependency 'CENChatEngine/Core'
        bulderInterface.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'CHATENGINE_USE_BUILDER_INTERFACE=0' }
        bulderInterface.pod_target_xcconfig = { 
            'APPLICATION_EXTENSION_API_ONLY' => 'YES',
            'GCC_PREPROCESSOR_DEFINITIONS' => 'CHATENGINE_USE_BUILDER_INTERFACE=0' 
        }
    end

    spec.subspec 'Plugin' do |plugin|
        plugin.subspec 'Core' do |core|
            core.source_files = 'CENChatEngine/Plugin/**/*'
            core.private_header_files = [
                'ChatEngine/**/*Private.h',
                'ChatEngine/Plugin/CEPPrivateStructures.h'
            ]
        end

        plugin.subspec 'TypingIndicator' do |typingIndicator|
            typingIndicator.dependency 'CENChatEngine/Plugin/Core'
            typingIndicator.source_files = 'Plugins/CENTypingIndicator/**/*'
        end

        plugin.subspec 'RandomUsername' do |randomUsername|
            randomUsername.dependency 'CENChatEngine/Plugin/Core'
            randomUsername.source_files = 'Plugins/CENRandomUsername/**/*'
        end

        plugin.subspec 'UnreadMessages' do |unreadMessages|
            unreadMessages.dependency 'CENChatEngine/Plugin/Core'
            unreadMessages.source_files = 'Plugins/CENUnreadMessages/**/*'
        end

        plugin.subspec 'Markdown' do |markdown|
            markdown.dependency 'CENChatEngine/Plugin/Core'
            markdown.source_files = 'Plugins/CENMarkdown/**/*'
        end

        plugin.subspec 'Gravatar' do |gravatar|
            gravatar.dependency 'CENChatEngine/Plugin/Core'
            gravatar.source_files = 'Plugins/CENGravatar/**/*'
        end

        plugin.subspec 'OnlineUserSearch' do |onlineUserSearch|
            onlineUserSearch.dependency 'CENChatEngine/Plugin/Core'
            onlineUserSearch.source_files = 'Plugins/CENOnlineUserSearch/**/*'
        end

        plugin.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    end

    spec.dependency 'PubNub'
    spec.default_subspec = 'BuilderInterfaceOn'


    spec.license = { 
        :type => 'MIT', 
        :text => <<-LICENSE
            PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
            Copyright (c) 2018 PubNub Inc.
            http://www.pubnub.com/
            http://www.pubnub.com/terms

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in
            all copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
            THE SOFTWARE.

            PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
            Copyright (c) 2014 PubNub Inc.
            http://www.pubnub.com/
            http://www.pubnub.com/terms
        LICENSE
    }
end
