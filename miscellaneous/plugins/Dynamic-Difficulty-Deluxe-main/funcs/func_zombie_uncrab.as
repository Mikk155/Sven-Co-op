DDDZombieUncrab func_zombie_uncrab;

final class DDDZombieUncrab
{
    int enable = 1;
    int diff = 1;

    bool active()
    {
        return ( enable == 1 && g_DDD.diff >= diff );
    }

    float units()
    {
        return 0.2f * float( g_DDD.diff );
    }

    bool MonsterTraceAttack( CBaseMonster@ pZombie, int & in iHitgroup )
    {
        if( active() && string( pZombie.pev.model ).EndsWith( '_uncrab.mdl' ) )
        {
            if( !m_CustomKeyValue.HasKey( pZombie, '$f_ddd_zcrabhealth' ) )
            {
                m_CustomKeyValue.SetValue( pZombie, '$f_ddd_zcrabhealth', g_EngineFuncs.CVarGetFloat( 'sk_headcrab_health' ) );
            }

            return ( iHitgroup == 1 );
        }
        return false;
    }

    int MonsterKilled( CBaseMonster@ pZombie )
    {
        if( active() && string( pZombie.pev.model ).EndsWith( '_uncrab.mdl' ) )
        {
            float fDamagedCrab;
            m_CustomKeyValue.GetValue( pZombie, '$f_ddd_zcrabhealth', fDamagedCrab );
            return int( fDamagedCrab );
        }
        return 0;
    }

    void CreateHeadCrab( CBaseMonster@ pZombie )
    {
        float fDamagedCrab;
        m_CustomKeyValue.GetValue( pZombie, '$f_ddd_zcrabhealth', fDamagedCrab );

        pZombie.pev.body = 1;
        pZombie.pev.solid = SOLID_NOT;
        Vector VecHeadSrc = pZombie.pev.origin + pZombie.pev.view_ofs;

        m_EntityFuncs.CreateEntity
        (
            {
                { 'origin', VecHeadSrc.ToString() },
                { 'classify', string( pZombie.Classify() ) },
                { 'classname', 'monster_headcrab' },
                { 'angles', pZombie.pev.angles.ToString() },
                { 'health', string( fDamagedCrab ) }
            }
        ).pev.velocity.z = 500;
    }
}
