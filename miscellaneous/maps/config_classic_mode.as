#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include 'utils/ScriptBaseCustomEntity'

namespace config_classic_mode
{
    void Register()
    {
        g_Util.CustomEntity( 'config_classic_mode' );

        g_ClassicMode.EnableMapSupport();

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'config_classic_mode' ) +
            g_ScriptInfo.Description( 'Allow to configurate classic mode for models that the game does not support' ) +
            g_ScriptInfo.Wiki( 'config_classic_mode' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum config_classic_mode_spawnflags
    {
        RESTART_NOW = 1,
        FORCE_REMAP = 2
    }

    class config_classic_mode : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string
        m_iszTargetOnToggle,
        m_iszTargetOnFail,
        m_iszTargetOnEnable,
        m_iszTargetOnDisable,
        m_iszConfigFile;

        private float m_iThinkTime;

        dictionary g_KeyValues;

        array<ItemMapping@> g_ItemMappings;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues( szKey, szValue );

            g_KeyValues[ szKey ] = szValue;

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
            else if( szKey == 'm_iszConfigFile' )
            {
                m_iszConfigFile = szValue;
            }
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_KeyValues.getKeys(); }
        }

        void Precache()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_KeyValues[ Key ] );

                    if( Key.StartsWith( 'models/' ) )
                    {
                        g_Game.PrecacheModel( Value );
                        g_Util.Debug( '[config_classic_mode] Precached model "' + Value + '"' );
                    }
                }
            }

            BaseClass.Precache();
        }

        void PreSpawn()
        {
            if( !m_iszConfigFile.IsEmpty() )
            {
                g_KeyValues = g_Util.GetKeyAndValue( 'scripts/maps/' + m_iszConfigFile, g_KeyValues );
            }

            BaseClass.PreSpawn();
        }

        void InsertItemMapping( const string iszOldWeapon, const string iszNewWeapon )
        {
            g_ItemMappings.insertLast( ItemMapping( iszOldWeapon, iszNewWeapon ) );
        }

        void Spawn()
        {
            if( g_Util.GetNumberOfEntities( self.GetClassname() ) > 1 )
            {
                g_Util.Debug( self.GetClassname() + '[config_classic_mode] WARNING! There is more than one config_classic_mode entity in this map!.' );
            }

            // Sadly this doesn't change the world's weapons, idk why but it only changes Player's inventory given from CFG x[
            g_ClassicMode.ForceItemRemap( spawnflag( FORCE_REMAP ) );

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( g_KeyValues[ Key ] );

                if( g_ClassicMode.IsEnabled() )
                {
                    if( Key.StartsWith( 'models/' ) )
                    {
                        dictionary g_changemodel;
                        g_changemodel [ 'target' ] = '!activator';
                        g_changemodel [ 'model' ] = Value;
                        g_changemodel [ 'targetname' ] =  'CCM_' + Key;
                        g_EntityFuncs.CreateEntity( 'trigger_changemodel', g_changemodel, true );
                        g_Util.Debug( '[config_classic_mode] Created trigger_changemodel replaces "' + Key + '" -> "' + Value + '"' );
                    }
                }

                if( Key.StartsWith( 'weapon_' ) && Value.StartsWith( 'weapon_' ) )
                {
                    InsertItemMapping( Key, Value );
                    g_Util.Debug( '[config_classic_mode] Remapped "' + Key + '" -> "' + Value + '"' );
                }
            }
            g_ClassicMode.SetItemMappings( @g_ItemMappings );

            g_Util.Trigger( ( g_ClassicMode.IsEnabled() ) ? m_iszTargetOnEnable : m_iszTargetOnDisable , self, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );

            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            m_UTLatest = useType;
            if( IsLockedByMaster() )
            {
                return;
            }
            else if( g_ClassicMode.IsEnabled() && useType == USE_ON || !g_ClassicMode.IsEnabled() && useType == USE_OFF )
            {
                g_Util.Trigger( m_iszTargetOnFail, ( pActivator !is null ) ? pActivator : self, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
                return;
            }

            g_ClassicMode.SetShouldRestartOnChange( spawnflag( RESTART_NOW ) );

            g_ClassicMode.Toggle();

            g_Util.Trigger( m_iszTargetOnToggle, ( pActivator !is null ) ? pActivator : self, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
        }

        void Think()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_KeyValues[ Key ] );

                    CBaseEntity@ pEntity = null;
                    CBaseEntity@ pWeapon = null;

                    while( ( @pEntity = g_EntityFuncs.FindEntityByString( pEntity, 'model', Key ) ) !is null )
                    {
                        if( pEntity !is null && atoi( g_Util.CKV( pEntity, '$i_classic_mode_ignore' ) ) != 1 )
                        {
                            g_Util.Debug( '[config_classic_mode] replaced "' + string( pEntity.pev.model ) + "' -> '" + string( Value ) + '"' );
                            g_Util.Trigger( 'CCM_' + Key, pEntity, self, USE_ON, 0.0f );
                        }
                    }
                }
            }
            self.pev.nextthink = g_Engine.time + m_iThinkTime + 0.1f;
        }
    }
}
