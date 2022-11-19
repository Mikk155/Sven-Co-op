/*
    INSTALL:

    "plugin"
    {
        "name" "game_survival_control"
        "script" "mikk/game_survival_control"
    }
*/

// false = Dont hide cooldown messages
bool blCooldown = true;

// false = Dont disable weapon's drop while survival is disabled
bool blDropWpn = true;

// false = Dont disable Free roaming for spectators
bool blFreeRoam = true;

// 0 = use default map cvar 'mp_survival_startdelay'
// Else = time in seconds to enable survival mode.
int iDelayStart = 0;

#include "../../maps/mikk/game_survival_control"
void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Mikk https://github.com/Mikk155");
    g_Module.ScriptInfo.SetContactInfo("https://discord.gg/VsNnE3A7j8 \n");
}

void MapStart()
{
    if( g_CustomEntityFuncs.IsCustomEntity( "game_survival_control" ) )
        return;

    if( g_EngineFuncs.CVarGetFloat("mp_survival_starton") == 1
    && g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1 )
    {
        CSurvival::AmmoDupeFix(
            blCooldown,
            blDropWpn,
            blFreeRoam,
            ( iDelayStart == 0 ) ?
            g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" )
            : iDelayStart);
    }
}