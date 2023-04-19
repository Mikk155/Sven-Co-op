/*

// INSTALLATION:

#include "mikk/game_stealth"

*/
#include 'utils'
namespace script
{
    void ScriptInfo()
    {
        g_Information.SetInformation
        ( 
            'Script: game_debug\n' +
            'Description: Entity wich when fired, shows a debug message, also shows other entities being triggered..\n' +
            'Author: Mikk\n' +
            'Discord: ' + g_Information.GetDiscord( 'mikk' ) + '\n'
            'Server: ' + g_Information.GetDiscord() + '\n'
            'Github: ' + g_Information.GetGithub()
        );
    }

    void random_value( CBaseEntity@ self )
    {
        g_Util.SetCKV( self, "$i_random", string( Math.RandomLong( int( self.pev.health ), int( self.pev.max_health ) ) ) );
        g_Util.SetCKV( self, "$f_random", string( Math.RandomFloat( self.pev.health , self.pev.max_health ) ) );
        self.Use( null, null, USE_OFF, 0.0f );
    }

    void survival_mode( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flDelay )
    {
        if( !g_SurvivalMode.MapSupportEnabled() ) { return; }
        if( useType == USE_ON ) { g_SurvivalMode.Enable( true ); }
        else if( useType == USE_OFF ) { g_SurvivalMode.Disable(); }
        else { g_SurvivalMode.Toggle(); }
    }

    void alien_teleport( CBaseEntity@ self )
    {
        int[] iPlayer( g_Engine.maxClients + 1 );

        int iPlayerCount = 0;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

            if( pPlayer is null || !pPlayer.IsAlive() || !pPlayer.IsConnected() || (pPlayer.pev.flags & FL_FROZEN) != 0 )
            {
                continue;
            }

            iPlayer[iPlayerCount] = i;
            iPlayerCount++;
        }

        int iPlayerIndex = ( iPlayerCount == 0 ) ? -1 : iPlayer[ Math.RandomLong( 0, iPlayerCount-1 ) ];

        if( iPlayerIndex == -1 )
        {
            return;
        }

        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );
        Vector vecSrc = pPlayer.pev.origin;
        Vector vecEnd = vecSrc + Vector(Math.RandomLong(-512,512), Math.RandomLong(-512,512), 0);
        float flDir = Math.RandomLong(-360,360);

        vecEnd = vecEnd + g_Engine.v_right * flDir;

        TraceResult tr;
        g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

        if( tr.flFraction >= 1.0 )
        {
            HULL_NUMBER hullCheck = human_hull;

            hullCheck = head_hull;

            g_Utility.TraceHull( vecEnd, vecEnd, dont_ignore_monsters, hullCheck, pPlayer.edict(), tr );

            if( tr.fAllSolid == 1 || tr.fStartSolid == 1 || tr.fInOpen == 0 )
            {
                g_Util.Trigger( self.pev.noise, pPlayer, self, USE_TOGGLE, 0.0f );
                return;
            }
            else
            {
                CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( self.pev.netname ), null, true );

                if( pEntity !is null )
                {
                    g_EntityFuncs.SetOrigin( pEntity, vecEnd );
                    Vector vecAngles = Math.VecToAngles( pPlayer.pev.origin - pEntity.pev.origin );
                    pEntity.pev.angles.y = vecAngles.y;

                    CBaseEntity@ pXenMaker = g_EntityFuncs.FindEntityByTargetname( pXenMaker, string( self.pev.target ) );

                    if( pXenMaker !is null )
                    {
                        Vector VecOld = pXenMaker.pev.origin;

                        pXenMaker.pev.origin = pEntity.pev.origin + Vector( 0, 40, 0 );
                        pXenMaker.Use( self, self, USE_TOGGLE, 0.0f );

                        pXenMaker.pev.origin = VecOld;
                    }
                    g_Util.Trigger( self.pev.message, pPlayer, pEntity, USE_TOGGLE, 0.0f );
                }
            }
        }
    }
}