/*
    INSTALL:
    └──📁svencoop
        ├───📁scripts
        │   ├───📁maps
        │   │   └───📁mikk
        │   │       └───📄bloodpuddle.as
        │   └───📁plugins
        │       └───📁mikk
        │           └───📄bloodpuddle.as
        │
        └──📁models  
           └───📁mikk  
               └───📁misc  
                   └───📄bloodpuddle.mdl

    "plugin"
    {
        "name" "bloodpuddle"
        "script" "mikk/bloodpuddle"
    }
*/

#include "../../maps/mikk/bloodpuddle"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo
    (
        "Github: https://github.com/Gaftherman
        Discord: https://discord.gg/VsNnE3A7j8 \n"
    );
}

void MapInit()
{
    RegisterBloodPuddle();
}