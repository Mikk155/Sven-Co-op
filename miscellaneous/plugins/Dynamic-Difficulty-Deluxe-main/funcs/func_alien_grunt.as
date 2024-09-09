DDDAlienGrunt func_alien_grunt;

final class DDDAlienGrunt
{
    int enable_punch = 1;
    int diff_punch = 10;

    int enable_stun = 1;
    int diff_stun = 20;

    int enable_berserk = 1;
    int diff_berserk = 1;
    float berserk;

    void UpdateDifficulty()
    {
        if( active( enable_berserk, diff_berserk ) )
        {
            g_EngineFuncs.CVarSetFloat( 'sk_agrunt_melee_engage_distance', AgruntBerserk() );
        }
    }

    void MapInit()
    {
        berserk = g_EngineFuncs.CVarGetFloat( 'sk_agrunt_melee_engage_distance' );
    }

    bool active( int tu, int td )
    {
        return ( tu == 1 && g_DDD.diff >= td );
    }

    const int AgruntBerserk()
    {
        return int( berserk + ( g_DDD.diff ) * 5 );
    }

    bool stun( CBaseEntity@ pInflictor )
    {
        return ( active( enable_stun, diff_stun ) && pInflictor.GetClassname() == 'hornet' );
    }

    void stun( CBasePlayer@ pPlayer, CBaseEntity@ pInflictor )
    {
        g_PlayerFuncs.ScreenFade( pPlayer, Vector( 255, 200, 0 ), 0.5f, 0.5f, 255, FFADE_IN | FFADE_MODULATE );
        pPlayer.pev.velocity.x = pInflictor.pev.velocity.x / 4;
        pPlayer.pev.velocity.y = pInflictor.pev.velocity.y / 4;
    }

    bool punch( CBasePlayer@ pPlayer, CBaseEntity@ pInflictor )
    {
        return ( active( enable_punch, diff_punch ) && pInflictor.GetClassname() == 'monster_alien_grunt' );
    }

    void punchpush( CBasePlayer@ pPlayer, CBaseEntity@ pInflictor )
    {
        pPlayer.pev.velocity.z = 100;

        Vector angThrow = pInflictor.pev.v_angle + pInflictor.pev.punchangle;
        
        float flVel = ( 90 - angThrow.x ) * 4;

        Vector vecThrow = g_Engine.v_forward * flVel + pPlayer.pev.velocity;
        pPlayer.pev.velocity = vecThrow;

        pPlayer.pev.punchangle.x -= 4.0;
        pPlayer.pev.punchangle.z -= 2.0f;
    }
}