namespace ClientDisconnect
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_DISCONNECT:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect::ClientDisconnect );
        }
    }

    HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        dictionary pReplacement;
        pReplacement["name"] = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + " " + string( pPlayer.pev.netname );
        ParseMSG( ParseLanguage( pJson, "MSG_PLAYER_LEAVE", pReplacement ) );

        return HOOK_CONTINUE;
    }
}