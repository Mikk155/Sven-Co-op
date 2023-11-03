#include '../../maps/mikk/as_utils'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );
    mk.FileManager.GetMultiLanguageMessages( msg, 'scripts/plugins/mikk/AntiClip.ini' );
}

dictionary msg;

string sstate;

CConCommand g_Cvars( "AntiClip", "AS Cvars", @SetCvars, ConCommandFlag::AdminOnly );

void SetCvars( const CCommand@ args )
{
    if( args[1] == 'enable' && g_Utility.IsStringInt( args[2] ) )
    {
        switch( atoi( args[2] ) )
        {
            case 0:
            {
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::PM_Move, @PM_Move );
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::ShouldCollide, @ShouldCollide );
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::AddToFullPack_Post, @AddToFullPack_Post );
                sstate = mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_plugin_anticlip', '0' );
                break;
            }
            case 1:
            {
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::PM_Move, @PM_Move );
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::ShouldCollide, @ShouldCollide );
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::AddToFullPack_Post, @AddToFullPack_Post );

                g_Hooks.RegisterHook( Hooks::ASLP::Engine::PM_Move, @PM_Move );
                g_Hooks.RegisterHook( Hooks::ASLP::Engine::AddToFullPack_Post, @AddToFullPack_Post );
                g_Hooks.RegisterHook( Hooks::ASLP::Engine::ShouldCollide, @ShouldCollide );
                sstate = mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_plugin_anticlip', '1' );
                break;
            }
        }

        mk.PlayerFuncs.PrintMessage( null, ( atoi( args[2] ) == 1 ? dictionary( msg[ 'anticlip enabled' ] ) : msg_disabled ), CMKPlayerFuncs_PRINT_CHAT, true );
    }
    else if( !args[1].IsEmpty() )
    {
        projectiles.insertLast( args[1] );
        g_Game.AlertMessage( at_notice, '[AntiClip] Added projectile "' + args[1] + '" to the collision list.\n' );
    }
}

void MapInit()
{
    projectiles.resize( 0 );
    mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_plugin_anticlip', sstate );
}

array<string> projectiles;

HookReturnCode ShouldCollide( CBaseEntity@ pTouched, CBaseEntity@ pProjectile, META_RES& out meta_result, int &out result )
{
    if( pTouched is null || pProjectile is null || projectiles.find( pProjectile.GetClassname() ) < 0 )
        return HOOK_CONTINUE;

    CBaseEntity@ pOwner = g_EntityFuncs.Instance( pProjectile.pev.owner );

    if( pOwner is null )
        return HOOK_CONTINUE;

    if( pTouched.IsPlayer() && pTouched.Classify() == pOwner.Classify() || pOwner.IsPlayer() && pTouched.IsPlayerAlly() )
    {
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