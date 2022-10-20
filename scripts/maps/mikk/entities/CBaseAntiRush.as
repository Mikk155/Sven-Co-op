/*
Mikk
https://github.com/Mikk155

CubeMath
https://github.com/CubeMath

Gaftherman
https://github.com/Gaftherman

INSTALL:

#include "mikk/entities/CBaseAntiRush"

// Original Script by Cubemath
// Modified a bit by mikk & gaftherman
// First argument enables or disables votes.
// Second argument is the percentage required for vote activate antirush
// Third argument is the time in seconds that a vote will think
// Fourth argument is the default percentage of players required to be inside to trigger (If mapper don't force)
// Five argument define if using debug mode. set to false for release

void MapInit()
{
	RegisterCBaseAntiRush( true, 50, 15, 0.66, true );
}

*/

bool IsDisabledByVoted = false;
float flVotePercentage, flVoteTime, flPercentage;
bool bldebug = false;

void RegisterCBaseAntiRush( bool VoteInit = true, float PercentInit = 40, float VoteTimeInit = 15, float DefPercent = 0.66, bool Debug = true ) 
{
	// Register the entity
	g_CustomEntityFuncs.RegisterCustomEntity( "CBaseAntiRushMultiPlayer", "trigger_once_mp" );

	if( VoteInit )
	{
		g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
		flVotePercentage = PercentInit;
		flVoteTime = VoteTimeInit;
	}

	flPercentage = DefPercent;

	bldebug = Debug;

	// Load entities file after registering the entity
	const string EntitiesLoadFile = "mikk/antirush/" + string( g_Engine.mapname ) + ".txt";
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ pArguments = pParams.GetArguments();

    if ( pArguments.ArgC() >= 1 )
    {
        if( pArguments[0] == "/antirush" )
        {
			if( g_PlayerFuncs.GetNumPlayers() == 1 )
			{
				if( IsDisabledByVoted )
				{
					ANTIRUSHMLAN::MSG( 2, null, 0, 0 );
					IsDisabledByVoted = false;
				}
				else
				{
					ANTIRUSHMLAN::MSG( 1, null, 0, 0 );
					IsDisabledByVoted = true;
				}
			}
			else
			{
				ExecVote();
				ANTIRUSHMLAN::MSG( 0, pPlayer, 0, 0 );
			}
		}
        else if( pArguments[0] == "antirush" )
        {
			if( IsDisabledByVoted )
			{
				ANTIRUSHMLAN::MSG( 7, pPlayer, 0, 0 );
			}
			else
			{
				ANTIRUSHMLAN::MSG( 8, pPlayer, 0, 0 );
			}
		}
	}
    return HOOK_CONTINUE;
}

void ExecVote()
{
	Vote vote( "Anti-Rush", "Want to toggle anti-rush state?", flVoteTime, flVotePercentage );
	vote.SetYesText( "Enable");
	vote.SetNoText( "Disable" );
	vote.SetVoteBlockedCallback( @VoteBlockedTryLater );
	vote.SetVoteEndCallback( @VoteEndCallBack );
	
	vote.Start();
}

//Try again later
void VoteBlockedTryLater( Vote@ pVote, float flTime )
{
	g_Scheduler.SetTimeout( "ExecVote", flTime );
}

void VoteEndCallBack( Vote@ pVote, bool bResult, int iVoters )
{
	if ( bResult )
	{
		ANTIRUSHMLAN::MSG( 2, null, 0, 0 );
		IsDisabledByVoted = false;
	}
	else
	{
		ANTIRUSHMLAN::MSG( 1, null, 0, 0 );
		IsDisabledByVoted = true;
	}
}

#include "utils"

enum trigger_once_flag
{
    SF_AR_IS_OFF = 1 << 0,
	SF_AR_NOTEXT = 1 << 1,
	SF_AR_NOSOUN = 1 << 2,
	SF_AR_USEVEC = 1 << 3
}

class CBaseAntiRushMultiPlayer : ScriptBaseEntity
{
	private float m_flPercentage = flPercentage;
	private string killtarget	= "";

	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
		if( szKey == "percent" )
		{
			m_flPercentage = atof( szValue );
			return true;
		} 
		else if( szKey == "minhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		} 
		else if( szKey == "maxhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else if( szKey == "killtarget" )
		{
            killtarget = szValue;
			return true;
		}
		else 
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Spawn() 
	{
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;

		if( bldebug )
		{
			self.pev.renderamt = 255;
			self.pev.rendercolor = Vector( 255, 0, 0 );
			self.pev.rendermode = 1;
		}
		else
		{
			self.pev.effects |= EF_NODRAW;
		}

		self.pev.dmg = 9;

		UTILS::SetSize( self );

		if( self.pev.SpawnFlagBitSet( SF_AR_USEVEC ) || self.IsBSPModel() )
		{
			g_EntityFuncs.SetOrigin( self, self.pev.origin );
		}
		
		if( !string( self.pev.netname ).IsEmpty() )
		{
			CBaseEntity@ pLocker = null;

			while((@pLocker = g_EntityFuncs.FindEntityByClassname(pLocker, "*")) !is null)
			{
				if( string( self.pev.netname ) == string( pLocker.pev.model ) )
				{
					if( pLocker.GetCustomKeyvalues().HasKeyvalue( "$i_ignore" ) )
						continue;

					g_EntityFuncs.Remove( pLocker );
				}
			}
		}

		CBaseEntity@ pEffects = g_EntityFuncs.FindEntityByTargetname( pEffects, string( self.pev.target ) + "_FX" );

		if( pEffects !is null )
		{
			dictionary myFXs;
			myFXs ["targetname"] = "FX_" + string( self.pev.target );
			myFXs ["spawnflags"] = "64";
			myFXs ["rendermode"] = "5";
			myFXs ["renderamt"] = "0";
			myFXs ["target"] =  string( self.pev.target ) + "_FX";
			g_EntityFuncs.CreateEntity( "env_render_individual", myFXs, true );
		}

		if( string( self.pev.message ).IsEmpty() )
		{
			self.pev.message = "buttons/bell1";
		}

		SetThink( ThinkFunction( this.TriggerThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;

        BaseClass.Spawn();
	}

    void UpdateOnRemove()
    {
		do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) );
		while( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) !is null );

        BaseClass.UpdateOnRemove();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
		if( self.pev.health > 0 )
		{
			self.pev.health -= 1;
			return;
		}
	}
	
	void TriggerThink() 
	{
		if( !string( self.pev.noise ).IsEmpty() )
		{
			CBaseEntity@ pLevelChange = null;

			while((@pLevelChange = g_EntityFuncs.FindEntityByClassname(pLevelChange, "trigger_changelevel")) !is null)
			{
				if( string( self.pev.noise ) == string( pLevelChange.pev.model ) )
				{
					if( pLevelChange.pev.spawnflags != 2 )
					{
						g_EntityFuncs.DispatchKeyValue( edict_t@ pLevelChange, "spawnflags", "2" );
					}
					for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
					{
						CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

						if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
							continue;

						if( UTILS::InsideZone( pPlayer, pLevelChange ) )
						{
							// logica
						}
				}
			}
			self.pev.nextthink = g_Engine.time + 0.1f;
			return;
		}

		float TotalPlayers = 0, PlayersTrigger = 0, CurrentPercentage = 0;

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			if( UTILS::InsideZone( pPlayer, self ) && self.pev.health <= 0 )
				PlayersTrigger = PlayersTrigger + 1.0f;

			TotalPlayers = TotalPlayers + 1.0f;
		}

		if( TotalPlayers > 0) 
		{
			CurrentPercentage = PlayersTrigger / TotalPlayers + 0.00001f;

			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;

				if( UTILS::InsideZone( pPlayer, self ) )
				{
					if( IsDisabledByVoted )
					{
						FireAfterConditions();
					}

					if( !self.pev.SpawnFlagBitSet( SF_AR_NOTEXT ))
					{

						if( self.pev.health > 0 )
						{
							ANTIRUSHMLAN::MSG( 5, pPlayer, self.pev.health, 0 );
						}
						else if( CurrentPercentage >= m_flPercentage && self.pev.frags >= 0 ) 
						{
							ANTIRUSHMLAN::MSG( 6, pPlayer, self.pev.frags, self.pev.dmg );
						}
						else if( CurrentPercentage <= m_flPercentage && self.pev.health <= 0 )
						{
							ANTIRUSHMLAN::MSG( 4, pPlayer, m_flPercentage, CurrentPercentage );
						}
					}
					g_EntityFuncs.FireTargets( "FX_" + self.pev.target, pPlayer, pPlayer, USE_OFF );
				}
				else
				{
					g_EntityFuncs.FireTargets( "FX_" + self.pev.target, pPlayer, pPlayer, USE_ON );
				}
			}
		}

		if( CurrentPercentage >= m_flPercentage ) 
		{
			if( self.pev.frags > 0 )
			{
				self.pev.dmg = self.pev.dmg - 1;

				if( self.pev.dmg == 0 )
				{
					self.pev.frags = self.pev.frags - 1;
					self.pev.dmg = 9;
				}
			}
			else
			{
				FireAfterConditions();
			}
		}
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	void FireAfterConditions()
	{
		if( !self.pev.SpawnFlagBitSet( SF_AR_NOSOUN ) )
		{
			NetworkMessage msg( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
				msg.WriteString( "spk " + self.pev.message );
			msg.End();
		}

		if( killtarget != "" && killtarget != self.GetTargetname() )
		{
			do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) );
			while( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) !is null );
		}

        UTILS::TriggerMode( self.pev.target, self );

		UpdateOnRemove();

		g_EntityFuncs.Remove( self );
	}
}

namespace ANTIRUSHMLAN
{
	void MSG( int mode, CBasePlayer@ pPlayer, float flOne, float flTwo )
	{
		HUDTextParams thp;
		thp.x = -1;
		thp.y = 0.95;
		thp.effect = 0;
		thp.r1 = 255;
		thp.g1 = 0;
		thp.b1 = 0;
		thp.a1 = 0;
		thp.r2 = 255;
		thp.g2 = 0;
		thp.b2 = 0;
		thp.a2 = 0;
		thp.fadeinTime = 0;
		thp.fadeoutTime = 0.75;
		thp.holdTime = 1;
		thp.fxTime = 0;
		thp.channel = 3;

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ aPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( aPlayer is null || !aPlayer.IsConnected() )
				continue;

			int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

			if(iLanguage == 1 )	// Spanish
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacion iniciada por " + pPlayer.pev.netname + "\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacion para deshabilitar Anti-Rush aprobada." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacion para habilitar Anti-Rush aprobada." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] La votacion ha sido deshabilitada en este servidor." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% De jugadores necesario para continuar. Actual: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Elimina los " + flOne + " enemigos restantes para continuar.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Cuenta-regresiva: "+int(flOne)+"."+int(flTwo)+"0" );
			}
			else if(iLanguage == 2 )	// portuguese
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacao iniciada por " + pPlayer.pev.netname + "\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote para desativar o Anti-Rush aprovado." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote para ativar o Anti-Rush aprovado." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] A votacao foi desabilitada neste servidor." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% De jogadores necessarios para continuar. Atual: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Mate " + flOne + " inimigos restantes para continuar.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Contagem-regressiva: "+int(flOne)+"."+int(flTwo)+"0" );
			}
			else if(iLanguage == 3 )	// german
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Abstimmung gestartet von " + pPlayer.pev.netname + "\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Abstimmung zum Deaktivieren von Anti-Rush bestanden." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Abstimmung zum Aktivieren von Anti-Rush bestanden." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Die Abstimmung wurde auf diesem Server deaktiviert." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% Von Spielern, die benotigt werden, um fortzufahren. Aktuell: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Tote die verbleibenden " + flOne + " Feinde, um voranzukommen.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Countdown: "+int(flOne)+"."+int(flTwo)+"0" );
			}
			else if(iLanguage == 4 )	// french
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote commence par " + pPlayer.pev.netname + "\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votez pour desactiver l'Anti-Rush passe." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votez pour activer l'Anti-Rush passe." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Le vote a ete desactive sur ce serveur." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% Des joueurs necessaires pour continuer. Courant: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Tuez les " + flOne + " ennemis restants pour progresser.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Compte a rebours: "+int(flOne)+"."+int(flTwo)+"0" );
			}
			else if(iLanguage == 5 )	// italian
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votazione iniziata da " + pPlayer.pev.netname + "\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Voto per disabilitare Anti-Rush superato." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vota per abilitare Anti-Rush superato." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Il voto e stato disabilitato su questo server." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% Dei giocatori necessari per continuare. Attuale: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Uccidi i restanti " + flOne + " nemici per progredire.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Conto alla rovescia: "+int(flOne)+"."+int(flTwo)+"0" );
			}
			else if(iLanguage == 6 )	// esperanto
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdono komencita de " + pPlayer.pev.netname + "\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdoni por malebligi Kontrau-Rush pasis." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdoni por ebligi Anti-Rush pasis." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdono estis malsaltita en ci tiu servilo." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% De ludantoj bezonis daurigi. Nuna: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Mortigu " + flOne + " ceterajn malamikojn por progreso.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Retronombrado: "+int(flOne)+"."+int(flTwo)+"0" );
			}
			else	// English
			{
				if( mode == 0 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote started by " + pPlayer.pev.netname +"\n" );
				if( mode == 1 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote for disable Anti-Rush passed." );
				if( mode == 2 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote for enable Anti-Rush passed." );
				if( mode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote has been disabled on this server." );
				if( mode == 4 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] " + int(flOne*100) + "% Of players needed to continue. Current: "+ int(flTwo*100) + "%\n" );
				if( mode == 5 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Kill remaining " + flOne + " enemies for progress.\n" );
				if( mode == 6 ) g_PlayerFuncs.HudMessage( pPlayer, thp, "[ANTI-RUSH] Count-down: "+int(flOne)+"."+int(flTwo)+"0" );
				if( mode == 7 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Anti-Rush is currently disabled. say /antirush to start a vote." );
				if( mode == 8 ) g_PlayerFuncs.ClientPrint( aPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Anti-Rush is currently enabled. say /antirush to start a vote." );
			}
		}
	}
}