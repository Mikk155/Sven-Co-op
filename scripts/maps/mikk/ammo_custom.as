#include 'utils'
#include 'utils/customentity'

namespace ammo_custom
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'ammo_custom::ammo_custom','ammo_custom' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'ammo_custom' ) +
            g_ScriptInfo.Description( 'Item that will give a certain ammout of bullets. and can be set with a limited collected times per players individualy' ) +
            g_ScriptInfo.Wiki( 'ammo_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    class ammo_custom : ScriptBasePlayerAmmoEntity, ScriptBaseCustomEntity
    {
        private string p_sound;

        private string am_name = 'buckshot';

        private string[][] Weapons = 
        {
            {'Satchel Charge', 'weapon_satchel'},
            {'Trip Mine', 'weapon_tripmine'},
            {'Hand Grenade', 'weapon_handgrenade'},
            {'snarks', 'weapon_snark'}
        };

        private int am_give = 1;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == 'am_name' )
            {
                am_name = szValue;
            }
            else if( szKey == 'p_sound' )
            {
                p_sound = szValue;
            }
            else if( szKey == 'am_give' )
            {
                am_give = atoi( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Spawn()
        {
            CustomModelSet();

            if( self.pev.frags > 0 )
            {
                if( string( self.pev.targetname ).IsEmpty() )
                {
                    self.pev.targetname = 'ammocustom_' + self.entindex();
                }

                dictionary g_keyvalues =
                {
                    { 'spawnflags', '64' },
                    { 'target', string( self.pev.targetname ) },
                    { 'renderamt', '0' },
                    { 'rendermode', '5' },
                    { 'targetname', string( self.pev.targetname ) + '_FX' }
                };

                g_EntityFuncs.CreateEntity( 'env_render_individual', g_keyvalues );
            }

            Precache();
            BaseClass.Spawn();
        }
        
        void Precache()
        {
            CustomModelPrecache();

            if( !p_sound.IsEmpty() )
            {
                g_SoundSystem.PrecacheSound( p_sound );
                g_Game.PrecacheGeneric( 'sound/' + p_sound );
            }
            BaseClass.Precache();
        }

        bool AddAmmo( CBaseEntity@ pOther ) 
        {
            if( pOther is null || IsLockedByMaster( pOther ) )
            {
                return false;
            }

            int iValue = atoi( g_Util.GetCKV( pOther, '$i_ammo_custom' + self.entindex() ) );

            if( iValue < self.pev.frags || self.pev.frags == 0 )
            {
                for(uint i = 0; i < Weapons.length(); i++)
                {
                    if( am_name == Weapons[i][0] )
                    {
                        if( cast<CBasePlayer@>( pOther ).HasNamedPlayerItem( Weapons[i][1] ) is null )
                        {
                            CBaseEntity@ FakeWeapon = g_EntityFuncs.Create( Weapons[i][1], pOther.pev.origin, Vector( 0, 0, 0 ), false );

                            FakeWeapon.pev.spawnflags = 1024;
                            cast<CBasePlayerWeapon@>( FakeWeapon ).m_iDefaultAmmo = am_give;
                            Pickup();
                        }
                    }
                }


                CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

                if( pPlayer is null )
                {
                    return false;
                }

                if( am_name == 'flashlight' )
                {
                    if( pPlayer.m_iFlashBattery < 100 )
                    {
                        float flash = pPlayer.m_iFlashBattery + am_give;

                        if( flash >= 100 )
                        {
                            pPlayer.m_iFlashBattery = 100;
                            g_Util.SetCKV( pPlayer, '$f_pf_flashlight', 100.0 );
                        }
                        else
                        {
                            pPlayer.m_iFlashBattery = int( flash );
                            g_Util.SetCKV( pPlayer, '$f_pf_flashlight', flash );
                        }
                        Pickup();
                    }
                }
                else if( am_name == 'battery' )
                {
                    if( pPlayer.pev.armorvalue < pPlayer.pev.armortype )
                    {
                        pPlayer.pev.armorvalue += am_give;
                        pPlayer.pev.armorvalue = Math.min( pPlayer.pev.armorvalue, 100 );

                        if( !p_sound.IsEmpty() )
                        {
                            NetworkMessage msg( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
                                msg.WriteString( 'item_battery' );
                            msg.End();

                            int pct;
                            pct = int( float( pPlayer.pev.armorvalue * 100.0 ) *  (1.0 / 100 ) + 0.5 );
                            pct = ( pct / 5 );
                            if ( pct > 0 )
                                pct--;

                            pPlayer.SetSuitUpdate( '!HEV_' + pct + 'P', false, 30 );

                        }
                        Pickup();
                    }
                }
                else if( am_name == 'healthkit' )
                {
                    if( pPlayer.pev.health < pPlayer.pev.max_health )
                    {
                        pPlayer.TakeHealth( am_give, DMG_GENERIC );

                        if( !p_sound.IsEmpty() )
                        {
                            NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
                                message.WriteString( 'item_healthkit' );
                            message.End();
                        }

                        Pickup();
                    }
                }
                else if( am_name == 'air' )
                {
                    pPlayer.pev.air_finished = g_Engine.time + am_give;
                    Pickup();
                }
                else if( pPlayer.GiveAmmo( am_give, am_name, pPlayer.GetMaxAmmo( am_name ) ) != -1 )
                {
                    if( self.pev.frags > 0 )
                    {
                        g_Util.SetCKV( pPlayer, '$i_ammo_custom' + self.entindex(), iValue + 1 );
                        
                        if( iValue == self.pev.frags - 1 )
                        {
                            g_Util.Trigger( string( self.pev.targetname ) + '_FX', pPlayer, pPlayer, USE_ON, 0.0f );
                            g_Util.Debug( '[ammo_custom] Player "' + string( pPlayer.pev.netname ) + '" can not take more ammo from this item.' );
                        }
                    }
                    Pickup();
                }
            }
            return false;
        }
        
        bool Pickup()
        {
            if( !p_sound.IsEmpty() )
            {
                g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, p_sound, 1, ATTN_NORM );
            }
            return true;
        }
    }
}