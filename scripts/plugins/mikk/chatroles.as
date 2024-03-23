#include "../../mikk/shared"

json pJson;
bool AddColor;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    pJson.load('plugins/mikk/chatroles.json');
    AddColor = !Mikk.Utility.IsPluginInstalled( 'ChatColors', false );
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
    && pJson[ Mikk.PlayerFuncs.GetSteamID( pPlayer ) ] == 'json@' )
    {
        json pData = pJson[ Mikk.PlayerFuncs.GetSteamID( pPlayer ), {} ];

        int oldClassify;

        if( AddColor )
        {
            oldClassify = pPlayer.Classify();

            if( oldClassify < 16 || oldClassify > 19 )
            {
                if( pData[ 'color' ] == 'red' )
                {
                    pPlayer.SetClassification( 17 );
                }
                else if( pData[ 'color' ] == 'green' )
                {
                    pPlayer.SetClassification( 19 );
                }
                else if( pData[ 'color' ] == 'blue' )
                {
                    pPlayer.SetClassification( 16 );
                }
                else if( pData[ 'color' ] == 'yellow' )
                {
                    pPlayer.SetClassification( 18 );
                }
                pPlayer.SendScoreInfo();
            }
        }

        Mikk.PlayerFuncs.PlayerSay( pPlayer, '[' + pData[ 'role' ] + '] ' + string( pPlayer.pev.netname ) + ': ' + args.GetCommandString() );

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