namespace config_classic_mode
{
    void Register()
    {
        g_Util.ScriptAuthor.insertLast
        (
            "Script: config_classic_mode\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Entity that customize classic mode for monsters, models and items that the game doesn't support.\n"
        );

        //We want classic mode to be enabled here
        g_ClassicMode.EnableMapSupport();
        g_CustomEntityFuncs.RegisterCustomEntity( "config_classic_mode::config_classic_mode", "config_classic_mode" );
    }

    enum config_classic_mode_flags
    {
        SF_CCM_RESTART_NOW = 1 << 0
    }

    class config_classic_mode : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string target_toggle, target_failed, target_enabled, target_disabled;

        dictionary g_ItemMapping;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues( szKey, szValue );

            g_ItemMapping[ szKey ] = szValue;

            if( szKey == "target_toggle" )
            {
                target_toggle = szValue;
            }
            else if( szKey == "target_failed" )
            {
                target_failed = szValue;
            }
            else if( szKey == "target_enabled" )
            {
                target_enabled = atof( szValue );
            }
            else if( szKey == "target_disabled" )
            {
                target_disabled = atof( szValue );
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
                g_Util.DebugMessage( "[config_classic_mode]" );
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_ItemMapping[ Key ] );

                    if( string( Key ).StartsWith( "models/" ) )
                    {
                        g_Game.PrecacheModel( Value );
                        g_Util.DebugMessage( "Precached model '" + Value + "'" );
                    }
                }
            }

            BaseClass.Precache();
        }

        void Spawn()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                g_Util.DebugMessage( "[config_classic_mode]" );
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string Key = string( strKeyValues[ui] );
                    string Value = string( g_ItemMapping[ Key ] );

                    if( string( Key ).StartsWith( "models/" ) )
                    {
                        dictionary g_changemodel;
                        g_changemodel [ "target" ] = "!activator";
                        g_changemodel [ "model" ] = Value;
                        g_changemodel [ "targetname" ] =  "CCM_" + Key;
                        g_EntityFuncs.CreateEntity( "trigger_changemodel", g_changemodel, true );
                        g_Util.DebugMessage( "Created trigger_changemodel replaces '" + Key + "' -> '" + Value + "'" );
                    }
                }
            }

            g_Util.Trigger( ( g_ClassicMode.IsEnabled() ) ? target_enabled : target_disabled , self, self, USE_TOGGLE, delay );

            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }
            else
            if( g_ClassicMode.IsEnabled() && useType == USE_ON || !g_ClassicMode.IsEnabled() && useType == USE_OFF )
            {
                g_Util.Trigger( target_failed, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
                return;
            }

            g_ClassicMode.SetShouldRestartOnChange( ( self.pev.SpawnFlagBitSet( SF_CCM_RESTART_NOW ) ) ? true : false );

            g_ClassicMode.Toggle();

            g_Util.Trigger( target_toggle, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
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

                    while( ( @pEntity = g_EntityFuncs.FindEntityByString( pEntity, "model", Key ) ) !is null )
                    {
                        if( pEntity !is null && g_Util.GetCKV( pEntity, "$i_classic_mode_ignore" ) != "1" )
                        {
                            g_Util.DebugMessage( "[config_classic_mode] replaced '" + string( pEntity.pev.model ) + "' -> '" + string( Value ) + "'" );
                            g_Util.Trigger( "CCM_" + Key, pEntity, self, USE_ON, 0.0f );
                        }
                    }

                    if(string( Key ).StartsWith( 'weapon') 
                    or string( Key ).StartsWith( 'item_' )
                    or string( Key ).StartsWith( 'ammo_' ) )
                    {
                        while( ( @pWeapon = g_EntityFuncs.FindEntityByString( pWeapon, "classname", Key ) ) !is null )
                        {
                            if( pWeapon !is null )
                            {
                                g_Util.DebugMessage( "[config_classic_mode] replaced '" + string( pWeapon.pev.classname ) + "' -> '" + string( Value ) + "'" );
                                g_EntityFuncs.Create( Value, pWeapon.pev.origin, pWeapon.pev.angles, false);
                                g_EntityFuncs.Remove( pWeapon );
                            }
                        }
                    }
                }
            }
            self.pev.nextthink = g_Engine.time + self.pev.health + 0.1f;
        }
    }
}// end namespace