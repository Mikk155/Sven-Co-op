#include "../../respawndead_keepweapons"

void RegisterSurvivalManager() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "survival_manager", "survival_manager" );
}

HUDTextParams HudText;

enum survival_manager_flag
{
    SF_SM_KEEP_INVENTORY = 1 << 0,
    SF_SM_HIDE_MESSAGESC = 2 << 0
}

class survival_manager : ScriptBaseEntity
{
    private bool toggle	= true;

    void Spawn()
    {
        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.5f;

        BaseClass.Spawn();
    }

    void TriggerThink()
    {
        if( g_PlayerFuncs.GetNumPlayers() > 0 )
        {
            g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 1 );
            g_EngineFuncs.CVarSetFloat( "mp_survival_supported", 1 );
            g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 1 );
            g_SurvivalMode.Activate( true );
            g_SurvivalMode.Enable();
            SetThink( ThinkFunction( this.SurvivalMode ) );
            self.pev.nextthink = g_Engine.time + 1.0f;
        }
        self.pev.nextthink = g_Engine.time + 0.5f;
    }

    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
        if( toggle ) { Enable(); } else { Disable(); }

        toggle = !toggle;
    }

    void Enable()
    {
        Advice( 2 );
        g_EngineFuncs.CVarSetFloat( "mp_dropweapons", int( self.pev.iuser1) );
        g_EntityFuncs.FireTargets( string( self.pev.netname ), null, null, USE_TOGGLE );

        SetThink( ThinkFunction( this.SurvivalMode ) );
        self.pev.nextthink = g_Engine.time + 1.0f;
    }

    void Advice( int imode )
    {
        if( !self.pev.SpawnFlagBitSet( SF_SM_HIDE_MESSAGESC ) )
        {
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if(pPlayer is null ) { continue; }

                SURVIVALMANAGER::Messager( pPlayer, imode, 0 );
            }
        }

        NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
        message.WriteString( "spk buttons/bell1" );
        message.End();
    }

    void Disable()
    {
        Advice( 1 );
        g_EngineFuncs.CVarSetFloat( "mp_dropweapons", int( self.pev.iuser2) );
        g_EntityFuncs.FireTargets( string( self.pev.target ), null, null, USE_TOGGLE );

        SetThink( null );
    }

    void SurvivalMode()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if(pPlayer is null ) { continue; }

            CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
            int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_survivaln_t").GetInteger();

            if( kvSpawnIs >= 0 )
            {
                if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() )
                {
                    SURVIVALMANAGER::Messager( pPlayer, 0, kvSpawnIs );

                    ckvSpawns.SetKeyvalue("$i_survivaln_t", kvSpawnIs - 1 );
                }
                if( pPlayer.IsAlive() && kvSpawnIs != int( self.pev.health ) )
				{
                    ckvSpawns.SetKeyvalue("$i_survivaln_t", int( self.pev.health ) );
                }
				else if( kvSpawnIs <= 0 )
				{
                    g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );

					// Must include https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as
					if( self.pev.SpawnFlagBitSet( SF_SM_KEEP_INVENTORY ) )
					{
					    RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, true );
					}

                    ckvSpawns.SetKeyvalue("$i_survivaln_t", int( self.pev.health ) );
                }
            }
        }

        if( int( self.pev.frags ) > 0 )
        {
            self.pev.frags = self.pev.frags -1;
        }
        else if( int( self.pev.frags ) == 0 )
        {
            self.pev.frags = -1;
            Disable();
        }
        self.pev.nextthink = g_Engine.time + 1.0f;
    }
}

namespace SURVIVALMANAGER
{
    void Messager( CBasePlayer@ pThis, int imode, float flvalue )
    {
        HudText.x = -1;
        HudText.y = -1;
        HudText.effect = 0;
        HudText.r1 = RGBA_SVENCOOP.r;
        HudText.g1 = RGBA_SVENCOOP.g;
        HudText.b1 = RGBA_SVENCOOP.b;
        HudText.a1 = 0;
        HudText.r2 = RGBA_SVENCOOP.r;
        HudText.g2 = RGBA_SVENCOOP.g;
        HudText.b2 = RGBA_SVENCOOP.b;
        HudText.a2 = 0;
        HudText.fadeinTime = 0; 
        HudText.fadeoutTime = 0.25;
        HudText.holdTime = 2;
        HudText.fxTime = 0;
        HudText.channel = 3;

        CustomKeyvalues@ ckLenguage = pThis.GetCustomKeyvalues();
        CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
        int iLanguage = int(ckLenguageIs.GetFloat());

        if(iLanguage == 1 )
        {
            if( imode == 0 ) g_PlayerFuncs.HudMessage( pThis, HudText, "Reviviras en " + flvalue +" segundos\n" );
            if( imode == 1 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now enabled.\n" );
            if( imode == 2 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now disabled.\n" );
        }
        else if(iLanguage == 2 )
        {
            if( imode == 0 ) g_PlayerFuncs.HudMessage( pThis, HudText, "reviver em " + flvalue +" segundos\n" );
            if( imode == 1 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now enabled.\n" );
            if( imode == 2 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now disabled.\n" );
        }
        else if(iLanguage == 3 )
        {
            if( imode == 0 ) g_PlayerFuncs.HudMessage( pThis, HudText, "wiederbeleben " + flvalue +" Sekunden\n" );
            if( imode == 1 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now enabled.\n" );
            if( imode == 2 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now disabled.\n" );
        }
        else if(iLanguage == 4 )
        {
            if( imode == 0 ) g_PlayerFuncs.HudMessage( pThis, HudText, "revivre dans " + flvalue +" secondes\n" );
            if( imode == 1 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now enabled.\n" );
            if( imode == 2 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now disabled.\n" );
        }
        else if(iLanguage == 5 )
        {
            if( imode == 0 ) g_PlayerFuncs.HudMessage( pThis, HudText, "rivivere " + flvalue +" secondi\n" );
            if( imode == 1 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now enabled.\n" );
            if( imode == 2 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now disabled.\n" );
        }
        else if(iLanguage == 0 )
        {
            if( imode == 0 ) g_PlayerFuncs.HudMessage( pThis, HudText, "Respawn in " + flvalue +" seconds\n" );
            if( imode == 1 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now enabled.\n" );
            if( imode == 2 ) g_PlayerFuncs.ClientPrint( pThis, HUD_PRINTTALK, "Survival mode is now disabled.\n" );
        }
    }
}