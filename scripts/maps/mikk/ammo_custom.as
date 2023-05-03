#include 'utils/customentity'
namespace ammo_custom
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'ammo_custom::ammo_custom','ammo_custom' );
        g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, PlayerKilled );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'ammo_custom' ) +
            g_ScriptInfo.Description( 'Item that will give a certain ammout of bullets. and can be set with a limited collected times per players individualy' ) +
            g_ScriptInfo.Wiki( 'ammo_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum ammo_custom_spawnflags
    {
        RESTORE_COUNT = 64,
        TOUCH_ONLY = 128,
        USE_ONLY = 256,
        ONLY_IN_LOS = 512,
        DISABLE_RESPAWN = 1024
    }

    HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
    {
        if( pPlayer !is null )
        {
            CBaseEntity@ ammo = null;
            while( ( @ammo = g_EntityFuncs.FindEntityByClassname( ammo, "ammo_custom" ) ) !is null )
            {
                if( ammo !is null && ammo.pev.SpawnFlagBitSet( RESTORE_COUNT ) )
                {
                    ammo.Use( pPlayer, pPlayer, USE_OFF, 0.0f );
                }
            }
        }
        return HOOK_CONTINUE;
    }

    class ammo_custom : ScriptBasePlayerAmmoEntity, ScriptBaseCustomEntity
    {
        private string GetName(){return string(self.pev.targetname);}
        private string EntIndex(){return string( 'ammo_custom_' + self.entindex() );}
        private bool PlayerAble(CBaseEntity@ p){ return (p.IsPlayer() && p !is null && p.IsAlive() ? true : false );}

        private string
        m_iszTargetOnCount,
        m_iszPickupSound,
        m_iszAmmoName = 'buckshot';

        private int m_iAmmoCount = 1;
        private float m_fDelayRestore;

        private string[][] Weapons = 
        {
            {'Satchel Charge', 'weapon_satchel'},
            {'Trip Mine', 'weapon_tripmine'},
            {'Hand Grenade', 'weapon_handgrenade'},
            {'snarks', 'weapon_snark'}
        };

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == 'm_iszAmmoName' || szKey == 'am_name' )
            {
                m_iszAmmoName = szValue;
            }
            else if( szKey == 'm_iszPickupSound' || szKey == 'p_sound' )
            {
                m_iszPickupSound = szValue;
            }
            else if( szKey == 'm_iszTargetOnCount' )
            {
                m_iszTargetOnCount = szValue;
            }
            else if( szKey == 'm_iAmmoCount' || szKey == 'am_give' )
            {
                m_iAmmoCount = atoi( szValue );
            }
            else if( szKey == 'm_fDelayRestore' )
            {
                m_fDelayRestore = atof( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Spawn()
        {
            Precache();
            CustomModelSet();

            self.pev.targetname = ( GetName().IsEmpty() ? EntIndex() : GetName() );

            string renderamt = g_Util.GetCKV( self, '$i_renderamt' );
            string rendermode = g_Util.GetCKV( self, '$i_rendermode' );
            string renderfx = g_Util.GetCKV( self, '$i_renderfx' );
            string rendercolor = g_Util.GetCKV( self, '$s_rendercolor' );

            dictionary g_Render;
            g_Render[ 'spawnflags' ] = '64';
            g_Render[ 'target' ] = GetName();
            g_Render[ 'renderamt' ] = ( renderamt.IsEmpty() ? '100' : renderamt );
            g_Render[ 'rendermode' ] = ( rendermode.IsEmpty() ? '2' : rendermode );
            g_Render[ 'renderfx' ] = ( renderfx.IsEmpty() ? '0' : renderfx );
            g_Render[ 'rendercolor' ] = ( rendercolor.IsEmpty() ? '0 0 0' : rendercolor );
            g_Render[ 'targetname' ] = GetName() + '_FX';
            g_EntityFuncs.CreateEntity( 'env_render_individual', g_Render );

            BaseClass.Spawn();
        }
        
        void Precache()
        {
            CustomModelPrecache();

            if( !m_iszPickupSound.IsEmpty() )
            {
                g_SoundSystem.PrecacheSound( m_iszPickupSound );
                g_Game.PrecacheGeneric( 'sound/' + m_iszPickupSound );
            }
            BaseClass.Precache();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float fldelay )
        {
            if( PlayerAble( pActivator ) )
            {
                if( useType == USE_OFF )
                {
                    g_Util.SetCKV( pActivator, '$i_' + EntIndex(), 0 );
                    g_Util.Trigger( GetName() + '_FX', pActivator, pActivator, USE_OFF, 0.0f );
                    return;
                }

                if( !spawnflag( TOUCH_ONLY ) )
                {
                    AddAmmo( pActivator );
                }
            }
        }

        void Touch( CBaseEntity@ pOther )
        {
            if( PlayerAble( pOther ) && !spawnflag( USE_ONLY ) )
            {
                AddAmmo( pOther );
            }
        }

        void Restore( CBaseEntity@ pPlayer )
        {
            int iValue = atoi( g_Util.GetCKV( pPlayer, '$i_' + EntIndex() ) );
            g_Util.SetCKV( pPlayer, '$i_' + EntIndex(), iValue - 1 );
            g_Util.Trigger( GetName() + '_FX', pPlayer, pPlayer, USE_OFF, 0.0f );
        }

        bool CanPick( CBaseEntity@ pPlayer )
        {
            if( spawnflag( ONLY_IN_LOS ) && !pPlayer.FVisibleFromPos( pPlayer.pev.origin, self.Center() ) )
            {
                return false;
            }

            int iValue = atoi( g_Util.GetCKV( pPlayer, '$i_' + EntIndex() ) );
            int iWait = int( wait - wait - wait );

            if( !m_iszMaster.IsEmpty() && g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
            {
                return true;
            }
            if( self.pev.frags > 0 && iValue < self.pev.frags )
            {
                g_Util.SetCKV( pPlayer, '$i_' + EntIndex(), iValue + 1 );

                if( m_fDelayRestore > 0.0f )
                {
                    g_Scheduler.SetTimeout( @this, "Restore", m_fDelayRestore, @pPlayer );
                }
                return true;
            }
            return false;
        }

        bool AddAmmo( CBaseEntity@ pOther ) 
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

            if( !PlayerAble( pPlayer ) )
            {
                return false;
            }

            g_Util.Trigger( GetName() + '_FX', pPlayer, pPlayer, ( CanPick( pPlayer ) ? USE_OFF : USE_ON ), 0.0f );

            if( CanPick( pPlayer ) )
            {
                for( uint i = 0; i < Weapons.length(); i++ )
                {
                    if( m_iszAmmoName == Weapons[i][0] )
                    {
                        if( cast<CBasePlayer@>( pPlayer ).HasNamedPlayerItem( Weapons[i][1] ) is null )
                        {
                            CBaseEntity@ FakeWeapon = g_EntityFuncs.Create( Weapons[i][1], pPlayer.pev.origin, Vector( 0, 0, 0 ), false );

                            FakeWeapon.pev.spawnflags = 1024;
                            cast<CBasePlayerWeapon@>( FakeWeapon ).m_iDefaultAmmo = m_iAmmoCount;
                            return Pickup();
                        }
                    }
                }

                if( m_iszAmmoName == 'flashlight' )
                {
                    if( pPlayer.m_iFlashBattery < 100 )
                    {
                        float flash = pPlayer.m_iFlashBattery + m_iAmmoCount;

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
                        return Pickup( pPlayer );
                    }
                }
                else if( m_iszAmmoName == 'battery' && pPlayer.pev.armorvalue < pPlayer.pev.armortype )
                {
                    pPlayer.pev.armorvalue += m_iAmmoCount;
                    pPlayer.pev.armorvalue = Math.min( pPlayer.pev.armorvalue, 100 );
                    return Pickup();
                }
                else if( m_iszAmmoName == 'healthkit' && pPlayer.pev.health < pPlayer.pev.max_health )
                {
                    pPlayer.TakeHealth( m_iAmmoCount, DMG_GENERIC );
                    return Pickup( pPlayer );
                }
                else if( m_iszAmmoName == 'air' )
                {
                    pPlayer.pev.air_finished = g_Engine.time + m_iAmmoCount;
                    return Pickup();
                }
                else if( pPlayer.GiveAmmo( m_iAmmoCount, m_iszAmmoName, pPlayer.GetMaxAmmo( m_iszAmmoName ) ) != -1 )
                {
                    return Pickup();
                }
            }
            g_Util.Trigger( m_iszTargetOnCount, pPlayer, self, USE_TOGGLE, 0.0f );
            return false;
        }

        bool Pickup( CBasePlayer@ &in pPlayer = null )
        {
            if( !m_iszPickupSound.IsEmpty() )
            {
                g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, m_iszPickupSound, 1, ATTN_NORM );

                if( m_iszAmmoName == 'battery' )
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
                else if( m_iszAmmoName == 'healthkit' )
                {
                    NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
                        message.WriteString( 'item_healthkit' );
                    message.End();
                }
            }
            return true;
        }
    }
}