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

    string m_iszHostName = config[ "DYNAMIC_HOSTNAME" ];
    m_iszHostName.Replace( "$hostname$", config[ "HOSTNAME" ] );
    m_iszHostName.Replace( "$maps$", mapname );
    m_iszHostName.Replace( "$antirush$", antirush );
    m_iszHostName.Replace( "$survival$", config[ ( g_SurvivalMode.MapSupportEnabled() ? "ENABLED" : "DISABLED" ) ] );

    g_EngineFuncs.ServerCommand( "hostname \"" + m_iszHostName + "\"\n" );
    g_EngineFuncs.ServerExecute();
}