DDDMonsteralert func_monster_alert;

final class DDDMonsteralert
{
    int enable = 1;
    int diff = 70;

    bool active()
    {
        return ( enable == 1 && g_DDD.diff >= diff );
    }

    bool condition( CBaseMonster@ pVictim, CBaseEntity@ pInflictor )
    {
        if( active() && pInflictor !is null && pVictim.m_hEnemy.GetEntity() is null && InvalidEntities.find( pInflictor.GetClassname() ) < 0 )
        {
            return true;
        }
        return false;
    }

    array<string> InvalidEntities =
    {
        'bolt',
        'knife_throw',
        'monster_snark',
        'monster_tripmine',
        'weapon_lp_pipewrench',
        'weapon_lp_crossbolt',
        'weapon_lp_handgrenade',
        'grenade',
        'displacer_portal',
        'monster_chumtoad',
        'monster_satchel'
    };
}