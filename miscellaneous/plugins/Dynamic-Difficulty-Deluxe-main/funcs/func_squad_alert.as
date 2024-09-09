DDDSquadAlert func_squad_alert;

final class DDDSquadAlert
{
    int enable = 1;
    int diff = 30;

    bool active()
    {
        return ( enable == 1 && g_DDD.diff >= diff );
    }

    bool condition( CBaseMonster@ pMonster )
    {
        if( active() && pMonster.pev.netname != '' )
        {
            return true;
        }
        return false;
    }

    void MoveSquad( CBaseMonster@ pMonster )
    {
        CBaseMonster@ pSquad = null;

        while( ( @pSquad = cast<CBaseMonster@>( g_EntityFuncs.FindEntityByString( pSquad, 'netname', pMonster.pev.netname ) ) ) !is null && pSquad.m_hEnemy.GetEntity() is null )
        {
            pSquad.m_hTargetEnt = EHandle( pMonster );
        }
    }
}