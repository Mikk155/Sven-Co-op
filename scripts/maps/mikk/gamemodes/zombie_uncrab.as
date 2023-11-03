#include '../as_register'

namespace zombie_uncrab
{
    void MapInit()
    {
        g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPreTraceAttack, @zombie_uncrab::MonsterPreTraceAttack );
        g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPreKilled, @zombie_uncrab::MonsterPreKilled );
    }

    HookReturnCode MonsterPreTraceAttack( TraceInfo@ pInfo )
    {
        CBaseMonster@ pVictim = cast<CBaseMonster@>( pInfo.pVictim );
        CBaseEntity@ pInflictor = pInfo.pInflictor;
        float v_fDamage = pInfo.flDamage;
        Vector v_VecDir = pInfo.vecDir;
        TraceResult v_ptr = pInfo.ptr;
        int v_bitsDamageType = pInfo.bitsDamageType;

        if( pVictim !is null && pVictim.GetClassname().StartsWith( 'monster_zombie' ) && string( pVictim.pev.model ).EndsWith( '_uncrab.mdl' ) )
        {
            if( !pVictim.GetCustomKeyvalues().HasKeyvalue( '$f_zombie_uncrab' ) )
            {
                g_EntityFuncs.DispatchKeyValue( pVictim.edict(), '$f_zombie_uncrab', g_EngineFuncs.CVarGetFloat( 'sk_headcrab_health' ) );
            }

            if( v_ptr.iHitgroup == 1 )
            {
                float m_fCrabHealth = atof( pVictim.GetCustomKeyvalues().GetKeyvalue( '$f_zombie_uncrab' ).GetString() );

                g_EntityFuncs.DispatchKeyValue( pVictim.edict(), '$f_zombie_uncrab', m_fCrabHealth - v_fDamage );
            }
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode MonsterPreKilled( CBaseMonster@ pMonster, entvars_t@ pevAttacker, int& out iGib )
    {
        if( !pMonster.HasMemory( bits_MEMORY_KILLED ) && pMonster !is null && pMonster.GetClassname().StartsWith( 'monster_zombie' ) && string( pMonster.pev.model ).EndsWith( '_uncrab.mdl' ) )
        {
            float m_fCrabHealth = atof( pMonster.GetCustomKeyvalues().GetKeyvalue( '$f_zombie_uncrab' ).GetString() );

            if( m_fCrabHealth > 0 )
            {
                pMonster.pev.body = 1;
                pMonster.pev.solid = SOLID_NOT;

                mk.EntityFuncs.CreateEntity
                (
                    {
                        { 'origin', Vector( pMonster.pev.origin + pMonster.pev.view_ofs ).ToString() },
                        { 'classify', string( pMonster.Classify() ) },
                        { 'classname', 'monster_headcrab' },
                        { 'angles', pMonster.pev.angles.ToString() },
                        { 'health', string( m_fCrabHealth ) }
                    }
                ).pev.velocity.z = 500;

                iGib = GIB_NEVER;
            }
        }
        return HOOK_CONTINUE;
    }
}