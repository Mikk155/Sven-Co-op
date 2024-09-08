namespace ClientSay
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_TALK:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay::ClientSay );
        }
    }

    HookReturnCode ClientSay( SayParameters@ pParams )
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        const CCommand@ args = pParams.GetArguments();

        if( pPlayer is null || args.ArgC() <= 0 || pParams.ShouldHide )
            return HOOK_CONTINUE;

        ParseMSG( "- " + GetEmote( pPlayer ) + ( pPlayer.IsAlive() ? "" : ParseLanguage( pJson, "MSG_PLAYER_DEAD" ) + " " ) + string( pPlayer.pev.netname ) + ": " + args.GetCommandString() );

        return HOOK_CONTINUE;
    }
}