#include '../../mikk/as_utils'

// Put in here the name of the map your server is starting at by it's +map parameter
const string m_iszServerStartMap = '_server_start';

// Add this function to your vote map plugin, make sure to ejecute it when the map is going to be changed.
/*

File@ pLatest = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter/latestmap.txt', OpenFile::APPEND );

if( pLatest !is null && pLatest.IsOpen() )
{
    pLatest.Write( m_iszYourVotedMap + '\n' );
}

*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );

    g_Hooks.RegisterHook( Hooks::ASLP::Engine::KeyValue, @KeyValue );
}

array<string> m_iszMapasSospechosos;

HookReturnCode KeyValue( CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName, META_RES& out meta_result )
{
    if( szClassName == 'trigger_changelevel' && pszKey == 'map' )
    {
        m_iszMapasSospechosos.insertLast( pszValue );
    }
    return HOOK_CONTINUE;
}

void MapStart()
{
    if( string( g_Engine.mapname ) == m_iszServerStartMap )
    {
        CargarPosiblesCulpables();
    }
    else
    {
        GuardarPosibleCulpables();
    }
}

void GuardarPosibleCulpables()
{
    File@ pLatest = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter/latestmap.txt', OpenFile::WRITE );

    if( pLatest !is null && pLatest.IsOpen() )
    {
        for( uint ui = 0; ui < m_iszMapasSospechosos.length(); ui++ )
        {
            pLatest.Write( m_iszMapasSospechosos[ui] + '\n' );
        }
    }
    m_iszMapasSospechosos.resize(0);
}

void CargarPosiblesCulpables()
{
        File@ pLatest = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter/latestmap.txt', OpenFile::READ );

        if( pLatest is null || !pLatest.IsOpen() )
            return;

        array<string> m_iszPosibleCulpables;

        while( !pLatest.EOFReached() )
        {
            string line;
            pLatest.ReadLine( line );

            if( line.Length() > 0 )
                m_iszPosibleCulpables.insertLast( line );
        }
        pLatest.Close();

        if( m_iszPosibleCulpables.length() > 0 )
        {
            File@ pCrashes = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter/MapCrashes.txt', OpenFile::APPEND );

            if( pCrashes is null || !pCrashes.IsOpen() )
                return;

            DateTime g_CrashReportTime;

            for( uint ui = 0; ui < m_iszPosibleCulpables.length(); ui++ )
            {
                pCrashes.Write( '' + m_iszPosibleCulpables[ui] + '.bsp Probablemente haya crasheado el servidor el dia ' + string( g_CrashReportTime.GetDayOfMonth() ) + ' del mes '+ string( g_CrashReportTime.GetMonth() ) + ' a las ' + string( g_CrashReportTime.GetHour() ) + ':' + string( g_CrashReportTime.GetMinutes() ) + '\n' );
            }
            pCrashes.Close();
        }
}