//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../mikk/shared"

json pJson;
bool AddColor;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    pJson.load('plugins/mikk/chatroles.json');
    AddColor = !Mikk.IsPluginInstalled( 'ChatColors', false );
}

void MapInit()
{
    pJson.reload('plugins/mikk/chatroles.json');
}

// keeping the scoreboard color would be neat too, but then you can't see hp/armor
void revert_scoreboard_color(EHandle h_plr) {
	CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
	if (plr is null or !plr.IsConnected()) {
		return;
	}

	plr.SendScoreInfo();
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();

    if( pPlayer !is null
    && !pParams.ShouldHide
    && args.GetCommandString() != ''
    && hiden.find( Mikk.PlayerFuncs.GetSteamID( pPlayer ) ) < 0
    && pJson.Instance( Mikk.PlayerFuncs.GetSteamID( pPlayer ) ) == JsonValueType::ARRAY )
    {
        array<string> pData = array<string>( pJson[ Mikk.PlayerFuncs.GetSteamID( pPlayer ) ] );

        int oldClassify;

        if( AddColor && pData.length() == 2 )
        {
            oldClassify = pPlayer.Classify();

            if( oldClassify < 16 || oldClassify > 19 )
            {
                if( pData[1] == 'red' )
                {
                    pPlayer.SetClassification( 17 );
                }
                else if( pData[1] == 'green' )
                {
                    pPlayer.SetClassification( 19 );
                }
                else if( pData[1] == 'blue' )
                {
                    pPlayer.SetClassification( 16 );
                }
                else if( pData[1] == 'yellow' )
                {
                    pPlayer.SetClassification( 18 );
                }
                pPlayer.SendScoreInfo();
            }
        }

        string preText = ( pData[0].IsEmpty() ? '' : '[' + pData[0] + '] ' );
        Mikk.PlayerFuncs.PlayerSay( pPlayer, preText + string( pPlayer.pev.netname ) + ': ' + args.GetCommandString() );

        if( AddColor )
        {
            pPlayer.SetClassification(oldClassify);

            g_Scheduler.SetTimeout("revert_scoreboard_color", 0.5f, EHandle( pPlayer ));
        }

        pParams.ShouldHide = true;
    }
	return HOOK_CONTINUE;
}

CClientCommand _cmd("hiderole", "hide chat role", @consoleCmd );

array<string> hiden;

void hidemode( string id, int arg )
{
    if( arg == 0 )
    {
        if( hiden.find(id) >= 0 )
        {
            hiden.removeAt( hiden.find( id ) );
            g_Game.AlertMessage( at_console, "Not hidden\n" );
        }
    }
    else
    {
        if( hiden.find(id) < 0 )
        {
            hiden.insertLast( id );
        }
    }
}

void consoleCmd( const CCommand@ args )
{
    if( g_ConCommandSystem.GetCurrentPlayer() !is null )
    {
        hidemode( Mikk.PlayerFuncs.GetSteamID( g_ConCommandSystem.GetCurrentPlayer() ), atoi( args[1] ) );
    }
}