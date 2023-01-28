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
            SetCvars( pActivator, pCaller, useType, flValue );
        }

        void Spawn()
        {
            if( self.pev.SpawnFlagBitSet( SF_TCC_START_ON ) )
            {
                SetCvars( null, null, USE_TOGGLE, 0.0f );
            }

            BaseClass.Spawn();
        }

        void SetCvars( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
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

                if( g_Utility.IsStringFloat( Value ) || g_Utility.IsStringInt( Value ) )
                {
                    g_EngineFuncs.CVarSetFloat( Key, ( useType == USE_OFF ) ? atof( OldValue ) : atof( Value ) );

					dictOldCvars[ Key ] = string( g_EngineFuncs.CVarGetFloat( Key ) );
                    g_Util.DebugMessage( "Store CVAR '" + Key + "' : '" + string( g_EngineFuncs.CVarGetFloat( Key ) ) + "'" );
                    g_Util.DebugMessage( "Set CVAR '" + Key + "' : '" + Value + "'" );
                }
                else
                {
                    g_EngineFuncs.CVarSetString( Key, ( useType == USE_OFF ) ? atof( OldValue ) : atof( Value ) );

					dictOldCvars[ Key ] = string( g_EngineFuncs.CVarGetString( Key ) );
                    g_Util.DebugMessage( "Store CVAR '" + Key + "' : '" + string( g_EngineFuncs.CVarGetString( Key ) ) + "'" );
                    g_Util.DebugMessage( "Set CVAR '" + Key + "' : '" + Value + "'" );
                }
            }
        }
    }
}
// End of namespace