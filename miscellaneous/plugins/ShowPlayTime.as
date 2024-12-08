#include '../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    Mikk.Json.ReadJsonFile( "plugins/ShowPlayTime", pJson );

    seconds = minutes = hours = days = restarts = 0;

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

JSon pJson;
int seconds;
int minutes;
int hours;
int days;
int restarts;
string map;

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( pPlayer !is null && pParams.GetArguments()[0] == '/time' )
    {
        Mikk.Language.Print( pPlayer, pJson, "MESSAGE", CHAT, pReplacement() );
    }
    return HOOK_CONTINUE;
}

// when a new update that doesn't randomly crash servers?
HookReturnCode MapChange( const string& in szNextMap )
{
    restarts++;
    return HOOK_CONTINUE;
}

dictionary pReplacement()
{
    return {
        { 'days' , string( days ) },
        { 'hours' , string( hours ) },
        { 'minutes' , string( minutes ) },
        { 'seconds' , string( seconds ) },
        { 'restarts' , string( restarts ) },
        { '(s)' , ( restarts > 1 ? "s" : "" ) }
    };
}

void MapInit()
{
    if( map.IsEmpty() ) map = string( g_Engine.mapname );
    if( map != string( g_Engine.mapname ) )
    {
        map = string( g_Engine.mapname );
        restarts = 0;
    }

    Mikk.Utility.UpdateTimer( g_Think, "Think", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

CScheduledFunction@ g_Think = null;

void Think()
{
    seconds++;
    if( seconds > 59 )
    {
        minutes++;
        seconds = 0;
    }
    if( minutes > 59 )
    {
        hours++;
        minutes = 0;
    }
    if( hours > 23 )
    {
        days++;
        hours = 0;
    }

    if( string( minutes ).EndsWith( '0' ) && seconds == 1 )
    {
        Mikk.Language.PrintAll( pJson, "MESSAGE", CHAT, pReplacement() );
    }
}