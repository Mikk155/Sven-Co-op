#include "fft"
#include "json"
#include "GameFuncs"
#include "PlayerFuncs"
#include "UserMessages"

json pJson;
bool AddColor;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    pJson.load('plugins/mikk/chatroles.json');
    AddColor = !GameFuncs::IsPluginInstalled( 'ChatColors' );
}

void MapActivate()
{
    // -TODO Implement an admin command to set roles and json encoder to save them
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
    && hiden.find( PlayerFuncs::GetSteamID( pPlayer ) ) < 0
    && pJson.Instance( PlayerFuncs::GetSteamID( pPlayer ) ) == JsonValueType::ARRAY )
    {
        array<string> pData = array<string>( pJson[ PlayerFuncs::GetSteamID( pPlayer ) ] );

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
        UserMessages::PlayerSay( pPlayer, preText + string( pPlayer.pev.netname ) + ': ' + args.GetCommandString() );

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
        hidemode( PlayerFuncs::GetSteamID( g_ConCommandSystem.GetCurrentPlayer() ), atoi( args[1] ) );
    }
}