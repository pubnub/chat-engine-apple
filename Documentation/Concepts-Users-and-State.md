### Users

[Users](reference-user) are other applications connected to the [Chat](reference-chat) via [ChatEngine](reference-chatengine). A [User](reference-user) represents a connected client.  

### Me

When a client calls [ChatEngine.connect](reference-chatengine#connect), they create a special [User](reference-user) called [Me](reference-me). [Me](reference-me) represents "this [User](reference-user) for this instance."  

[Me](reference-me) and [User](reference-user) are similar in many ways, with the main difference being that [Me](reference-me) has the ability to edit [Me.state](reference-me#state) via [Me.update](reference-me#update) while you can not updated some other [User.state](reference-user#state).

See [Me](reference-me) for more information.

### State

So how do we add other information to Users? Like a profile? We update [Me.state](reference-me#state) via [Me.update](reference-me#update).

This way, when any new client connects to the chat, their [Me](reference-me) object will update all the other clients about it's state.

Let's give [Me](reference-me) a unique username color. Here's a function to choose a random color.  
```objc
- (NSString *)color {

    NSArray<NSString *> *colors = @[
        @"AliceBlue", @"AntiqueWhite", @"Aqua", @"Aquamarine", @"Azure", @"Beige", @"Bisque", @"Black", 
        @"BlanchedAlmond", @"Blue", @"BlueViolet", @"Brown", @"BurlyWood", @"CadetBlue", @"Chartreuse", 
        @"Chocolate", @"Coral", @"CornflowerBlue", @"Cornsilk", @"Crimson", @"Cyan", @"DarkBlue", 
        @"DarkCyan", @"DarkGoldenRod", @"DarkGray", @"DarkGrey", @"DarkGreen", @"DarkKhaki", 
        @"DarkMagenta", @"DarkOliveGreen", @"Darkorange", @"DarkOrchid", @"DarkRed", @"DarkSalmon",  
        @"DarkSeaGreen", @"DarkSlateBlue", @"DarkSlateGray", @"DarkSlateGrey", @"DarkTurquoise", 
        @"DarkViolet", @"DeepPink", @"DeepSkyBlue", @"DimGray", @"DimGrey", @"DodgerBlue", @"FireBrick", 
        @"FloralWhite", @"ForestGreen", @"Fuchsia", @"Gainsboro", @"GhostWhite", @"Gold", @"GoldenRod", 
        @"Gray", @"Grey", @"Green", @"GreenYellow", @"HoneyDew", @"HotPink", @"IndianRed", @"Indigo", 
        @"Ivory", @"Khaki", @"Lavender", @"LavenderBlush", @"LawnGreen", @"LemonChiffon", @"LightBlue", 
        @"LightCoral", @"LightCyan", @"LightGoldenRodYellow", @"LightGray", @"LightGrey", @"LightGreen", 
        @"LightPink", @"LightSalmon", @"LightSeaGreen", @"LightSkyBlue", @"LightSlateGray",
        @"LightSlateGrey", @"LightSteelBlue", @"LightYellow", @"Lime", @"LimeGreen", @"Linen", @"Magenta", 
        @"Maroon", @"MediumAquaMarine", @"MediumBlue", @"MediumOrchid", @"MediumPurple", 
        @"MediumSeaGreen", @"MediumSlateBlue", @"MediumSpringGreen", @"MediumTurquoise",
        @"MediumVioletRed", @"MidnightBlue", @"MintCream", @"MistyRose", @"Moccasin", @"NavajoWhite", 
        @"Navy", @"OldLace", @"Olive", @"OliveDrab", @"Orange", @"OrangeRed", @"Orchid", @"PaleGoldenRod", 
        @"PaleGreen", @"PaleTurquoise", @"PaleVioletRed", @"PapayaWhip", @"PeachPuff", @"Peru", @"Pink",
        @"Plum", @"PowderBlue", @"Purple", @"Red", @"RosyBrown", @"RoyalBlue", @"SaddleBrown", @"Salmon", 
        @"SandyBrown", @"SeaGreen", @"SeaShell", @"Sienna", @"Silver", @"SkyBlue", @"SlateBlue",
        @"SlateGray", @"SlateGrey", @"Snow", @"SpringGreen", @"SteelBlue", @"Tan", @"Teal", @"Thistle", 
        @"Tomato", @"Turquoise", @"Violet", @"Wheat", @"White", @"WhiteSmoke", @"Yellow", @"YellowGreen"];

    return colors[(arc4random() % colors.count)];
}
```  

We can update [Me's](reference-me) state on the network with the [Me.update](reference-me#update) method.  
```objc
me.update(@{ @"color": [self color] });
```

Then we can listen for the sate event in other applications via [$.state](reference-chatengine#event-state):  
```objc
self.client.on(@"$.state", ^(CENUser *user) {
    NSLog(@"'%@' updated state: %@", user.uuid, user.state);
});
```

You can set [Me.state](reference-me#state) during connection by supplying it to [ChatEngine.connect](reference-chatengine#connect) constructor.  
```objc
self.client.connect(@"serhii").state(@{ @"color": [self color] }).perform();
```

What if we want to get [User's](reference-state) state some other time without events? You can simply check for [User.state](reference-user#state) property.  
```objc
// Get last known connected user.
CENUser *user = self.client.users.allValues.lastObject;

// Output the user's state.
NSLog(@"'%@' state: %@", user.uuid, user.state);
```