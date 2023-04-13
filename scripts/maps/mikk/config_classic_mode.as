#include 'utils'

bool config_classic_mode_register = g_Util.CustomEntity( 'config_classic_mode::config_classic_mode','config_classic_mode' );
bool config_classic_mode_enable = config_classic_mode_support();
bool config_classic_mode_support()
{
    g_ClassicMode.EnableMapSupport();
    return true;
}

namespace config_classic_mode
{
    enum config_classic_mode_spawnflags
    {
        RESTART_NOW = 1
    }

    class config_classic_mode : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string
        m_iszTargetOnToggle,
        m_iszTargetOnFail,
        m_iszTargetOnEnable,
        m_iszTargetOnDisable;

        private float m_iThinkTime;

        dictionary g_ItemMapping;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues( szKey, szValue );

            g_ItemMapping[ szKey ] = szValue;

            if( szKey == 'm_iszTargetOnToggle' )
            {
                m_iszTargetOnToggle = szValue;
            }
            else if( szKey == 'm_iszTargetOnFail' )
            {
                m_iszTargetOnFail = szValue;
            }
            else if( szKey == 'm_iszTargetOnEnable' )
            {
                m_iszTargetOnEnable = szValue;
            }
            else if( szKey == 'm_iszTargetOnDisable' )
            {
                m_iszTargetOnDisable = szValue;
            }
            else if( szKey == 'm_iThinkTime' )
            {
                m_iThinkTime = atof( szValue );
            }
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_ItemMapping.getKeys(); }
        }

        void Precache()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_ItemMapping[ Key ] );

                    if( string( Key ).StartsWith( 'models/' ) )
                    {
                        g_Game.PrecacheModel( Value );
                        g_Util.Debug( '[config_classic_mode] Precached model '' + Value + ''' );
                    }
                    else
                    {
                        g_Game.PrecacheOther( Value );
                        g_Util.Debug( '[config_classic_mode] Precached item '' + Value + ''' );
                    }
                }
            }

            BaseClass.Precache();
        }

        void Spawn()
        {
            if( g_Util.GetNumberOfEntities( self.GetClassname() ) > 1 )
            {
                g_Util.Debug( self.GetClassname() + '[config_classic_mode] Can not use more than one entity per level. Removing...' );
                g_EntityFuncs.Remove( self );
            }

            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_ItemMapping[ Key ] );

                    if( string( Key ).StartsWith( 'models/' ) )
                    {
                        dictionary g_changemodel;
                        g_changemodel [ 'target' ] = '!activator';
                        g_changemodel [ 'model' ] = Value;
                        g_changemodel [ 'targetname' ] =  'CCM_' + Key;
                        g_EntityFuncs.CreateEntity( 'trigger_changemodel', g_changemodel, true );
                        g_Util.Debug( '[config_classic_mode] Created trigger_changemodel replaces "' + Key + '" -> "' + Value + '"' );
                    }
                }
            }

            g_Util.Trigger( ( g_ClassicMode.IsEnabled() ) ? m_iszTargetOnEnable : m_iszTargetOnDisable , self, self, USE_TOGGLE, delay );

            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
            {
                return;
            }
            else
            if( g_ClassicMode.IsEnabled() && useType == USE_ON || !g_ClassicMode.IsEnabled() && useType == USE_OFF )
            {
                g_Util.Trigger( m_iszTargetOnFail, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
                return;
            }

            g_ClassicMode.SetShouldRestartOnChange( spawnflag( RESTART_NOW ) );

            g_ClassicMode.Toggle();

            g_Util.Trigger( m_iszTargetOnToggle, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
        }

        void Think()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_ItemMapping[ Key ] );

                    CBaseEntity@ pEntity = null;
                    CBaseEntity@ pWeapon = null;

                    while( ( @pEntity = g_EntityFuncs.FindEntityByString( pEntity, 'model', Key ) ) !is null )
                    {
                        if( pEntity !is null && g_Util.GetCKV( pEntity, '$i_classic_mode_ignore' ) != '1' )
                        {
                            g_Util.Debug( '[config_classic_mode] replaced '' + string( pEntity.pev.model ) + '' -> '' + string( Value ) + ''' );
                            g_Util.Trigger( 'CCM_' + Key, pEntity, self, USE_ON, 0.0f );
                        }
                    }

                    if(string( Key ).StartsWith( 'weapon_' )
                    or string( Key ).StartsWith( 'item_' )
                    or string( Key ).StartsWith( 'ammo_' ) )
                    {
                        while( ( @pWeapon = g_EntityFuncs.FindEntityByString( pWeapon, 'classname', Key ) ) !is null )
                        {
                            if( pWeapon !is null && g_Util.GetCKV( pWeapon, '$i_classic_mode_ignore' ) != '1' )
                            {
                                g_Util.Debug( '[config_classic_mode] replaced '' + string( pWeapon.pev.classname ) + '' -> '' + string( Value ) + ''' );
                                g_EntityFuncs.Create( Value, pWeapon.pev.origin, pWeapon.pev.angles, false);
                                g_EntityFuncs.Remove( pWeapon );
                            }
                        }
                    }
                }
            }
            self.pev.nextthink = g_Engine.time + m_iThinkTime + 0.1f;
        }
    }
}