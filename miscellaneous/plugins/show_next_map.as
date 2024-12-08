CScheduledFunction@ g_Think = null;

array<string> a_sMaps;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );
    g_Hooks.RegisterHook(Hooks::Game::KeyValue, @KeyValue);
    g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
}

void MapStart()
{
    if( g_Think !is null )
    {
        g_Scheduler.RemoveTimer( g_Think );
    }

    if( g_Think is null && a_sMaps.length() > 0 )
    {
        @g_Think = g_Scheduler.SetInterval( "Think", 20.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
    }
}

void Think()
{
    NetworkMessage message( MSG_ALL, NetworkMessages::NextMap );
        message.WriteString( ( a_sMaps.length() == 1 ? string( a_sMaps[0] ) : string( a_sMaps.length() ) + ' Results' ) );
    message.End();
}

HookReturnCode KeyValue( CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName )
{
    if( szClassName == 'trigger_changelevel' && pszKey == 'map' )
        a_sMaps.insertLast( pszValue );
    return HOOK_CONTINUE;
}

// Funny how many stupid things i wrote
HookReturnCode MapChange( const string& in szNextMap )
{
    a_sMaps.resize(0);
    return HOOK_CONTINUE;
}