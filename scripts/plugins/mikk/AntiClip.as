//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../mikk/fft"
#include "../../mikk/json"
#include "../../mikk/Language"
#include "../../mikk/datashared"
#include "../../mikk/EntityFuncs"

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Gaftherman | https://github.com/Mikk155/Sven-Co-op" );
    pJson.load('plugins/mikk/AntiClip.json');
    ToggleState( 1 );
}

bool hooks;

CClientCommand CMD( "anticlip", "Toggle AntiClip, on/off", @Command, ConCommandFlag::AdminOnly );

void Command( const CCommand@ args )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    if( args[1] == "on" || args[1] == "true" || atoi( args[1] ) == 1 )
    {
        if( !hooks )
        {
            Language::PrintAll( pJson[ "ENABLED", {} ], MKLANG::CHAT, { { "name", string( pPlayer.pev.netname ) } } );
            ToggleState( 1 );
        }
    }
    else if( hooks )
    {
        Language::PrintAll( pJson[ "DISABLED", {} ], MKLANG::CHAT, { { "name", string( pPlayer.pev.netname ) } } );
        ToggleState( 0 );
    }
}

void ToggleState( int casex )
{
    switch( casex )
    {
        case 0:
        {
            g_Hooks.RemoveHook( Hooks::ASLP::Engine::PM_Move, @PM_Move );
            g_Hooks.RemoveHook( Hooks::ASLP::Engine::ShouldCollide, @ShouldCollide );
            g_Hooks.RemoveHook( Hooks::ASLP::Engine::AddToFullPack_Post, @AddToFullPack_Post );
            hooks = false;
            break;
        }
        case 1:
        {
            if( !hooks )
            {
                hooks = true;
                g_Hooks.RegisterHook( Hooks::ASLP::Engine::PM_Move, @PM_Move );
                g_Hooks.RegisterHook( Hooks::ASLP::Engine::AddToFullPack_Post, @AddToFullPack_Post );

                if( array<string>( pJson[ 'projectiles' ] ).length() > 0 )
                {
                    g_Hooks.RegisterHook( Hooks::ASLP::Engine::ShouldCollide, @ShouldCollide );
                }
            }
            break;
        }
    }

    datashared::SetData( { { "state", string(casex) } } );
}

bool MapBlackListed, WasEnabled;

void MapActivate()
{
    pJson.reload( 'plugins/mikk/AntiClip.json' );

    if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) > 0 )
    {
        MapBlackListed = true;
        WasEnabled = hooks;
        ToggleState(0);
    }
    else if( MapBlackListed )
    {
        if( WasEnabled )
        {
            ToggleState(1);
        }
        MapBlackListed = false;
    }

    datashared::SetData( { { "state", ( hooks ? '1' : '0' ) } } );
}

HookReturnCode ShouldCollide( CBaseEntity@ pTouched, CBaseEntity@ pProjectile, META_RES& out meta_result, int &out result )
{
    if( pTouched is null || pProjectile is null )
        return HOOK_CONTINUE;

    if( array<string>( pJson[ 'projectiles' ] ).find( 'lasers' ) >= 0 && pTouched.IsPlayer() && pProjectile.IsPlayer() )
    {
        meta_result = MRES_SUPERCEDE;
        return HOOK_CONTINUE;
    }

    CBaseEntity@ pOwner = g_EntityFuncs.Instance( pProjectile.pev.owner );

    if( pOwner is null )
        return HOOK_CONTINUE;

    if( array<string>( pJson[ 'projectiles' ] ).find( pProjectile.GetClassname() ) >= 0
    && ( pTouched.IsPlayer() && pTouched.Classify() == pOwner.Classify() || pOwner.IsPlayer() && pTouched.IsPlayerAlly() )
    ) {
        meta_result = MRES_SUPERCEDE;
    }
    return HOOK_CONTINUE;
}

HookReturnCode PM_Move(playermove_t@& out pmove, int server, META_RES& out meta_result)
{
    if (pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO)
    {
        meta_result = MRES_IGNORED;
        return HOOK_CONTINUE;
    }

    int numphysent = -1;

    for (int j = numphysent; j < pmove.numphysent; j++)
    {
        if (pmove.GetPhysEntByIndex(j) !is null && pmove.GetPhysEntByIndex(j).player == 0)
        {
            pmove.SetPhysEntByIndex(pmove.GetPhysEntByIndex(j), numphysent++);
        }
    }

    pmove.numphysent = numphysent;

    return HOOK_CONTINUE;
}

HookReturnCode AddToFullPack_Post(entity_state_t@& out state, int entindex, edict_t @ent, edict_t@ host, int hostflags, int player, META_RES& out meta_result, int& out result)
{
    CBaseEntity@ pEntity = g_EntityFuncs.Instance(ent);
    CBaseEntity@ pHost = g_EntityFuncs.Instance(host);

    if(pHost !is null && pEntity !is null && pHost.IsPlayer() && pEntity.IsPlayer() && ent !is host && player != 0)
    {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(pHost);
        state.solid = (pPlayer.GetObserver().IsObserver() || Intersects(pHost, pEntity)) ? SOLID_BBOX : SOLID_NOT;
    }

    return HOOK_CONTINUE;
}

bool Intersects(CBaseEntity@ pHost, CBaseEntity@ pEntity)
{
    return pHost.pev.absmin.z >= pEntity.pev.absmax.z - 24;
}