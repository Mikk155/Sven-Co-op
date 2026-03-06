const float MESSAGE_DISPLAY_COOLDOWN = 60;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

    MapActivate();
}

int mapRestarts = 0;

DateTime date;

HookReturnCode MapChange( const string& in nextmap )
{
    if( string( g_Engine.mapname ) == nextmap )
    {
        mapRestarts++;
    }
    else
    {
        date = DateTime();
    }

    return HOOK_CONTINUE;
}

void ShowTime()
{
    TimeDifference difference = DateTime() - date;
    difference.MakeAbsolute();

    int days = difference.GetDays();
    int hours = difference.GetHours() % 24;
    int minutes = difference.GetMinutes() % 60;
    int seconds = difference.GetSeconds() % 60;

    string time = "This map has been running for ";

    if( days > 0 ) { snprintf( time, "%1%2 day%3 ", time, days, ( days > 1 ? "s" : "" ) ); }
    if( hours > 0 ) { snprintf( time, "%1%2 hour%3 ", time, hours, ( hours > 1 ? "s" : "" ) ); }
    if( minutes > 0 ) { snprintf( time, "%1%2 minute%3 ", time, minutes, ( minutes > 1 ? "s" : "" ) ); }
    if( seconds > 0 ) { snprintf( time, "%1%2 second%3 ", time, seconds, ( seconds > 1 ? "s" : "" ) ); }

    if( mapRestarts > 0 ) { snprintf( time, "%1during %2 map restart%3", time, mapRestarts, ( mapRestarts > 1 ? "s" : "" ) ); }

    g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, time + ".\n" );
}

CScheduledFunction@ fnThink;

void MapActivate()
{
    if( fnThink !is null )
    {
        g_Scheduler.RemoveTimer( fnThink );
        @fnThink = null;
    }

    @fnThink = g_Scheduler.SetInterval( "ShowTime", MESSAGE_DISPLAY_COOLDOWN, g_Scheduler.REPEAT_INFINITE_TIMES );
}

float NextClientDisplay;

HookReturnCode ClientSay( SayParameters@ params )
{
    if( NextClientDisplay > g_Engine.time )
        return HOOK_CONTINUE;

    if( params.GetArguments()[0] != '/time' )
        return HOOK_CONTINUE;

    ShowTime();

    NextClientDisplay = g_Engine.time + 10.0f;

    return HOOK_CONTINUE;
}
