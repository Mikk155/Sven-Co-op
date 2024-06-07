namespace BetterWeapons
{
    namespace weapon_9mmhandgun
    {
        ReflectionHook OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, int AttackMode )
        {
            if( pPlayer is null || pWeapon is null )
                return ReflectionHook::NONE;

            json js = json( pJson[ "weapon_9mmhandgun" ] );

            switch( AttackMode )
            {
                case ATTACK::SECONDARY:
                {
                    if( g_EngineFuncs.CVarGetFloat( 'weaponmode_9mmhandgun' ) == 0 && pWeapon.m_iClip > 0 )
                    {
                        Vector punchangle = Vector( js[ "punchangle" ] );

                        pPlayer.pev.punchangle.x -= punchangle.x;
                        pPlayer.pev.punchangle.z = Math.RandomFloat( -punchangle.z, punchangle.z );
                        pPlayer.pev.punchangle.y = Math.RandomFloat( -punchangle.y, punchangle.y );
                        pWeapon.m_flNextSecondaryAttack = pJson[ "weapon_9mmhandgun", {} ][ "m_flNextSecondaryAttack", 0.09 ];
                    }
                    break;
                }
            }
            return ReflectionHook::NONE;
        }
    }
}
