// interval of time to schedule messages
const float gpRepeatInterval = 500;

// message to display where %1 is the days left and %2 the server ip
const string gptemplateMessage = "This server will terminate in %1 days. We are moving to %2\n";

// List of server host names and their respective new ip.
dictionary gpServers = {
    { "Misfire's Sven Co-Op 5.26 | very XP #4 [EU] BUYMENU", "82.25.58.60:27016" },
    { "Misfire's Sven Co-Op 5.26 | non-XP [US] BUYMENU", "82.25.58.60:27017" },
    { "Misfire's Sven Co-op 5.26 | such Chill #2 [EU]", "82.25.58.60:27018" },
    { "Misfire's Sven Co-Op 5.26 | non-XP #2 [EU] BUYMENU", "82.25.58.60:27018" },
    { "Misfire's Sven Co-Op 5.26 | very XP #3 [EU] BUYMENU", "82.25.58.60:27015" },
    { "Misfire's Sven Co-Op 5.26 | very XP #2 [US] BUYMENU", "162.141.78.131:27016" },
    { "Misfire's Sven Co-Op 5.26 | very XP [US] BUYMENU", "162.141.78.131:27015" },
    { "Misfire's Sven Co-op 5.26 | such Chill [US]", "162.141.78.131:27019" },
    { "Misfire's Sven Co-Op 5.26 | PVP/DM ONLY", "162.141.78.131:27017" }
};

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op/" );
    MapActivate();
}

CScheduledFunction@ gpThink = null;
int remainingDays;
string serverIp;
ClientPutInServerHook@ gpHook = ClientPutInServerHook( function( CBasePlayer@ player )
{
    if( player !is null )
    {
        g_Scheduler.SetTimeout( "NoticeIndividual", 5.0f, player.entindex() );
    }
    return HOOK_CONTINUE;
} );

void Notice()
{
    if( g_PlayerFuncs.GetNumPlayers() <= 0 )
        return;

    string buffer;
    snprintf( buffer, gptemplateMessage, remainingDays, serverIp );
    g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, buffer );
}

void NoticeIndividual( int index )
{
    auto player = g_PlayerFuncs.FindPlayerByIndex(index);

    if( player !is null )
    {
        string buffer;
        snprintf( buffer, gptemplateMessage, remainingDays, serverIp );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTTALK, buffer );
    }
}

void MapActivate()
{
    if( gpThink !is null )
    {
        g_Scheduler.RemoveTimer( gpThink );
        @gpThink= null;
    }

    g_Hooks.RemoveHook( Hooks::Player::ClientPutInServer, @gpHook );

    DateTime now = DateTime();

    if( now.GetMonth() != 8 )
        return;

    int todayDay = now.GetDayOfMonth();

    if( todayDay > 24 )
        return;

    remainingDays = 24 - todayDay;

    string hostname = g_EngineFuncs.CVarGetString( "hostname" );

    if( gpServers.get( hostname, serverIp ) && !serverIp.IsEmpty() )
    {
        Notice();
        g_EngineFuncs.ServerPrint( "Start printing migration notice:\n" );
        g_EngineFuncs.ServerPrint( serverIp );
        @gpThink = g_Scheduler.SetInterval( "Notice", gpRepeatInterval );

        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @gpHook );
    }
}
