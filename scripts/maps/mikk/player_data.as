/*
DOWNLOAD:

scripts/maps/mikk/player_data.as


INSTALL:

#include "mikk/player_data"


TEST MAP:
https://github.com/Mikk155/Sven-Co-op/releases/tag/player_data
*/

namespace player_data
{
    CScheduledFunction@ g_PlayerData = g_Scheduler.SetTimeout( "InitPlayerDataStore", 0.0f );

    void InitPlayerDataStore()
    {
        dictionary g_keyvalues =
        {
            { "m_iszScriptFunctionName", "player_data::CallPlayerDataStore" },
            { "m_iMode", "2" },
            { "m_flThinkDelta", "1.0" },
            { "targetname", "InitPlayerDataStore" }
        };
        CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

        if( pTriggerScript !is null )
        {
            g_EntityFuncs.FireTargets( "InitPlayerDataStore", null, null, USE_ON, 0.0f );
        }
    }

    void CallPlayerDataStore( CBaseEntity@ pTriggerScript )
    {
        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null )
            {
                SetDataOnValues( pPlayer, "$i_hassuit", string( pPlayer.HasSuit() ) );
                SetDataOnValues( pPlayer, "$s_steamid", string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );
                SetDataOnValues( pPlayer, "$i_adminlevel", string( g_PlayerFuncs.AdminLevel( pPlayer ) ) );
                SetDataOnValues( pPlayer, "$i_hascorpse", string( pPlayer.GetObserver().HasCorpse() ) );
            }
        }
    }

    void SetDataOnValues( CBasePlayer@ pPlayer, const string key, const string value )
    {
        dictionary g_keyvalues;
        g_keyvalues [ "m_iszValueType" ] = "0";
        g_keyvalues [ "target" ] = "!activator";
        g_keyvalues [ "targetname" ] = "doweneedanamehere?";
        g_keyvalues [ "m_iszValueName" ] = key;
        g_keyvalues [ "m_iszNewValue" ] = value;

        CBaseEntity@ pSetValue = g_EntityFuncs.CreateEntity( "trigger_changevalue", g_keyvalues, true );

        if( pSetValue !is null )
        {
            // g_Game.AlertMessage( at_console, "player_data::SetDataOnValues() saved " + pPlayer.pev.netname + "'s data. " + '"' + key + '" "' + value + '"\n');
            pSetValue.Use( pPlayer, pPlayer, USE_ON, 0.0f );
            g_EntityFuncs.Remove( pSetValue );
        }

        // this doesn't work. it sets a empty string.
        //pPlayer.GetCustomKeyvalues().SetKeyvalue( key, value );
    }
}
// End of namespace