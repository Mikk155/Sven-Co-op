DDDBarnacleSpeed func_barnacle_speed;

final class DDDBarnacleSpeed
{
    int enable = 1;
    int diff = 30;

    bool active()
    {
        return ( enable == 1 && g_DDD.diff >= diff );
    }

    float units()
    {
        return 0.2f * float( g_DDD.diff );
    }

    bool condition( CBasePlayer@ pPlayer )
    {
        if( active() && ( pPlayer.m_Activity == ACT_BARNACLE_PULL || pPlayer.pev.button & IN_DUCK > 0 ) )
        {
            TraceResult tr;
            g_Utility.TraceLine( pPlayer.pev.origin, Vector( 0, 0, 90 ) * 8192, dont_ignore_monsters, pPlayer.edict(), tr );

            CBaseEntity@ pBarnacle = g_EntityFuncs.Instance( tr.pHit );

            if( pBarnacle !is null and pBarnacle.GetClassname() == 'monster_barnacle'
            and abs( pBarnacle.pev.origin.z - ( ( pPlayer.pev.origin.z + pPlayer.pev.view_ofs.z ) - 8) ) >= 44 )
            {
                return true;
            }
        }
        return false;
    }
}