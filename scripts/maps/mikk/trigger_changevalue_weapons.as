#include "utils"
namespace trigger_changevalue_weapons
{
    array<string> WeaponsKeys =
    {
        "skin",
        "target",
        "body",
        "exclusivehold",
        "spawnflags",
        /* Start of weapon_displacer */
        "m_iszTeleportDestination",
        "m_TertiaryMode",
        "m_flPortalSpeed",
        "m_flPortalRadius",
        "m_flPrimaryAmmoNeeded",
        "m_flSecondaryAmmoNeeded",
        "m_flTertiaryAmmoNeeded",
        /* End of weapon_displacer */
        "wpn_v_model",
        "wpn_w_model",
        "wpn_p_model",
        "soundlist",
        "CustomSpriteDir",
        "dmg",
        "renderfx",
        "rendermode",
        "renderamt",
        "rendercolor",
        "movetype",
        "targetname"
    };

    string GetValue( CBaseEntity@ pEntity, string GetValue )
    {
        if( pEntity !is null )
        {
            return pEntity.GetCustomKeyvalues().GetKeyvalue( "$s_" + GetValue ).GetString();
        }
        return String::EMPTY_STRING;
    }

    CScheduledFunction@ g_Changevalue = g_Scheduler.SetTimeout( "FindChangeValues", 0.0f );

    void FindChangeValues()
    {
        dictionary g_keyvalues =
        {
            { "m_iszScriptFunctionName","trigger_changevalue::WeaponValues" },
            { "m_iMode", "1" },
            { "targetname", "weapon_changevalue" }
        };
        g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

        CBaseEntity@ pEnt = null;

        while( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, "trigger_changevalue" ) ) !is null )
        {
            if( GetValue( pEnt, "weapon" ) != String::EMPTY_STRING || GetValue( pEnt, "weapon" ) != '' )
            {
                dictionary g_keyvalues2 =
                {
                    { "target","!activator" },
                    { "m_iszValueName", "$s_weapon" },
                    { "m_iszNewValue", GetValue( pEnt, "weapon" ) },
                    { "message", "weapon_changevalue" },
                    { "targetname", pEnt.GetTargetname() }
                };
                g_EntityFuncs.CreateEntity( pEnt.GetClassname(), g_keyvalues2 );
            }
        }
    }

    void WeaponValues( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flvalue )
    {
        if( pActivator !is null && !GetValue( pActivator, "weapon" ).IsEmpty() )
        {
            CBasePlayerItem@ pWeapon = cast<CBasePlayer@>( pActivator ).HasNamedPlayerItem( GetValue( pActivator, "weapon" ) );

            if( pWeapon !is null )
            {
                for( uint i = 0; i < WeaponsKeys.length(); ++i )
                {
                    if( !GetValue( pActivator, WeaponsKeys[i] ).IsEmpty() )
                    {
                        g_PlayerFuncs.ClientPrintAll
                        (
                            HUD_PRINTCONSOLE,
                            "weapon_changevalue-: Updated "
                            + pActivator.pev.netname 
                            + "'s weapon " 
                            + GetValue( pActivator, "weapon" )
                            + " keyvalue " 
                            + WeaponsKeys[i] 
                            + " -> " 
                            + GetValue( pActivator, WeaponsKeys[i] ) 
                            + "\n"
                        );
                        g_EntityFuncs.DispatchKeyValue( pWeapon.edict(), WeaponsKeys[i], GetValue( pActivator, WeaponsKeys[i] ) );
                    }
                }
            }
        }
    }
}