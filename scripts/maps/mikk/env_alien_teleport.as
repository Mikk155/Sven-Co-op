#include "utils"
namespace env_alien_teleport
{
    void Register() 
    {
        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#env_alien_teleport\n"
            "Author: Rick\n"
            "Github: github.com/RedSprend\n"
            "Description: Randomly teleport in aliens on a random player.\n"
        );

        g_CustomEntityFuncs.RegisterCustomEntity( "env_alien_teleport::entity", "env_alien_teleport" );
    }

    class entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Spawn()
        {
            Precache();

            if( g_Util.GetNumberOfEntities( self.GetClassname() ) > 1 )
            {
                g_Util.Debug( self.GetClassname() + ': Can not use more than one entity per level. Removing...' );
                g_EntityFuncs.Remove( self );
            }

            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Precache()
        {
            g_Game.PrecacheOther( string( self.pev.netname ) );
            BaseClass.Precache();
        }

        int GetRandomPlayer()
        {
            int[] iPlayer(g_Engine.maxClients + 1);

            int iPlayerCount = 0;

            for( int i = 1; i <= g_Engine.maxClients; i++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                if( pPlayer is null
                or !pPlayer.IsAlive()
                or !pPlayer.IsConnected()
                or (pPlayer.pev.flags & FL_FROZEN) != 0 )
                {
                    continue;
                }

                iPlayer[iPlayerCount] = i;
                iPlayerCount++;
            }
            return (iPlayerCount == 0) ? -1 : iPlayer[Math.RandomLong(0,iPlayerCount-1)];
        }

        void TriggerThink()
        {
            int iPlayerIndex = GetRandomPlayer();

            if( master() or iPlayerIndex == -1 )
            {
                self.pev.nextthink = g_Engine.time + 0.1f;
                return;
            }

            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );

            // TODO: keep some distance away from the player to prevent spawning the monster on (or too close) the player.
            Vector vecSrc = pPlayer.pev.origin;

            Vector vecEnd = vecSrc + Vector(Math.RandomLong(-512,512), Math.RandomLong(-512,512), 0);
            float flDir = Math.RandomLong(-360,360);

            vecEnd = vecEnd + g_Engine.v_right * flDir;

            TraceResult tr;
            g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

            if( tr.flFraction >= 1.0 )
            {
                CheckFreeSpace( string( self.pev.netname ), vecEnd, pPlayer);
            }

            self.pev.nextthink = ( delay > 0.0 ) ? g_Engine.time + delay : g_Engine.time + 120.0f;
        }

        void CheckFreeSpace( const string& in szClassname, Vector& in vecOrigin, CBaseEntity@ pPlayer )
        {
            TraceResult tr;
            HULL_NUMBER hullCheck = human_hull;
            
                hullCheck = head_hull;

            g_Utility.TraceHull( vecOrigin, vecOrigin, dont_ignore_monsters, hullCheck, pPlayer.edict(), tr );

            if( tr.fAllSolid == 1 || tr.fStartSolid == 1 || tr.fInOpen == 0 )
            {
                // Obstructed! Try again
                g_Util.Trigger( self.pev.noise, pPlayer, self, USE_TOGGLE, 0.0f );
                return;
            }
            else
            {
                // All clear! Spawn here
                SpawnMonster( szClassname, vecOrigin, EHandle(pPlayer) );
            }
        }

        void SpawnMonster( const string& in szClassname, Vector& in vecOrigin, EHandle hPlayer )
        {
            if( !hPlayer.IsValid() )
                return;

            CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());

            if( pPlayer is null )
            {
                return;
            }

            CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, null, true );
            
            if( pEntity !is null )
            {
                g_EntityFuncs.SetOrigin( pEntity, vecOrigin );
                Vector vecAngles = Math.VecToAngles( pPlayer.pev.origin - pEntity.pev.origin );
                pEntity.pev.angles.y = vecAngles.y;

                CBaseEntity@ pXenMaker = g_EntityFuncs.FindEntityByTargetname( pXenMaker, ( self.pev.message ) );
                
                if( pXenMaker !is null /*&& pXenMaker.pev.ClassNameIs( 'env_xenmaker' )*/ )
                {
                    Vector VecOld = pXenMaker.pev.origin;

                    pXenMaker.pev.origin = pEntity.pev.origin + Vector( 0, 40, 0 );
                    pXenMaker.Use( self, self, USE_TOGGLE, 0.0f );

                    pXenMaker.pev.origin = VecOld;
                }

                g_Util.Trigger( self.pev.target, pPlayer, pEntity, USE_TOGGLE, 0.0f );
            }
        }
    }
}
// End of namespace