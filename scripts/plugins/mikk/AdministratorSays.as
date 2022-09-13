void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();

	if( g_PlayerFuncs.AdminLevel( pPlayer ) == ADMIN_NO )
		return HOOK_CONTINUE;

    const CCommand@ args = pParams.GetArguments();
    string FullSentence = pParams.GetCommand();

	pParams.ShouldHide = true;
	
	if( g_PlayerFuncs.AdminLevel( pPlayer ) == ADMIN_OWNER )
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[OWNER] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
	else
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[ADMIN] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
	
	return HOOK_CONTINUE;
}