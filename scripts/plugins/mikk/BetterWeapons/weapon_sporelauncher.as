//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include '../../../mikk/ScriptBaseClass/CSpore'

namespace weapon_sporelauncher
{
    void PrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, json@ pJson )
    {
        if( pPlayer is null || pWeapon is null || !IsRegistered() )
            return;

        // When the fuck is this hook called
        // It's not Pre enough for stopping things from happening
        // But is also not Post enough to get the spore entity created

        //pSpore.pev.fuser1 = pJson[ 'Spore Time', 10.0 ];
    }

    void TertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, json@ pJson )
    {
        if( pPlayer is null || pWeapon is null || !IsRegistered() )
            return;

        Vector vecAngles = pPlayer.pev.v_angle + pPlayer.pev.punchangle;

        Math.MakeVectors( vecAngles );

        Vector vecSrc =
            pPlayer.EarPosition() +
            g_Engine.v_forward * 16 +
            g_Engine.v_right * 8 +
            g_Engine.v_up * -8;

        vecAngles = vecAngles + pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES);

        weapon_sporelauncher::CBetterSpore::Class@ pSpore =
            weapon_sporelauncher::CBetterSpore::CreateSpore( vecSrc, vecAngles, pPlayer, SporeType::ROCKET );

        Math.MakeVectors( vecAngles );

        if( pSpore !is null )
        {
            pSpore.pev.velocity = g_Engine.v_forward * pJson[ 'Spore Speed', 300 ];
            pPlayer.SetAnimation( PLAYER_ATTACK1 );

            pWeapon.SendWeaponAnim( 5, 0, 0 );

            pSpore.pev.velocity = pSpore.pev.velocity + DotProduct( pSpore.pev.velocity, g_Engine.v_forward ) * g_Engine.v_forward;

            pWeapon.m_iClip--;

            pWeapon.m_flNextPrimaryAttack =
                pWeapon.m_flNextSecondaryAttack =
                    pWeapon.m_flNextTertiaryAttack =
                        pJson[ 'Next Attack', 1.0 ];
        }
    }

    bool IsRegistered()
    {
        return g_CustomEntityFuncs.IsCustomEntity( weapon_sporelauncher::CBetterSpore::classname );
    }

    namespace CBetterSpore
    {
        const string classname = 'bw_spore';

        void MapInit()
        {
            g_CustomEntityFuncs.RegisterCustomEntity( 'weapon_sporelauncher::CBetterSpore::Class', classname );
            g_Game.PrecacheOther( classname );
        }

        Class@ GetClass( CBaseEntity@ pEntity ) {
            return cast<Class>( CastToScriptClass( pEntity ) );
        }

        CBaseEntity@ GetEntity( Class@ pEntity ) {
            return cast<CBaseEntity>( pEntity );
        }

        class Class : CSpore::Class
        {
            void FlyThink()
            {
                const float flDelay = m_bIsAI ? 4.0 : 2.0;

                if( m_SporeType != SporeType::GRENADE || ( g_Engine.time <= m_flIgniteTime + flDelay ) )
                {
                    NetworkMessage m( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                        m.WriteByte( TE_SPRITE_SPRAY );
                        m.WriteVector( pev.origin );
                        m.WriteVector( pev.velocity.Normalize() );
                        m.WriteShort( m_iTrail );
                        m.WriteByte( 2 );
                        m.WriteByte( 20 );
                        m.WriteByte( 80 );
                    m.End();
                }
                else
                {
                    g_Scheduler.SetTimeout( this, 'IgniteThink', 0.03 );
                    return;
                }

                pev.nextthink = g_Engine.time + 0.03;
            }

            array<string> movables =
            {
                "func_pushable",
                "func_train",
                "func_tracktrain",
                "func_door",
                "func_rotating",
                "func_door_rotating",
            };

            void StickyTouch( CBaseEntity@ pOther )
            {
                pev.velocity = g_vecZero;
                pev.movetype = MOVETYPE_NONE;
                pev.solid = SOLID_NOT;

                if( pOther !is null && ( pOther.IsMonster() || pOther.IsPlayer() || movables.find( pOther.GetClassname() ) > 0 ) )
                {
                    hCopyPointer = EHandle( pOther );
                    VecOffSet = pOther.pev.origin - pev.origin;
                    // -TODO offset angles
                }
                SetThink( ThinkFunction( this.CopyThink ) );
                pev.nextthink = g_Engine.time;
            }

            EHandle hCopyPointer;
            Vector VecOffSet;

            void CopyThink()
            {
                CBaseEntity@ pOther = hCopyPointer.GetEntity();

                if( pev.fuser1 <= 0 )
                {
                    IgniteThink();
                    return;
                }

                if( pOther !is null )
                {
                    // pev.origin = pOther.pev.origin + VecOffSet;
                    g_EntityFuncs.SetOrigin( self, pOther.pev.origin - VecOffSet );
                }

                CSoundEnt@ pSound = GetSoundEntInstance();
                pSound.InsertSound( bits_SOUND_DANGER, pev.origin, int( pev.dmg / 0.4 ), 0.3, self );

                NetworkMessage m( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                    m.WriteByte( TE_SPRITE_SPRAY );
                    m.WriteVector( pev.origin );
                    m.WriteVector( pev.velocity.Normalize() );
                    m.WriteShort( m_iTrail );
                    m.WriteByte( 2 );
                    m.WriteByte( 20 );
                    m.WriteByte( 80 );
                m.End();

                pev.nextthink = g_Engine.time + 0.1;
                pev.fuser1 = pev.fuser1 - 0.1;
            }

            void Touch( CBaseEntity@ pOther )
            {
                if( m_SporeType == SporeType::GRENADE )
                {
                    MyBounceTouch(pOther);
                }
                else if( m_SporeType == SporeType::ROCKET )
                {
                    RocketTouch(pOther);
                }
                else
                {
                    StickyTouch(pOther);
                }
            }
        }

        Class@ CreateSpore( const Vector& in vecOrigin, const Vector& in vecAngles, CBaseEntity@ pOwner, int sporeType )
        {
            Class@ pSpore = GetClass( g_EntityFuncs.Create( classname, vecOrigin, g_vecZero, true ) );

            if( pSpore is null )
                return null;

            pSpore.m_SporeType = SporeType(sporeType);
            pSpore.pev.angles = vecAngles;
            @pSpore.pev.owner = pOwner.edict();
            pSpore.pev.origin = vecOrigin;
            pSpore.Spawn();

            return @pSpore;
        }
    }
}