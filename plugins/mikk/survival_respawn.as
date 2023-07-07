void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

dictionary TrackPlayers;

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null && !TrackPlayers.exists( string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ) )
    {
        pPlayer.Respawn();
        TrackPlayers[ string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ] = 'Joined';
    }
    return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
    TrackPlayers.deleteAll();
    return HOOK_CONTINUE;
}