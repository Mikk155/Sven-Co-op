#include "utils"

namespace counterstrike_classes
{
    CScheduledFunction@ g_DelayedRegister = g_Scheduler.SetTimeout( "Register", 0.0f );

    void Register()
    {
        g_EngineFuncs.CVarSetString( 'mp_observer_mode', '1' );
        g_EngineFuncs.CVarSetString( 'mp_respawndelay', '0' );

        CBaseEntity@ pSpawnPoint = null;

        while( ( @pSpawnPoint = g_EntityFuncs.FindEntityByClassname( pSpawnPoint, 'info_player_*' ) ) !is null )
        {
            if( pSpawnPoint !is null )
            {
                if( pSpawnPoint.GetClassname() == 'info_player_deathmatch' && pSpawnPoint.pev.message != 'CT' )
                {
                    pSpawnPoint.pev.message = 'T';
                    pSpawnPoint.pev.spawnflags = 40;
                }

                if( pSpawnPoint.GetClassname() == 'info_player_start' )
                {
                    CBaseEntity@ pNewSpawnPoint = g_EntityFuncs.Create( 'info_player_deathmatch', pSpawnPoint.pev.origin, pSpawnPoint.pev.angles, false );

                    if( pNewSpawnPoint !is null )
                    {
                        pNewSpawnPoint.pev.message = 'CT';
                        pNewSpawnPoint.pev.spawnflags = 40;
                        pNewSpawnPoint.pev.targetname = pSpawnPoint.pev.targetname;
                        pNewSpawnPoint.pev.target = pSpawnPoint.pev.target;
                        g_EntityFuncs.Remove( pSpawnPoint );
                    }
                }

            }
        }

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'counterstrike_classes' ) +
            g_ScriptInfo.Description( 'Allow T-CT spawns as it normaly is by its spawnpoints' ) +
            g_ScriptInfo.Wiki( 'counterstrike_classes' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    void VoteClass( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fldelay )
    {
        if( pActivator !is null )
        {
            CreateMenu( cast< CBasePlayer@ >( pActivator ) );
        }
    }

    void SetT( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fldelay )
    {
        if( pActivator !is null )
        {
            pActivator.pev.targetname = 'T';
        }
    }

    void SetCT( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fldelay )
    {
        if( pActivator !is null )
        {
            pActivator.pev.targetname = 'CT';
        }
    }

    CTextMenu@ g_VoteMenu;
    void CreateMenu( CBasePlayer@ pPlayer )
    {
        @g_VoteMenu = CTextMenu( @MainCallback );
        g_VoteMenu.SetTitle( 'Choose Team' );
        g_VoteMenu.AddItem( 'Terrorist' );
        g_VoteMenu.AddItem( 'Counter-Terrorist' );
        g_VoteMenu.Register();
        g_VoteMenu.Open( 25, 0, pPlayer );
    }

    void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
    {
        if( pItem !is null )
        {
            if( pItem.m_szName == 'Terrorist' )
            {
                pPlayer.pev.targetname = 'T';
            }
            else if( pItem.m_szName == 'Counter-Terrorist' )
            {
                pPlayer.pev.targetname = 'CT';
            }
            else
            {
                g_Scheduler.SetTimeout( "CreateMenu", 1.0f, @pPlayer );
            }
        }
    }
}