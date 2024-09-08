namespace ClientPutInServer
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_CONNECT:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer::ClientPutInServer );
        }
    }

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            dictionary pReplacement;
            pReplacement["name"] = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + " " + string( pPlayer.pev.netname );
            ParseMSG( ParseLanguage( pJson, "JOINED", pReplacement ) );
        }
        return HOOK_CONTINUE;
    }
}