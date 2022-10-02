// Code from rick https://github.com/RedSprend

// Description: Randomly teleport in aliens on a random player.
// Based on m_flCooldownTime and REQUIRED_PLAYER_COUNT

// TODO: (I will most likely not finish this plugin as I got bored of it)
// - prevent spawning the monster on (or too close) the player.
// - Trace a line from vecEnd downwards (vecEnd.z) to not let the alien spawn in mid air.
// - Use SetTimeout instead of SetInterval.

namespace DDD_ATELE
{
    array<string> g_szMonsters = 
    {
        "monster_alien_slave",
        "monster_headcrab",
        "monster_houndeye",
        "monster_snark",
        "monster_stukabat",
        "monster_sqknest"
    };

    float m_flCooldownTime = 0;
    int ATeleMaxCDN, ATeleMinCDN;
    CScheduledFunction@ g_pThink = null;

    void ATELEPRECACHE()
    {
        for( uint i = 0; i < g_szMonsters.length(); i++ )
        {
            g_Game.PrecacheMonster( g_szMonsters[i], false );
            g_Game.PrecacheMonster( g_szMonsters[i], true );
        }
    }

    void ATELE( int flDifficulty )
    {
        ATeleMaxCDN =  12000 / flDifficulty;
        ATeleMinCDN = 2400 / flDifficulty;

        RestoreTimer();
    }

    void RestoreTimer()
    {
        g_Scheduler.RemoveTimer( g_pThink );
        @g_pThink = null;

        // random delay between 2400 seconds (40 minutes) to 12000 seconds (200 minutes) in diff 0 while 24 seconds to 120 seconds in diff 100
        m_flCooldownTime = Math.RandomLong( ATeleMinCDN , ATeleMaxCDN);

		@g_pThink = g_Scheduler.SetInterval( "ATELECHECK", m_flCooldownTime, g_Scheduler.REPEAT_INFINITE_TIMES );
    }

    void ATELECHECK()
    {
        int iPlayerIndex = GetRandomPlayer();
        if( iPlayerIndex == -1)
            return;

        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );

        string szMonster = g_szMonsters[Math.RandomLong(0,g_szMonsters.length() - 1)];

        // TODO: keep some distance away from the player to prevent spawning the monster on (or too close) the player.
        Vector vecSrc = pPlayer.pev.origin;

        if( (pPlayer.pev.flags & FL_DUCKING) != 0 )
        {
            // Player is ducking
            if( szMonster != "monster_headcrab" && szMonster != "monster_snark" && szMonster != "monster_sqknest" )
            {
                vecSrc.z += 18;
            }

        }

        Vector vecEnd = vecSrc + Vector(Math.RandomLong(-512,512), Math.RandomLong(-512,512), 0);
        float flDir = Math.RandomLong(-360,360);

        vecEnd = vecEnd + g_Engine.v_right * flDir;

        TraceResult tr;
        g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

        CheckFreeSpace( szMonster, vecEnd, pPlayer);
    }

    void CheckFreeSpace( const string& in szClassname, Vector& in vecOrigin, CBaseEntity@ pPlayer )
    {
        TraceResult tr;
        HULL_NUMBER hullCheck = human_hull;

        // Small monsters
        if( szClassname == "monster_babycrab" || szClassname == "monster_headcrab" || szClassname == "monster_snark" || szClassname == "monster_sqknest" || szClassname == "monster_stukabat" )
        {
            hullCheck = head_hull;
        }

        g_Utility.TraceHull( vecOrigin, vecOrigin, dont_ignore_monsters, hullCheck, pPlayer.edict(), tr );

        if( tr.fAllSolid == 1 || tr.fStartSolid == 1 || tr.fInOpen == 0 )
        {
            // Obstructed! Try again
            RestoreTimer();
            return;
        }
        else
        {
            // All clear! Spawn here
            CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, null, true );

            if( pEntity !is null )
            {
                CreateSpawnEffect( szClassname, vecOrigin, EHandle(pPlayer) );

                RestoreTimer();
            }
        }
    }

    void CreateSpawnEffect( const string& in szClassname, Vector& in vecOrigin, EHandle hPlayer )
    {
        if( !hPlayer.IsValid() )
            return;

        int iBeamCount = 8;
        Vector vBeamColor = Vector(30, 150, 50);//Vector(217,226,146);
        int iBeamAlpha = 128;
        float flBeamRadius = 256;

        Vector vLightColor = Vector(39,209,137);
        float flLightRadius = 160;

        Vector vStartSpriteColor = Vector(65,209,61);
        float flStartSpriteScale = 1.0f;
        float flStartSpriteFramerate = 12;
        int iStartSpriteAlpha = 255;

        Vector vEndSpriteColor = Vector(159,240,214);
        float flEndSpriteScale = 1.0f;
        float flEndSpriteFramerate = 12;
        int iEndSpriteAlpha = 255;

        // create the clientside effect
        NetworkMessage msg( MSG_PVS, NetworkMessages::TE_CUSTOM, vecOrigin );
            msg.WriteByte( 2 );
            msg.WriteVector( vecOrigin );
            // for the beams
            msg.WriteByte( iBeamCount );
            msg.WriteVector( vBeamColor );
            msg.WriteByte( iBeamAlpha );
            msg.WriteCoord( flBeamRadius );
            // for the dlight
            msg.WriteVector( vLightColor );
            msg.WriteCoord( flLightRadius );
            // for the sprites
            msg.WriteVector( vStartSpriteColor );
            msg.WriteByte( int( flStartSpriteScale*10 ) );
            msg.WriteByte( int( flStartSpriteFramerate ) );
            msg.WriteByte( iStartSpriteAlpha );

            msg.WriteVector( vEndSpriteColor );
            msg.WriteByte( int( flEndSpriteScale*10 ) );
            msg.WriteByte( int( flEndSpriteFramerate ) );
            msg.WriteByte( iEndSpriteAlpha );
        msg.End();
	
        g_Scheduler.SetTimeout( "SpawnMonster", 1.2f, szClassname, vecOrigin, hPlayer );
    }

    void SpawnMonster( const string& in szClassname, Vector& in vecOrigin, EHandle hPlayer )
    {
        if( !hPlayer.IsValid() )
            return;

        CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
        if( pPlayer is null )
            return;

        CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, null, true );
        if( pEntity !is null )
        {
            g_EntityFuncs.SetOrigin( pEntity, vecOrigin );
            Vector vecAngles = Math.VecToAngles( pPlayer.pev.origin - pEntity.pev.origin );
            pEntity.pev.angles.y = vecAngles.y;
        }
    }

    int GetRandomPlayer() 
    {
        int[] iPlayer(g_Engine.maxClients + 1);
        int iPlayerCount = 0;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || (pPlayer.pev.flags & FL_FROZEN) != 0 )
                continue;

            iPlayer[iPlayerCount] = i;
            iPlayerCount++;
        }

        return (iPlayerCount == 0) ? -1 : iPlayer[Math.RandomLong(0,iPlayerCount-1)];
    }
}