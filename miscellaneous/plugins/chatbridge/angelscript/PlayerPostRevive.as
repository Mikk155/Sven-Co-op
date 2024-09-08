namespace PlayerPostRevive
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_REVIVED:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::ASLP::Player::PlayerPostRevive, @PlayerPostRevive::PlayerPostRevive );
        }
    }

    HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        dictionary pReplacement;
        pReplacement["name"] = string( pPlayer.pev.netname );
        ParseMSG( ParseLanguage( pJson, "MSG_PLAYER_REVIVED", pReplacement ) );

        return HOOK_CONTINUE;
    }
}