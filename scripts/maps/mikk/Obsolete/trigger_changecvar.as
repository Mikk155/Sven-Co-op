// Moved to config_map_cvars
#include "utils"
namespace trigger_changecvar
{
    void Register() 
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_changecvar::entity", "trigger_changecvar" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: trigger_changecvar\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Alternative to trigger_setcvar but you can set more than one cvar per entity and can return them back to normal.\n"
        );
    }

    enum spawnflags
    {
        SF_TCC_START_ON = 1 << 0
    }

    class entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        dictionary dictKeyValues;
        dictionary dictOldCvars;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            dictKeyValues[ szKey ] = szValue;
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return dictKeyValues.getKeys(); }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }

            g_Util.DebugMessage( "[trigger_changecvar]" );

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( dictKeyValues[ Key ] );
				string OldValue = string( dictOldCvars[ Key ] );

                if( g_Utility.IsStringInt( Value ) )
                {
					dictOldCvars[ Key ] = string( g_EngineFuncs.CVarGetFloat( Key ) );

                    g_EngineFuncs.CVarSetFloat( Key, ( useType == USE_OFF ) ? atoi( OldValue ) : atoi( Value ) );

                    g_Util.DebugMessage( "" + Key + ": '" + OldValue + "' -> '" + string( g_EngineFuncs.CVarGetString( Key ) ) + "'" );
				}
                else if( g_Utility.IsStringFloat( Value ) )
                {
					dictOldCvars[ Key ] = string( g_EngineFuncs.CVarGetFloat( Key ) );

                    g_EngineFuncs.CVarSetFloat( Key, ( useType == USE_OFF ) ? atof( OldValue ) : atof( Value ) );

                    g_Util.DebugMessage( "" + Key + ": '" + OldValue + "' -> '" + string( g_EngineFuncs.CVarGetString( Key ) ) + "'" );
                }
				else
				{
					dictOldCvars[ Key ] = string( g_EngineFuncs.CVarGetString( Key ) );

                    g_EngineFuncs.CVarSetString( Key, ( useType == USE_OFF ) ? OldValue : Value );

                    g_Util.DebugMessage( "" + Key + ": '" + OldValue + "' -> '" + string( g_EngineFuncs.CVarGetString( Key ) ) + "'" );
                }
            }
        }

        void Spawn()
        {
            if( self.pev.SpawnFlagBitSet( SF_TCC_START_ON ) )
            {
                self.Use( null, null, USE_TOGGLE, 0.0f );
            }

            BaseClass.Spawn();
        }
    }
}
// End of namespace