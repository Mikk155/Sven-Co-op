/*
DOWNLOAD:

scripts/maps/mikk/trigger_changecvar.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/trigger_changecvar"

void MapInit()
{
    trigger_changecvar::Register();
}
*/

#include "utils"

namespace trigger_changecvar
{
    class trigger_changecvar : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        dictionary dictKeyValues;

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

            UTILS::Debug( "[trigger_changecvar::Use()]" );

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( dictKeyValues[ Key ] );

                if( g_Utility.IsStringFloat( Value ) || g_Utility.IsStringInt( Value ) )
                {
                    float newvalue, oldvalue;

                    oldvalue = g_EngineFuncs.CVarGetFloat( Key );

                    g_EngineFuncs.CVarSetFloat( Key, atof( Value ) );

                    newvalue = g_EngineFuncs.CVarGetFloat( Key );

                    UTILS::Debug( "Set CVAR '" + Key + "' : '" + oldvalue + "'  -> '" + newvalue + "'" );
                }
                else
                {
                    string newvalue, oldvalue;

                    oldvalue = g_EngineFuncs.CVarGetString( Key );

                    g_EngineFuncs.CVarSetString( Key, Value );

                    newvalue = g_EngineFuncs.CVarGetString( Key );

                    UTILS::Debug( "Set CVAR '" + Key + "' : '" + oldvalue + "'  -> '" + newvalue + "'" );
                }
            }

            UTILS::Trigger( self.pev.target, ( pActivator is null ) ? self : pActivator, self, useType, delay );
        }
    }

    void Register() 
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_changecvar::trigger_changecvar", "trigger_changecvar" );
    }
}