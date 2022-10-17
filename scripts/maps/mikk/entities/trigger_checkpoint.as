/*
	Rework of the point_checkpoint. please don't just replace this. Check the entity or the FGD first.

INSTALL:

#include "mikk/entities/trigger_checkpoint"

void MapInit()
{
	RegisterTriggerCheckpoint( "trigger_checkpoint", true);
}

*/

#include "../../respawndead_keepweapons"
#include "utils"

void RegisterTriggerCheckpoint( const string ClassName = "trigger_checkpoint", const bool KeepSpawns = true )
{
    g_CustomEntityFuncs.RegisterCustomEntity( "trigger_checkpoint", ClassName );
    g_Game.PrecacheOther( ClassName );
    
    if( KeepSpawns )
    {
        g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    }
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

    CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
    int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_chkpoint").GetInteger();

    PlayerKeepSpawnsData pData;
	pData.spawn = kvSpawnIs;
	g_PlayerKeepSpawns[SteamID] = pData;   

    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

    CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
    int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_chkpoint").GetInteger();

	if( g_PlayerKeepSpawns.exists(SteamID) )
	{
        PlayerLoadSpawns( g_EngineFuncs.IndexOfEdict(pPlayer.edict()), SteamID );
	}
    else
    {
		PlayerKeepSpawnsData pData;
		pData.spawn = kvSpawnIs;
		g_PlayerKeepSpawns[SteamID] = pData;
    }
	return HOOK_CONTINUE;
}

void PlayerLoadSpawns( int &in iIndex, string &in SteamID )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

	if( pPlayer is null )
		return;

	PlayerKeepSpawnsData@ pData = cast<PlayerKeepSpawnsData@>(g_PlayerKeepSpawns[SteamID]);

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	ckLenguage.SetKeyvalue("$i_chkpoint", int(pData.spawn));
}

HUDTextParams Textparams;

dictionary g_PlayerKeepSpawns;

class PlayerKeepSpawnsData
{
	int spawn;
}

enum trigger_checkpoint_flags
{
    SF_TCP_KEEP_VECT = 1 << 0,
    SF_TCP_INSTA_RES = 1 << 1,
    SF_TCP_KEEP_AMMO = 1 << 2,
    SF_TCP_COUNT_ONE = 1 << 3,
    SF_TCP_EUSE_ONLY = 1 << 4
}

class trigger_checkpoint : ScriptBaseEntity
{
    private int buttonin = IN_USE;
    private string bustr = "use";
    private string music = "../media/valve.mp3";

    bool KeyValue( const string& in szKey, const string& in szValue ) 
    {
        if( szKey == "music" )
        {
            music = szValue;
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
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }
    }

    void Precache()
    {
        if( string( self.pev.model ).IsEmpty() )
        {
            g_Game.PrecacheModel( "models/common/lambda.mdl" );
        }
        else
        {
            g_Game.PrecacheModel( self.pev.model );
        }

        g_SoundSystem.PrecacheSound( music );

        BaseClass.Precache();
	}

    void Spawn()
    {
        self.pev.solid = SOLID_NOT;
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.rendermode = kRenderTransAlpha;
        self.pev.framerate = 1.0f;
        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        if( string( self.pev.model ).StartsWith ( "*" ) && self.IsBSPModel() )
        {
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
            self.pev.effects |= EF_NODRAW;
        }
        else
        {
            g_EntityFuncs.SetModel( self, "models/common/lambda.mdl" );

            if( self.pev.vuser1 != g_vecZero && self.pev.vuser2 != g_vecZero )
            {
                g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
            }
            else
            {
                g_EntityFuncs.SetSize( self.pev, Vector( -64, -64, -36 ), Vector( 64, 64, 36 ) );
            }
        }
        g_EntityFuncs.SetModel( self, self.pev.model );

        if( self.pev.health == 0 )
        {
            self.pev.health = 3;
        }

        if( self.pev.frags == 32 || self.pev.frags == 0 )
        {
            buttonin = IN_USE;
            bustr = "use";
        }
        if( self.pev.frags == 1 )
        {
            buttonin = IN_ATTACK;
            bustr = "attack";
        }
        if( self.pev.frags == 2 )
        {
            buttonin = IN_JUMP;
            bustr = "jump";
        }
        if( self.pev.frags == 4 )
        {
            buttonin = IN_DUCK;
            bustr = "duck";
        }
        if( self.pev.frags == 2048 )
        {
            buttonin = IN_ATTACK2;
            bustr = "attack2";
        }
        if( self.pev.frags == 8192 )
        {
            buttonin = IN_RELOAD;
            bustr = "reload";
        }
        if( self.pev.frags == 16384 )
        {
            buttonin = IN_ALT1;
            bustr = "alt1";
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;

        BaseClass.Spawn();
    }

    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( self.pev.health == 0 ) self.pev.health = 1;

        if( self.pev.health == 4 )
        {
            Activation( null );
        }
        else
        {
            switch(useType)
            {
                case USE_ON:
                    self.pev.health = self.pev.health +1;
                break;

                case USE_OFF:
                    self.pev.health = self.pev.health -1;
                break;

                default:
                    self.pev.health = self.pev.health +1;
                break;
            }
        }
    }

    void TriggerThink()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                continue;

            if( self.pev.health <= 1 || !g_SurvivalMode.IsActive() )
            {
                if( self.pev.renderamt > 0 )
                    self.pev.renderamt = self.pev.renderamt -10;
                continue;
            }
            else
            {
                if( self.pev.renderamt < 255 )
                    self.pev.renderamt = self.pev.renderamt +10;
            }

            if( UTILS::InsideZone( pPlayer, self ) )
            {
                if( self.pev.health == 2 )
                {
                    Messager( pPlayer, 4, null );
                    continue;
                }

                if( self.pev.health == 4 )
                {
                    Messager( pPlayer, 3, null );
                    continue;
                }

                if( self.pev.SpawnFlagBitSet( SF_TCP_EUSE_ONLY ) )
                {
                    if( pPlayer.m_afButtonLast & IN_USE == 0)
                    {
                        Messager( pPlayer, 5, null );
                        continue;
                    }
                }

                Activation( pPlayer );

                // HACK Cuz im stupid and i don't know how to do global Think :/
                CBaseEntity@ pCps = null;
                while( ( @pCps = g_EntityFuncs.FindEntityByClassname( pCps, self.GetClassname() ) ) !is null )
                {
                    if( pCps.pev.iuser2 == 0 )
                        pCps.pev.iuser2 = pCps.pev.iuser2 +1;
                }

                self.pev.health = 0;
            }
        }

        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pDeadPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pDeadPlayer is null || !pDeadPlayer.IsConnected() || pDeadPlayer.IsAlive() )
                continue;

            if( pDeadPlayer.GetObserver().IsObserver() )
            {
                CustomKeyvalues@ ckvSpawns = pDeadPlayer.GetCustomKeyvalues();
                int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_chkpoint").GetInteger();

                Messager( pDeadPlayer, 1, null );

                if( kvSpawnIs > 0 )
                {
                    if( self.pev.health == 0 )
                    {
                        Messager( pDeadPlayer, 2, null );

                        if( pDeadPlayer.m_afButtonLast & buttonin != 0  )
                        {
                            ckvSpawns.SetKeyvalue("$i_chkpoint", kvSpawnIs - 1 );

                            Resurrect( pDeadPlayer );

                            if( !string( self.pev.netname ).IsEmpty() )
                            {
                                g_EntityFuncs.FireTargets( self.pev.netname, pDeadPlayer, pDeadPlayer, USE_TOGGLE );
                            }

                            if( !string( self.pev.message ).IsEmpty() )
                            {
                                CBaseEntity@ pXenMaker = g_EntityFuncs.FindEntityByTargetname( pXenMaker, string( self.pev.message ) );

                                g_EntityFuncs.SetOrigin( pXenMaker, pDeadPlayer.Center() );
                                g_EntityFuncs.FireTargets( string( self.pev.message ), pDeadPlayer, pDeadPlayer, USE_TOGGLE );
                            }
                        }
                    }
                }
            }
        }
        self.pev.nextthink = g_Engine.time + 0.1f;
    }

    void Activation( CBasePlayer@ pPlayer )
    {        
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pAllPlayers = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pAllPlayers is null || !pAllPlayers.IsConnected() )
                continue;

            Messager( pAllPlayers, 0, pPlayer );

            if( self.pev.SpawnFlagBitSet( SF_TCP_INSTA_RES ) )
            {
                Resurrect( pAllPlayers );
            }
            else if( !self.pev.SpawnFlagBitSet( SF_TCP_COUNT_ONE ) )
            {
                AddSpawn( pAllPlayers );
            }
        }

        g_SoundSystem.EmitSound(self.edict(), CHAN_STATIC, music, 1.0f, ATTN_NONE);

        if( self.pev.SpawnFlagBitSet( SF_TCP_COUNT_ONE ) )
        {
            AddSpawn( pPlayer );
        }

        if( string( self.pev.target ).IsEmpty() )
        {
            return;
        }
        else if( string( self.pev.target ).EndsWith( "#0" ) )
        {
            g_EntityFuncs.FireTargets( self.pev.target, pPlayer, pPlayer, USE_OFF );
        }
        else if( string( self.pev.target ).EndsWith( "#1" ) )
        {
            g_EntityFuncs.FireTargets( self.pev.target, pPlayer, pPlayer, USE_ON );
        }
        else if( string( self.pev.target ).EndsWith( "#2" ) )
        {
            g_EntityFuncs.FireTargets( self.pev.target, pPlayer, pPlayer, USE_KILL );
        }
        else
        {
            g_EntityFuncs.FireTargets( self.pev.target, pPlayer, pPlayer, USE_TOGGLE );
        }
    }

    void AddSpawn( CBasePlayer@ pPlayer )
    {
        CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
        int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_chkpoint").GetInteger();
        ckvSpawns.SetKeyvalue("$i_chkpoint", kvSpawnIs + 1 );
    }

    void Resurrect( CBasePlayer@ pPlayer )
    {
        if( self.pev.SpawnFlagBitSet( SF_TCP_KEEP_VECT ) )
        {
            pPlayer.GetObserver().RemoveDeadBody();
            pPlayer.SetOrigin( ( self.IsBSPModel() )  ? self.Center() : self.pev.origin );
            //g_EntityFuncs.SetOrigin( pPlayer, sVector );
            pPlayer.Revive();
        }
        else
        {
            // This way prevent players from get stuck when the map does a forced teleport -Mikk
            g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );

            // Must include https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as
            RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, self.pev.SpawnFlagBitSet( SF_TCP_KEEP_AMMO ) );
        }
    }

    void Messager( CBasePlayer@ pPlayer, int imode, CBasePlayer@ pActivator )
    {
        CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
        CustomKeyvalues@ ckLenguag = pPlayer.GetCustomKeyvalues();
        int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_chkpoint").GetInteger();
        int iLanguage = ckLenguag.GetKeyvalue("$f_lenguage").GetInteger();

        Textparams.x = 0.05;
        Textparams.y = 0.05;
        Textparams.effect = 0;
        Textparams.r1 = (kvSpawnIs > 0) ? RGBA_SVENCOOP.r : RGBA_RED.r;
        Textparams.g1 = (kvSpawnIs > 0) ? RGBA_SVENCOOP.g : RGBA_RED.g;
        Textparams.b1 = (kvSpawnIs > 0) ? RGBA_SVENCOOP.b : RGBA_RED.b;
        Textparams.a1 = 0;
        Textparams.r2 = (kvSpawnIs > 0) ? RGBA_SVENCOOP.r : RGBA_RED.r;
        Textparams.g2 = (kvSpawnIs > 0) ? RGBA_SVENCOOP.g : RGBA_RED.g;
        Textparams.b2 = (kvSpawnIs > 0) ? RGBA_SVENCOOP.b : RGBA_RED.b;
        Textparams.a2 = 0;
        Textparams.fadeinTime = 0; 
        Textparams.fadeoutTime = 0;
        Textparams.holdTime = 0.5;
        Textparams.fxTime = 0;
        Textparams.channel = 3;

        if( iLanguage == 1 )
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Juego guardado por " + ((pActivator is null) ? 'el mapa' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Vidas: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Presiona +'+ bustr +' para re-aparecer');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "Este punto de control no puede ser activado.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "Este punto de control no esta activo aun.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Presiona +use para activarlo');
        }
        else if( iLanguage == 2 )
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Game Saved by " + ((pActivator is null) ? 'the map' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Spawns: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +'+ bustr +' to re-spawn');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint can't be activated.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint is not active yet.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +use to activate');
        }
        else if( iLanguage == 3 )
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Game Saved by " + ((pActivator is null) ? 'the map' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Spawns: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +'+ bustr +' to re-spawn');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint can't be activated.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint is not active yet.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +use to activate');
        }
        else if( iLanguage == 4 )
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Game Saved by " + ((pActivator is null) ? 'the map' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Spawns: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +'+ bustr +' to re-spawn');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint can't be activated.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint is not active yet.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +use to activate');
        }
        else if( iLanguage == 5 )
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Game Saved by " + ((pActivator is null) ? 'the map' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Spawns: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +'+ bustr +' to re-spawn');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint can't be activated.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint is not active yet.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +use to activate');
        }
        else if( iLanguage == 6 )
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Game Saved by " + ((pActivator is null) ? 'the map' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Spawns: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +'+ bustr +' to re-spawn');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint can't be activated.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint is not active yet.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +use to activate');
        }
        else
        {
            if( imode == 0 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Game Saved by " + ((pActivator is null) ? 'the map' : ''+pActivator.pev.netname ) + ".\n");
            if( imode == 1 ) g_PlayerFuncs.HudMessage( pPlayer, Textparams, "Spawns: " + kvSpawnIs );
            if( imode == 2 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +'+ bustr +' to re-spawn');
            if( imode == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint can't be activated.\n");
            if( imode == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This checkpoint is not active yet.\n");
            if( imode == 5 ) g_PlayerFuncs.PrintKeyBindingString(pPlayer, 'Press +use to activate');
        }
    }
}
// End of namespace