/*
	Usage:
	
	"m_iszScriptFile" "mikk/callbacks"
	
	See the wiki
	https://github.com/Mikk155/Sven-Co-op/wiki/callbacks-Spanish

*/

// Enable to see debugs
bool DebugMode = true;

HUDTextParams HudParams;
HudParams.x = -1;
HudParams.effect = 0;
HudParams.r1 = RGBA_SVENCOOP.r;
HudParams.g1 = RGBA_SVENCOOP.g;
HudParams.b1 = RGBA_SVENCOOP.b;
HudParams.a1 = 0;
HudParams.r2 = RGBA_SVENCOOP.r;
HudParams.g2 = RGBA_SVENCOOP.g;
HudParams.b2 = RGBA_SVENCOOP.b;
HudParams.a2 = 0;
HudParams.fadeinTime = 0; 
HudParams.fadeoutTime = 0.25;
HudParams.fxTime = 0;

namespace CTriggerScripts
{
    void GetKillerTriggerTarget( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        CBaseEntity@ pInflictor = g_EntityFuncs.Instance( pActivator.pev.dmg_inflictor );
        CBaseMonster@ pMonsterActivator = cast<CBaseMonster@>(pActivator);
        CBaseEntity@ pTriggerScript = null;

        while( ( @pTriggerScript = g_EntityFuncs.FindEntityByClassname( pTriggerScript, "trigger_script" )) !is null )
        {
            if( string( pMonsterActivator.m_iszTriggerTarget ) == string( pTriggerScript.pev.targetname ) )
            {
                if( DebugMode ) { g_Game.AlertMessage( at_console, "\n\nTS DEBUG-: Monster Fire it's condition.\nfound " + pTriggerScript.pev.classname + "\n netname " + pTriggerScript.pev.netname + " has been fired.\n\n" ); }
                g_EntityFuncs.FireTargets( pTriggerScript.pev.netname, pInflictor, pInflictor, USE_TOGGLE );
            }
        }
    }

    void ToggleSurvivalMode( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( !g_SurvivalMode.IsActive() or !g_SurvivalMode.IsEnabled() )
        {
            g_SurvivalMode.Activate( true );
            g_SurvivalMode.Enable();
            if( DebugMode ) { g_Game.AlertMessage( at_console, "\n\nTS DEBUG-: Survival mode has been enabled\n\n" ); }
        }
        else
        {
            g_SurvivalMode.Disable();
            if( DebugMode ) { g_Game.AlertMessage( at_console, "\n\nTS DEBUG-: Survival mode has been disabled\n\n" ); }
        }
    }

    void Stealth( CBaseEntity@ pTriggerScript )
    {
        CBaseEntity@ pEnemy = null;
        while( ( @pEnemy = g_EntityFuncs.FindEntityByTargetname( pEnemy, string( pTriggerScript.pev.target ) )) !is null )
        {
            CBaseMonster@ pMoster = cast<CBaseMonster@>(pEnemy);

            if( pMoster.m_hEnemy.GetEntity() !is null )
            {
                CBaseEntity@ pTeleport = null;
                while( ( @pTeleport = g_EntityFuncs.FindEntityByTargetname( pTeleport, pTriggerScript.pev.netname )) !is null )
                {
                    pMoster.m_hEnemy.GetEntity().SetOrigin( pTeleport.pev.origin );
                    g_EntityFuncs.FireTargets( string(pTriggerScript.pev.message), pMoster.m_hEnemy.GetEntity(), pMoster.m_hEnemy.GetEntity(), USE_TOGGLE, 0.0f, 0.0f );
                    if( DebugMode ) { g_Game.AlertMessage( at_console, "\n\nTS DEBUG-: Player"+pMoster.m_hEnemy.GetEntity().pev.netname+" spotted. fired target and teleported.\n\n" ); }
                }
                pMoster.m_hEnemy = null;
            }
        }
    }

    void RenderProgressive( CBaseEntity@ pTriggerScript )
    {
        CBaseEntity@ pEntity = null;
        while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, pTriggerScript.pev.target)) !is null)
        {
            if( pTriggerScript.pev.renderamt > pEntity.pev.renderamt ) pEntity.pev.renderamt += 1; else pEntity.pev.renderamt -= 1;
            if( pEntity.pev.renderamt == pTriggerScript.pev.renderamt ) g_EntityFuncs.FireTargets( ""+pTriggerScript.pev.targetname, null, null, USE_TOGGLE );
        }
    }

    void ShowTimer( CBaseEntity@ pTriggerScript )
    {
        HudParams.holdTime = 2;
        HudParams.channel = 3;
        HudParams.y = 0.90;

        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsConnected() ) continue;

            CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
            CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
            int iLanguage = int(ckLenguageIs.GetFloat());
			
            if(iLanguage == 1 ) g_PlayerFuncs.HudMessage( pPlayer, HudParams, "El juego comenzara en "+int(pTriggerScript.pev.health)+" segundos.\n" );
            else if(iLanguage == 2 ) g_PlayerFuncs.HudMessage( pPlayer, HudParams, "O jogo comecara em "+int(pTriggerScript.pev.health)+" segundos.\n" );
            else if(iLanguage == 3 ) g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Das Spiel beginnt in "+int(pTriggerScript.pev.health)+" Sekunden.\n" );
            else if(iLanguage == 4 ) g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Le jeu commencera dans "+int(pTriggerScript.pev.health)+" secondes.\n" );
            else if(iLanguage == 5 ) g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Il gioco iniziera tra "+int(pTriggerScript.pev.health)+" secondi.\n" );
            else if(iLanguage == 6 ) g_PlayerFuncs.HudMessage( pPlayer, HudParams, "La ludo komencigos en "+int(pTriggerScript.pev.health)+" sekundoj.\n" );
            else g_PlayerFuncs.HudMessage( pPlayer, HudParams, "The game will start in "+int(pTriggerScript.pev.health)+" seconds.\n" );
        }

        pTriggerScript.pev.health -= 1;

        if( int( pTriggerScript.pev.health) <= 0 )
        {
            g_EntityFuncs.FireTargets( string( pTriggerScript.pev.netname ), pTriggerScript, pTriggerScript, USE_TOGGLE );
            if( DebugMode ) { g_Game.AlertMessage( at_console, "\n\nTS DEBUG-: Counter ended. netname Fired.\n\n" ); }
            g_EntityFuncs.Remove( pTriggerScript );
        }
    }

    void Invisibility( CBaseEntity@ pTriggerScript )
    {
        HudParams.holdTime = 1.2;
        HudParams.channel = 5;
        HudParams.y = 0.70;

        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
            if( pPlayer is null || !pPlayer.IsConnected() )
                continue;

            CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
            CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
            int iLanguage = int(ckLenguageIs.GetFloat());

            CustomKeyvalues@ ckinvi = pPlayer.GetCustomKeyvalues();
            CustomKeyvalue ckinvifl = ckinvi.GetKeyvalue("$i_invisibility");
            int ckinviint = int(ckinvifl.GetFloat());

            if( pPlayer.pev.button & IN_DUCK == 0)
            {
                ckinvi.SetKeyvalue( "$i_invisibility", 6 );
                pPlayer.pev.flags &= ~FL_NOTARGET;
                pPlayer.pev.rendermode  = kRenderNormal;
                pPlayer.pev.renderamt = 255;
                pPlayer.UnblockWeapons( pTriggerScript );
                continue;
            }
            else if( pPlayer.pev.button & IN_DUCK != 0)
            {
                if( ckinviint <= 0 )
                {
                    pPlayer.pev.flags |= FL_NOTARGET;
                    pPlayer.pev.rendermode = kRenderTransAlpha;
                    pPlayer.pev.renderamt = 30;
                    pPlayer.BlockWeapons( pTriggerScript );
                    continue;
                }

                ckinvi.SetKeyvalue( "$i_invisibility", ckinviint - 1 );

                if(iLanguage == 1 )g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entrando en modo invisible en "+ckinviint+ " segundos.\n" );
                else if(iLanguage == 2 )g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entering invisible mode in "+ckinviint+ " seconds.\n" );
                else if(iLanguage == 3 )g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entering invisible mode in "+ckinviint+ " seconds.\n" );
                else if(iLanguage == 4 )g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entering invisible mode in "+ckinviint+ " seconds.\n" );
                else if(iLanguage == 5 )g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entering invisible mode in "+ckinviint+ " seconds.\n" );
                else if(iLanguage == 6 )g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entering invisible mode in "+ckinviint+ " seconds.\n" );
                else g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Entering invisible mode in "+ckinviint+ " seconds.\n" );
            }
        }
    }
}
// End of namespace