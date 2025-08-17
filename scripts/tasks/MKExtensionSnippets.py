from tasks.task import Task, Asset;

from utils.Path import Path;
from utils.Logger import Logger;

import json;

# prefix | body | description
g_Snippets: list[tuple[str]] = [
(
"Extension",
"""
namespace Extensions
{
    namespace ${1:Extension name}
    {
        // You can register your own logger but idealy do after the plugin is being propertly registered.
        CLogger@ Logger;

        /**
        *   This is obligatory and must be the namespace in string form.
        **/
        string GetName()
        {
            return "${2:Extension name}";
        }

        /**
        *   Called when the extension is initialized
        *   @info
        *       ExtensionIndex: Contains the index for the current extension if needed to notice server ops to update the installation hierarchy.
        **/
        void OnExtensionInit( Hooks::IExtensionInit@ info )
        {
            @Logger = CLogger( "${3:Logger name}" );
            Logger.info( "Registered \\"" + GetName() + "\\" at index \\"" + info.ExtensionIndex + "\\"" );
        }
    }
}""",
"Extension workspace"
),
(
"HookCode::Continue",
"HookCode::Continue",
"Continue calling other hooks"
),
(
"HookCode::Break",
"HookCode::Break",
"Stop iteration to prevent subsequent extension's hooks from being called"
),
(
"HookCode::Handle",
"HookCode::Handle",
"Handle vanilla and metamod plugins. equivalent to HOOK_HANDLED"
),
(
"HookCode::Supercede",
"HookCode::Supercede",
"Handle the original game's call (metamod API only)"
),
(
"OnPluginInit",
"""
void OnPluginInit( Hooks::IHookInfo@ info )
{
    ${1:}
}""",
"Called when all extensions has been initialized. this is the last action in the plugin's PluginInit method."
),
(
"OnMapActivate",
"""
void OnMapActivate( Hooks::IMapActivate@ info )
{
    // Number of entities in the world (only BSP)
    int numb_ents = info.NumberOfEntities;
    ${1:}
}""",
"Called by MapActivate."
),
(
"OnMapChange",
"""
void OnMapChange( Hooks::IMapChange@ info )
{
    // map name the game is changing to
    string map = info.NextMap;

    /**
        Type of level change

        Hooks::MapChangeType::Unknown
        Hooks::MapChangeType::SurvivalRoundEnd
        Hooks::MapChangeType::TriggerChangelevel
        Hooks::MapChangeType::PlayerLoadSaved
        Hooks::MapChangeType::GameEnd
        Hooks::MapChangeType::MapCycleTimeOut
        Hooks::MapChangeType::FragsLimitReached
    **/
    Hooks::MapChangeType type = info.Type;
    ${1:}
}""",
"Called when the map is changing"
),
(
"OnMapInit",
"""
void OnMapInit( Hooks::IHookInfo@ info )
{
    ${1:}
}""",
"Called by MapInit."
),
(
"OnMapStart",
"""
void OnMapStart( Hooks::IHookInfo@ info )
{
    ${1:}
}""",
"Called by MapStart."
),
(
"OnMapThink",
"""
void OnMapThink( Hooks::IHookInfo@ info )
{
    ${1:}
}""",
"Called every server frame starting after MapActivate until the map is changing."
),
(
"OnPluginExit",
"""
void OnPluginExit( Hooks::IHookInfo@ info )
{
    ${1:}
}""",
"Called by PluginExit."
),
];

# -TODO Make this recolect info from the .as files at events/

class MKManagerSnippets( Task ):
#
    logger = Logger( "MKExtensionSnippets" );

    Snippets: dict = {};
    
    @property
    def Snippet( self ) -> dict:
    #
        return {
            "scope": "angelscript",
            "prefix": [ "mkextension", "extension", "Hook" ],
            "description": "[MKExtension plugin] "
        };
    #

    def Run( self, assets: list[Asset] ) -> int:
    #
        for gsnippet in g_Snippets:
        #
            msnippet: dict = self.Snippet;

            prefixes: list[str] = msnippet[ "prefix" ];
            prefixes.append( gsnippet[0] );
            msnippet[ "prefix" ] = prefixes;

            description: str = msnippet[ "description" ];

            msnippet[ "body" ] = "/**\n\t" + description + "\n**/" + gsnippet[1];

            description += gsnippet[2];
            msnippet[ "description" ] = description;

            self.Snippets[ gsnippet[0] ] = msnippet;
        #

        with open( Path.enter( ".vscode", "MKExtension.code-snippets" ), "w" ) as VSCodeSnippets:
        #
            VSCodeSnippets.write( json.dumps( self.Snippets, indent=4 ) );
        #

        return 0;
    #
#
