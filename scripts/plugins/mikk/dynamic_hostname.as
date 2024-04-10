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

#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    pJson.load( "plugins/mikk/dynamic_hostname" );
}

json pJson;

void MapActivate()
{
    g_Scheduler.SetTimeout( 'SetHostname', 10.0f );
}

void SetHostname()
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

    json config = pJson[ 'CONFIG', {} ];

    string antirush = config[ "DISABLED" ];

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
            antirush = config[ "ENABLED" ];
            break;
        }
    }

    CBaseEntity@ pDiffy = g_EntityFuncs.FindEntityByTargetname( null, 'ddd_dumpinfo' );

    string difficulty = CustomKeyValue( pDiffy, '$s_diff' );

    if( difficulty != String::INVALID_INDEX )
    {
        difficulty += ' (' + CustomKeyValue( pDiffy, '$i_diff' ) + ')';
    }

    string m_iszHostName = config[ "DYNAMIC_HOSTNAME" ];
    m_iszHostName.Replace( "$hostname$", config[ "HOSTNAME" ] );
    m_iszHostName.Replace( "$maps$", mapname );
    m_iszHostName.Replace( "$antirush$", antirush );
    m_iszHostName.Replace( "$difficulty$", ( difficulty == String::INVALID_INDEX ? config[ "DISABLED" ] : difficulty ) );
    m_iszHostName.Replace( "$survival$", config[ ( g_SurvivalMode.MapSupportEnabled() ? "ENABLED" : "DISABLED" ) ] );

    g_EngineFuncs.ServerCommand( "hostname \"" + m_iszHostName + "\"\n" );
    g_EngineFuncs.ServerExecute();
}