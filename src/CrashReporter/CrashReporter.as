// Put in here the name of the map your server is starting at by it's +map parameter
const string m_iszServerStartMap = '_server_start';

// Add this function to your vote map plugin, make sure to ejecute it when the map is going to be changed.
/*
File@ pLatest = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter_latestmap.txt', OpenFile::APPEND );
if( pLatest !is null && pLatest.IsOpen() )
{
    pLatest.Write( m_iszYourVotedMap + '\n' );
    pLatest.Close();
}
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
}

array<string> m_iszMapasSospechosos;

void MapInit(){ g_Hooks.RegisterHook( Hooks::ASLP::Engine::KeyValue, @KeyValue ); }

void MapActivate(){ g_Hooks.RemoveHook( Hooks::ASLP::Engine::KeyValue, @KeyValue ); }

void MapStart(){ if( string( g_Engine.mapname ) == m_iszServerStartMap ) { CargarPosiblesCulpables(); } else { GuardarPosibleCulpables(); } }

HookReturnCode KeyValue( CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName, META_RES& out meta_result )
    { if( szClassName == 'trigger_changelevel' && pszKey == 'map' ) { m_iszMapasSospechosos.insertLast( pszValue ); } return HOOK_CONTINUE; }

void GuardarPosibleCulpables()
{
    File@ pLatest = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter_latestmap.txt', OpenFile::WRITE );

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
    File@ pLatest = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter_latestmap.txt', OpenFile::READ );

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
        File@ pCrashes = g_FileSystem.OpenFile( 'scripts/plugins/store/CrashReporter_MapCrashes.txt', OpenFile::APPEND );

        if( pCrashes is null || !pCrashes.IsOpen() )
            return;

        DateTime g_CrashReportTime;

        for( uint ui = 0; ui < m_iszPosibleCulpables.length(); ui++ )
        {
            pCrashes.Write( '' + m_iszPosibleCulpables[ui] + '.bsp probably crashed the server the day ' + string( g_CrashReportTime.GetDayOfMonth() ) + ' del mes '+ string( g_CrashReportTime.GetMonth() ) + ' at ' + string( g_CrashReportTime.GetHour() ) + ':' + string( g_CrashReportTime.GetMinutes() ) + '\n' );
        }
        pCrashes.Close();
    }
}