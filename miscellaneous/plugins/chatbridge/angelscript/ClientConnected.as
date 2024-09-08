namespace ClientConnected
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_COUNTRY:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::Player::ClientConnected, @ClientConnected::ClientConnected );
        }
    }

    HookReturnCode ClientConnected( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason )
    {
        if( pEntity is null || szIPAddress.IsEmpty() || !g_EngineFuncs.IsDedicatedServer() )
            return HOOK_CONTINUE;

        dictionary pReplacement;
        pReplacement["name"] = szPlayerName;
        ParseMSG( "$ " + szIPAddress + " " + ParseLanguage( pJson, "MSG_PLAYER_CONNECTING", pReplacement ) );

        return HOOK_CONTINUE;
    }
}