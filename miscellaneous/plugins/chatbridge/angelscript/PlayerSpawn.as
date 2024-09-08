namespace PlayerSpawn
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_RESPAWN:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn::PlayerSpawn );
        }
    }

    HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        dictionary pReplacement;
        pReplacement["name"] = string( pPlayer.pev.netname );
        ParseMSG( ParseLanguage( pJson, "MSG_PLAYER_RESPAWN", pReplacement ) );

        return HOOK_CONTINUE;
    }
}