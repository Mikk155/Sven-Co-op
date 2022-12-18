/*
DOWNLOAD:

scripts/maps/mikk/weapon_changevalue.as
scripts/maps/mikk/utils.as


INSTALL:
    
#include "mikk/weapon_changevalue"

void MapInit()
{
    weapon_changevalue::Register();
}
*/

#include "utils"

namespace weapon_changevalue
{
    class weapon_changevalue : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        private string weapon_classname;
        dictionary dictKeyValues;

        bool KeyValue(const string& in szKey, const string& in szValue)
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "weapon_classname" ) weapon_classname = szValue;
            else dictKeyValues[ szKey ] = szValue;
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return dictKeyValues.getKeys(); }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flvalue )
        {
            if( master() ) return;

            if( pActivator is null or string( weapon_classname ).IsEmpty() ) return;

            CBasePlayerItem@ pWeapon = cast<CBasePlayer@>( pActivator ).HasNamedPlayerItem( weapon_classname );

            if( pWeapon is null )
            {
                return;
            }

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( dictKeyValues[ Key ] );

                g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE,  "weapon_changevalue-: Updated "+ pActivator.pev.netname + "'s weapon " + pWeapon.pev.classname + " keyvalue " + Key + " -> " + Value + "\n" );
                g_EntityFuncs.DispatchKeyValue( pWeapon.edict(), Key, Value );
            }
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "weapon_changevalue::weapon_changevalue", "weapon_changevalue" );
    }
}// end namespace