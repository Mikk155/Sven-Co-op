const string iszConfigFile = 'scripts/plugins/mikk/chatcolors.txt';

array<string> AllowedClients;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "w00tguy" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/wootguy" );

	AllowedClients.resize( 0 );

    File@ pFile = g_FileSystem.OpenFile( iszConfigFile, OpenFile::READ );

    if( pFile is null || !pFile.IsOpen() )
    {
        g_Game.AlertMessage( at_console, 'Can NOT open "' + iszConfigFile + '" Exiting...\n' );
        return;
    }

	int latestcolor = -1;
	string line;

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );
        line.Trim();

        if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
		{
            continue;
		}

		if( line[0] == '#' )
		{
			latestcolor = ( line == '#red' ? 17 : line == '#green' ? 19 : line == '#blue' ? 16 : line == '#yellow' ? 18 : -1 );
            continue;
		}

		AllowedClients.insertLast( line + ' ' + string( latestcolor ) );
    }
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( pPlayer !is null )
	{
		PlayerState@ state = getPlayerState( pPlayer );

		int ic = pPlayer.Classify();

		if( ic >= 16 && ic <= 19 )
		{
			state.color = ic;
		}

		for( uint i = 0; i < AllowedClients.length(); i++ )
		{
			array<string> iszSplit = {'',''};

        	iszSplit = AllowedClients[i].Split( ' ' );

			if( string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) == iszSplit[0] )
			{
				state.color = atoi( iszSplit[1] );
			}
		}
	}
	return HOOK_CONTINUE;
}

dictionary g_player_states;

class PlayerState
{
	int color = -1; // classify value
}

// Will create a new state if the requested one does not exit
PlayerState@ getPlayerState( CBasePlayer@ pPlayer )
{
	if( pPlayer !is null && pPlayer.IsConnected() )
	{
		string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( steamId == 'STEAM_ID_LAN' or steamId == 'BOT')
		{
			steamId = pPlayer.pev.netname;
		}
		
		if( !g_player_states.exists(steamId) )
		{
			PlayerState state;
			g_player_states[steamId] = state;
		}
		return cast<PlayerState@>( g_player_states[steamId] );
	}
	return null;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();

	PlayerState@ state = getPlayerState( pPlayer );

	if( pParams.GetArguments().ArgC() > 0 && state.color > 0 )
	{
		int oldClassify = pPlayer.Classify();
		pPlayer.SetClassification( state.color );
		pPlayer.SendScoreInfo();
		pPlayer.SetClassification(oldClassify);
		g_Scheduler.SetTimeout("revert_scoreboard_color", 0.5f, EHandle( pPlayer ));
	}

	return HOOK_CONTINUE;
}

// keeping the scoreboard color would be neat too, but then you can't see hp/armor
void revert_scoreboard_color(EHandle h_plr)
{
	CBasePlayer@ plr = cast<CBasePlayer@>( h_plr.GetEntity() );

	if( plr is null or !plr.IsConnected() )
	{
		return;
	}
	plr.SendScoreInfo();
}