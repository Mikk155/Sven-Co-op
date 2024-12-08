#include '../../maps/mikk/as_utils'

string m_szPath = 'scripts/plugins/mikk/MSG/';

int seconds;
int minutes;
int hours;
int days;
int restarts;
string map;
dictionary msg;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    seconds = 0;
    minutes = 0;
    hours = 0;

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    m_FileSystem.GetKeyAndValue( m_szPath + 'timer.txt', msg, true );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    if( pParams.GetArguments()[0] == '/time' )
    {
        m_Language.PrintMessage
        (
            pParams.GetPlayer(), msg, ML_CHAT, false,
            {
                { '$days$' , string( days ) },
                { '$hours$' , string( hours ) },
                { '$minutes$' , string( minutes ) },
                { '$seconds$' , string( seconds ) },
                { '$restarts$' , string( restarts ) }
            }
        );
    }
    return HOOK_CONTINUE;
}

// What are you looking at, pavobestia?
HookReturnCode MapChange( const string& in szNextMap )
{
    restarts++;
    return HOOK_CONTINUE;
}

void MapInit()
{
    if( map != string( g_Engine.mapname ) )
    {
        map = string( g_Engine.mapname );
        restarts = 0;
    }
    if( g_Think !is null )
    {
        g_Scheduler.RemoveTimer( g_Think );
    }

    @g_Think = g_Scheduler.SetInterval( "Think", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
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
        m_Language.PrintMessage
        (
            null, msg, ML_CHAT, true,
            {
                { '$days$' , string( days ) },
                { '$hours$' , string( hours ) },
                { '$minutes$' , string( minutes ) },
                { '$seconds$' , string( seconds ) },
                { '$restarts$' , string( restarts ) }
            }
        );
    }
}