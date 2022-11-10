/*
    INSTALL:

    "plugin"
    {
        "name" "NoFreeRoamingObservers"
        "script" "mikk/NoFreeRoamingObservers"
    }
*/
void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk: https://github.com/Mikk155" );
    g_Module.ScriptInfo.SetContactInfo("Discord: https://discord.gg/VsNnE3A7j8");
}

void MapInit()
{
    g_Hooks.RegisterHook( Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver );
}

HookReturnCode PlayerEnteredObserver( CBasePlayer@ pPlayer )
{
	if( pPlayer is null || !pPlayer.GetObserver().IsObserver() )
    {
		return HOOK_CONTINUE;
    }

    pPlayer.GetObserver().SetMode( OBS_CHASE_FREE );
    pPlayer.GetObserver().SetObserverModeControlEnabled( false );

    int i = int( pPlayer.GetCustomKeyvalues().GetKeyvalue( "$f_lenguage" ).GetFloat() );

    if( i == 1 )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AS] El modo de observador 'Free Roaming' esta bloqueado.\n" );
    }
    else
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AS] The observer mode 'Free Roaming' is blocked.\n" );
    }

    return HOOK_CONTINUE;
}