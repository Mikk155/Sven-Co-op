#include "../../maps/mikk/entities/survival_manager"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

void MapInit()
{
    RegisterSurvivalManager();
}

void MapActivate()
{
    CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "survival_manager" );

    if( pEntity !is null || g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1 )
        return;

    dictionary keyvalues;
    keyvalues =
    {
        { "spawnflags",    "1" },// 0 = respawned players will get equipment from CFG while 1 they get what they had when die

        { "iuser1",        "1" },// 0 = Players can't drop weapons while survival mode is OFF while 1 = they can

        { "health",        "5" },// Time in seconds that players must wait to resurrect

        { "frags",        "-1" },// Time that survival mode will be disabled until turned on

        { "iuser2",        "1" } // Used to return back drop weapons.
    };
    g_EntityFuncs.CreateEntity( "survival_manager", keyvalues, true );
}