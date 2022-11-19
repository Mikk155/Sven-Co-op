/*
INSTALL:

    "plugin"
    {
        "name" "AdminRole"
        "script" "mikk/AdminRole"
    }
*/

#include "../../maps/mikk/utils"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk https://github.com/Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8 \n" );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();

	if( g_PlayerFuncs.AdminLevel( pPlayer ) == ADMIN_NO )
		return HOOK_CONTINUE;

    const CCommand@ args = pParams.GetArguments();
    string FullSentence = pParams.GetCommand();

    if( args.Arg(0) == "/hideadmin" )
    {
        if( UTILS::GetCKV( pPlayer, "$i_adminlevel" ) == 0 )
            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_adminlevel", 1 );
        else
            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_adminlevel", 0 );
		pParams.ShouldHide = true;
		return HOOK_CONTINUE;
    }
	
	if( UTILS::GetCKV( pPlayer, "$i_adminlevel" ) == 1 )
		return HOOK_CONTINUE;

	pParams.ShouldHide = true;

	if( g_PlayerFuncs.AdminLevel( pPlayer ) == ADMIN_OWNER )
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[OWNER] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
	else
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[ADMIN] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
	return HOOK_CONTINUE;
}