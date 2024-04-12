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

namespace svenfixes
{
    namespace satchel_stun
    {
        void PluginInit()
        {
            InitHook( 'OnPlayerAttack', 'satchel_stun' );
            InitHook( 'OnMapInit', 'satchel_stun' );
            InitHook( 'OnThink', 'satchel_stun' );
        }

        void OnMapInit()
        {
            g_CustomEntityFuncs.RegisterCustomEntity( 'svenfixes::satchel_stun::CSatchelCharge', 'svenfixes_satchel' );
            g_Game.PrecacheOther( 'svenfixes_satchel' );
        }

        float time;

        void OnThink()
        {
            if( g_Engine.time > time && g_CustomEntityFuncs.IsCustomEntity( 'svenfixes_satchel' ) )
            {
                CBaseEntity@ pGrenade = null;

                while( ( @pGrenade = g_EntityFuncs.FindEntityByClassname( pGrenade, 'grenade' ) ) !is null  )
                {
                    g_EntityFuncs.DispatchKeyValue( pGrenade.edict(), 'is_not_revivable', '1' );
                }

                time = g_Engine.time + 5.0f;
            }
        }

        void OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, ATTACK AttackMode )
        {
            if( pWeapon.GetClassname() == 'weapon_satchel' && g_CustomEntityFuncs.IsCustomEntity( 'svenfixes_satchel' ) )
            {
                if( AttackMode == ATTACK::PRIMARY )
                {
                    CBaseEntity@ pSatchels = null;

                    while( ( @pSatchels = g_EntityFuncs.FindEntityByClassname( pSatchels, 'svenfixes_satchel' ) ) !is null )
                    {
                        CBaseEntity@ pOwner = g_EntityFuncs.Instance( pSatchels.pev.owner );

                        if( pOwner !is null && pOwner is pPlayer )
                        {
                            pSatchels.Use( null, null, USE_TOGGLE, 0.0f );
                        }
                    }
                }
                else
                {
                    CBaseEntity@ pSatchel = g_EntityFuncs.FindEntityInSphere( null, pPlayer.pev.origin, 100, 'monster_satchel', 'classname' );

                    if( pSatchel !is null )
                    {
                        CBaseEntity@ pOwner = g_EntityFuncs.Instance( pSatchel.pev.owner );

                        if( pOwner !is null )
                        {
                            CBaseEntity@ lpSatchel = g_EntityFuncs.Create( 'svenfixes_satchel', pSatchel.pev.origin, pSatchel.pev.angles, false, pOwner.edict() );

                            if( lpSatchel !is null )
                            {
                                lpSatchel.pev.velocity = pSatchel.pev.velocity;

                                g_EntityFuncs.Remove( pSatchel );
                            }
                        }
                    }
                }
            }
        }

        class CSatchelCharge : ScriptBasePlayerAmmoEntity
        {
            void Spawn()
            {
                Precache();

                // motor
                self.pev.movetype = MOVETYPE_BOUNCE;
                self.pev.solid = SOLID_BBOX;

                g_EntityFuncs.SetModel( self, "models/w_satchel.mdl" );
                g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) ); // Uses point-sized, and can be stepped over

                SetTouch( TouchFunction( SatchelSlide ) );
                SetThink( ThinkFunction( SatchelThink ) );
                SetUse( UseFunction( Use ) );
                self.pev.nextthink = g_Engine.time + 0.1;

                self.pev.gravity = 0.5;
                self.pev.friction = 0.8;

                self.pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_satchel' );
                self.pev.sequence = 1;
            }

            void Precache()
            {
                g_Game.PrecacheModel( "models/w_satchel.mdl" );
                g_SoundSystem.PrecacheSound( "weapons/g_bounce1.wav" );
                g_SoundSystem.PrecacheSound( "weapons/g_bounce2.wav" );
                g_SoundSystem.PrecacheSound( "weapons/g_bounce3.wav" );
            }

            void SatchelSlide( CBaseEntity@ pOther )
            {
                // don't hit the guy that launched this grenade
                CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
                if ( pOther == pOwner )
                    return;

                pev.gravity = 1; // normal gravity now

                // HACKHACK - on ground isn't always set, so look for ground underneath
                TraceResult tr;
                g_Utility.TraceLine( pev.origin, pev.origin - Vector( 0, 0, 10 ), ignore_monsters, self.edict(), tr );

                if ( tr.flFraction < 1.0 )
                {
                    // add a bit of static friction
                    pev.velocity = pev.velocity * 0.95;
                    pev.avelocity = pev.avelocity * 0.9;
                }

                // play sliding sound, volume based on velocity
                int bCheck = pev.flags;
                if ( ( bCheck &= FL_ONGROUND ) != FL_ONGROUND && pev.velocity.Length2D() > 10 )
                {
                    CSoundEnt@ pSound = GetSoundEntInstance();
                    pSound.InsertSound( bits_SOUND_PLAYER, pev.origin, 400, 0.3, self );
                    g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/g_bounce" + string( Math.RandomLong( 1, 3 ) ) + ".wav", 1, ATTN_NORM );
                }
            }

            void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
            {
                if( pActivator !is null && pActivator is g_EntityFuncs.Instance( pev.owner ) )
                {
                    CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

                    CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon>( pPlayer.HasNamedPlayerItem( 'weapon_satchel' ) );

                    if( pPlayer !is null && pWeapon !is null )
                    {
                        int Satchels = 0;

                        CBaseEntity@ pSatchels = null;

                        while( ( @pSatchels = g_EntityFuncs.FindEntityByClassname( pSatchels, self.GetClassname() ) ) !is null )
                        {
                            if( pSatchels !is self && g_EntityFuncs.Instance( pSatchels.pev.owner ) is pPlayer )
                            {
                                Satchels++;
                            }
                        }

                        switch( Satchels )
                        {
                            case 0:
                            {
                                pPlayer.RemovePlayerItem( pWeapon );
                                pPlayer.GiveNamedItem( 'weapon_satchel', 0, int( 1 + pPlayer.m_rgAmmo( pWeapon.PrimaryAmmoIndex() ) ) );
                                pPlayer.SelectItem( 'weapon_satchel' );
                                break;
                            }

                            default:
                            {
                                pPlayer.GiveAmmo( 1, 'Satchel Charge', pPlayer.GetMaxAmmo( 'Satchel Charge' ), true );
                                break;
                            }
                        }

                        Mikk.PlayerFuncs.ClientCommand( 'spk "items/gunpickup2.wav"', pPlayer );

                        g_EntityFuncs.Remove( self );
                    }
                }
                else
                {
                    CSoundEnt@ pSound = GetSoundEntInstance();
                    pSound.InsertSound( bits_SOUND_DANGER, pev.origin, 400, 0.3, self );

                    TraceResult tr;
                    Vector vecSpot; // trace starts here!

                    vecSpot = pev.origin + Vector( 0, 0, 8 );
                    g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ), ignore_monsters, self.edict(), tr );

                    g_EntityFuncs.CreateExplosion( tr.vecEndPos, Vector( 0, 0, -90 ), pev.owner, int( pev.dmg ), false );
                    g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );

                    g_EntityFuncs.Remove( self );
                }
            }

            void SatchelThink()
            {
                switch( self.pev.waterlevel )
                {
                    case 0:
                    {
                        self.pev.movetype = MOVETYPE_BOUNCE;
                        break;
                    }
                    case 3:
                    {
                        self.pev.movetype = MOVETYPE_FLY;
                        self.pev.velocity = self.pev.velocity * 0.8;
                        self.pev.avelocity = self.pev.avelocity * 0.9;
                        self.pev.velocity.z += 8;
                        break;
                    }
                    default:
                    {
                        if( self.pev.velocity == g_vecZero )
                        {
                            self.pev.solid = SOLID_NOT;
                            SetTouch( null );
                            SetThink( null );
                        }
                        else
                        {
                            self.pev.velocity.z -= 8;
                        }
                        break;
                    }
                }
                self.pev.nextthink = g_Engine.time + 0.1f;
            }
        }
    }
}
