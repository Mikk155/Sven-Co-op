//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../mikk/fft"
#include "../../mikk/json"
#include "../../mikk/datashared"
#include "../../mikk/UserMessages"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( "plugins/mikk/dynamic_hostname.json" );
}

json pJson;

void MapActivate()
{
    // Delayed due to how we obtain some data
    g_Scheduler.SetTimeout( 'SetHostname', 5.0f );
}

void SetHostname()
{
    string m_iszHostName = pJson[ 'CONFIG', {} ][ "DYNAMIC_HOSTNAME", '' ];

    m_iszHostName.Replace( "$hostname$", pJson[ 'CONFIG', {} ][ "HOSTNAME", '' ] );

    m_iszHostName.Replace( "$maps$", GetMapName() );

    m_iszHostName.Replace( "$antirush$", GetAntiRush() );

    m_iszHostName.Replace( "$difficulty$",
        ( string( datashared::GetData( 'DynamicDifficultyDeluxe' )[ "diff" ] ) == String::INVALID_INDEX ?
            pJson[ 'CONFIG', {} ][ "DISABLED", '' ] : string( datashared::GetData( 'DynamicDifficultyDeluxe' )[ "diff" ] ) )
    );

    m_iszHostName.Replace( "$survival$", pJson[ 'CONFIG', {} ][ ( g_SurvivalMode.MapSupportEnabled() ? "ENABLED" : "DISABLED" ), '' ] );

    g_EngineFuncs.ServerCommand( "hostname \"" + m_iszHostName + "\"\n" );
    g_EngineFuncs.ServerExecute();

    // Update score board on connected clients
    UserMessages::ServerName( m_iszHostName );
}

string GetMapName()
{
    string mapname = string( g_Engine.mapname ).ToLowercase();
    mapname.ToLowercase();

    json g_Maps = pJson[ "MAPS", {} ];

    const array<string> strMaps = g_Maps.getKeys();

    for( uint i = 0; i < strMaps.length(); i++ )
    {
        string key = strMaps[i];
        key.ToLowercase();

        if(
            ( key == mapname )
        ||
            ( key.EndsWith( "*", String::CaseInsensitive ) && mapname.StartsWith( key.SubString( 0, key.Length() -1 ) ) )
        ||
            ( key.StartsWith( "*", String::CaseInsensitive ) && mapname.EndsWith( key.SubString( 1, key.Length() ) ) )
        ){
            mapname = string( g_Maps[ key ] );
            break;
        }
    }
    return mapname;
}

string GetAntiRush()
{
    string antirush = pJson[ 'CONFIG', {} ][ "DISABLED", '' ];

    // Known antirush entities
    array<string> strAntirush =
    {
        "trigger_once_mp",
        "trigger_multiple_mp",
        "antirush",
        "anti_rush"
    };

    for( uint i = 0; i < strAntirush.length(); i++ )
    {
        CBaseEntity@ pAntiRush = null;

        while( ( @pAntiRush = g_EntityFuncs.FindEntityByClassname( pAntiRush, strAntirush[i] ) ) !is null )
        {
            antirush = pJson[ 'CONFIG', {} ][ "ENABLED", '' ];
            break;
        }
    }

    return antirush;
}