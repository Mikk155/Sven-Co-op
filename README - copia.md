
[utils](#utils) | utils is a script that contains alot of useful features and code that is being shared with my other scripts so in most of the cases you have to include this script.




# utils
**Introduction:**

utils is a script that contains alot of useful features and code that is being shared with my other scripts so in most of the cases you have to include this script.






### Basically FireTargets but we use this for custom entities to allow them to do use of [USE_TYPE](#utils-use-type)
```angelscript
g_Util.Trigger( string& in key, CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE& in useType = USE_TOGGLE, float& in flDelay = 0.0f )
```






### Send a string, replace the arguments sent, return the new string.
```angelscript
g_Util.StringReplace( string_t FullSentence, dictionary@ pArgs )
```
**Sample:**
```angelscript
g_Util.StringReplace( "this !number-st test for !activator", { { "!number", self.pev.frags }, { "!activator", pActivator.pev.netname }, } );
```
Then it will return a string like this
```angelscript
"this 1-st test for Mikk"
```






### Shows a motd to the given player.
```angelscript
g_Util.ShowMOTD( EHandle hPlayer, const string& in szTitle, const string& in szMessage )
```






### Shows a message to client's console if the next function is set.
```angelscript
g_Util.Debug( const string& in szMessage )
```






### Set to true and messages will be shown.
```angelscript
g_Util.DebugMode( const bool& in blmode = false )
```






### Return as a string the value of the given custom keyvalue from the given entity.
```angelscript
g_Util.GetCKV( CBaseEntity@ pEntity, string szKey )
```






### Set a custom keyvalue for the given entity.
```angelscript
g_Util.SetCKV( CBaseEntity@ pEntity, string szKey, string szValue )
```






### Boolean that returns true if the given text file contains szComparator as a line. use as a blacklist by giving g_Engine.mapname
```angelscript
g_Util.IsStringInFile( const string& in szPath, string& in szComparator )
```






### Boolean that returns true if the given plugin name is installed.
```angelscript
g_Util.IsPluginInstalled( const string& in szPluginName )
```






### Set information for this map/script. will be shown when a player connects or type in chat "/info"
```angelscript
g_Util.ScriptAuthor.insertLast
    (
        "Map: "+ string( g_Engine.mapname ) +"\n"
        "Author: Mikk\n"
        "Github: github.com/Mikk155\n"
        "Description: Test almost of the scripts.\n"
    );
```












### Supported Languages
| key to show | value from player |
|-------------|-------------------|
| message | english or empty |
| message_spanish | spanish |
| message_spanish2 | spanish spain |
| message_portuguese | portuguese |
| message_german | german |
| message_french | french |
| message_italian | italian |
| message_esperanto | esperanto |
| message_czech | czech |
| message_dutch | dutch |
| message_indonesian | indonesian |
| message_romanian | romanian |
| message_turkish | turkish |
| message_albanian | albanian |
