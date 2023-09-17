MDebugger m_Debug;

enum DEBUG_LEVEL
{
    // For final relase
    DEBUG_LEVEL_NONE = 0,

    // Show error messages only
    DEBUG_LEVEL_IMPORTANT = 1,

    // Shows almost of the messages
    DEBUG_LEVEL_ALMOST = 2,

    // Show debugs of Thinking entities (May flood your console)
    DEBUG_LEVEL_THINK = 3,
}

final class MDebugger
{
    int CurrentLevel = DEBUG_LEVEL_THINK;

    void SetDebugLevel( const int DebugLevel = DEBUG_LEVEL_NONE )
    {
        CurrentLevel = DebugLevel;
    }

    void Client( CBasePlayer@ pPlayer, string m_iszDebug, const int DebugLevel = DEBUG_LEVEL_IMPORTANT )
    {
        if( CurrentLevel != DEBUG_LEVEL_NONE && DebugLevel != DEBUG_LEVEL_NONE && DebugLevel <= DebugLevel )
        {
            if( pPlayer is null ) { g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, '[AS] ' + m_iszDebug + "\n" ); }
            else { g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, '[AS] ' + m_iszDebug + "\n" ); }
        }
    }

    void Server( string m_iszDebug, const int DebugLevel = DEBUG_LEVEL_IMPORTANT )
    {
        if( CurrentLevel != DEBUG_LEVEL_NONE && DebugLevel != DEBUG_LEVEL_NONE && DebugLevel <= DebugLevel )
            g_Game.AlertMessage( at_console, '[AS] ' + m_iszDebug + '\n' );
    }
}