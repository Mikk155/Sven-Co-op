DDDArmorVestNpcs func_armor_vest;

final class DDDArmorVestNpcs
{
    int enable = 1;
    float reduction = 0.8;

    bool condition( const string & in m_iszClassname, const int & in HitGroup )
    {
        return ( enable == 1 && ValidMonsters.find( m_iszClassname ) >= 0 && ( HitGroup == 2 || HitGroup == 3 ) );
    }

    array<string> ValidMonsters =
    {
        'monster_barney',
        'monster_zombie_barney',
        'monster_human_grunt',
        'monster_grunt_repel',
        'monster_male_assassin',
        // Need model with hitgroup 2/3!
        //'monster_hwgrunt',
        //'monster_hwgrunt_repel',
        'monster_human_grunt_ally',
        'monster_grunt_ally_repel',
        'monster_human_medic_ally',
        'monster_medic_ally_repel',
        'monster_human_torch_ally',
        'monster_torch_ally_repel'
    };
}