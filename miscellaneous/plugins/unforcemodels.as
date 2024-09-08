bool ForceRemove = false;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
}

void MapInit()
{
	if( !g_Map.HasForcedPlayerModels() )
	{
		IsForced = false;
	}
}

bool IsForced = false;

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	Unforce( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();

	if( args.ArgC() >= 1 && pPlayer !is null && pPlayer.IsConnected() && args[0] == '/unforcemodels' )
	{
		if( !g_Map.HasForcedPlayerModels() )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This map has No forced player models.\n" );
			return HOOK_CONTINUE;
		}
		if( ForceRemove )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Forced models have been disabled by the server.\n" );
			return HOOK_CONTINUE;
		}

		for(int i = 1; i <= g_Engine.maxClients; i++) 
		{
			CBasePlayer@ eAll = g_PlayerFuncs.FindPlayerByIndex(i);

			if( eAll !is null && eAll.IsConnected() ) 
			{
				int eidx = eAll.entindex();

				if( g_VoteMenu[eidx] is null )
				{
					@g_VoteMenu[eidx] = CTextMenu( MainCallback );
					g_VoteMenu[eidx].SetTitle( 'Un-Force Player Models ' );

					g_VoteMenu[eidx].AddItem( 'Force' );
					g_VoteMenu[eidx].AddItem( 'Un-Force' );

					g_VoteMenu[eidx].Register();
				}
				g_VoteMenu[eidx].Open( 5, 0, eAll );
			}
		}
		g_Scheduler.SetTimeout( "Results", 5.0f );
	}
	return HOOK_CONTINUE;
}


// Menus need to be defined globally when the plugin is loaded or else paging doesn't work.
// Each player needs their own menu or else paging breaks when someone else opens the menu.
// These also need to be modified directly (not via a local var reference). - Wootguy
array<CTextMenu@> g_VoteMenu = 
{
	null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null,
	null
};

int iforce, iunforce;

void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
	if( pItem !is null )
	{
		string iszVoted = string( pItem.m_szName );

		if( iszVoted == 'Force' )
		{
			++iforce;
		}
		else
		{
			++iunforce;
		}

		if( pPlayer !is null )
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, string( pPlayer.pev.netname ) + ' voted for '+iszVoted+' models.\n' );
		}
	}
}

void Unforce( CBasePlayer@ pPlayer )
{
	if( pPlayer !is null && pPlayer.IsConnected() && g_Map.HasForcedPlayerModels() )
	{
		if( ForceRemove || !IsForced )
		{
			pPlayer.SetOverriddenPlayerModel( string( pPlayer.pev.model ).Replace( 'models/', '' ).Replace( '.mdl', '' ) );
			g_Game.AlertMessage( at_console, 'Override' + string( pPlayer.pev.model ).Replace( 'models/', '' ).Replace( '.mdl', '' ) + '\n' );
		}
		else
		{
			pPlayer.ResetOverriddenPlayerModel( true, true );
			g_Game.AlertMessage( at_console, 'Reset' + '\n' );
		}
	}
}

void Results()
{
	string enable = 'enable';
	if( iunforce >= iforce )
	{
		IsForced = false;
		enable = 'disabled';
	}
	else
	{
		IsForced = true;
	}
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, 'Forced models have been '+enable+'.\n' );
	iforce = 0;
	iunforce = 0;
	for( int i = 1; i <= g_Engine.maxClients; Unforce( g_PlayerFuncs.FindPlayerByIndex( i++ ) ) );
}