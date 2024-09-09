DDDDeathDrop func_deathdrop;

final class DDDDeathDrop
{
    int enable_grenade = 1;
    int diff_grenade = 1;

    bool active( int tu, int td )
    {
        return ( tu == 1 && g_DDD.diff >= td );
    }

    bool can_drop_grenade( CBaseMonster@ pMonster )
    {
        return ( active( enable_grenade, diff_grenade ) && ValidGrenadeMonsters.find( pMonster.GetClassname() ) >= 0 && g_DDD.diff >= Math.RandomLong( 0, 100 ) );
    }

    void drop_grenade( CBaseMonster@ pMonster )
    {
        float X = Math.RandomFloat( 0.0f, 100.0f );
        float Y = Math.RandomFloat( 0.0f, 100.0f );
        float Z = Math.RandomFloat( 0.0f, 100.0f );
        float T = Math.RandomFloat( 2.0f, 5.5f );
        g_EntityFuncs.ShootTimed( pMonster.pev, pMonster.pev.origin, Vector( X, Y, Z ), T );
    }

    array<string> ValidGrenadeMonsters =
    {
        'monster_zombie_soldier',
        'monster_human_grunt',
        'monster_grunt_repel',
        'monster_human_assassin',
        'monster_male_assassin',
        'monster_hwgrunt',
        'monster_hwgrunt_repel',
        'monster_human_grunt_ally',
        'monster_grunt_ally_repel',
        'monster_human_medic_ally',
        'monster_medic_ally_repel',
        'monster_human_torch_ally',
        'monster_torch_ally_repel',
        'monster_gonome'
    };
}