#include "../mikk155/meta_api/core"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();

#if METAMOD_PLUGIN_ASLP
    g_Config.Update();
#endif
}

#if METAMOD_PLUGIN_ASLP
class CAntiClipConfig
{
    void Update()
    {
        this.Shutdown();

        dictionary data;
        meta_api::json::Deserialize( "scripts/plugins/anticlip.json", data );

        if( meta_api::json::IsMapListed( data ) )
        {
            g_Game.AlertMessage( at_console, "Anti-Clip disabled for this map.\n" );
            return;
        }

        data.get( "npc_clip", monsters );
        data.get( "player_boost", boost );
        data.get( "cliper_invisible", nodraw );
        data.get( "cliper_rendermode", rendermode );
        data.get( "cliper_renderamt", renderamt );
        data.get( "projectiles_clip", projectiles );

        g_Hooks.RegisterHook( Hooks::aslp::Player::PreMovement, @this.fnPreMovement );

        if( ( this.nodraw || this.rendermode > kRenderNormal  ) )
        {
            g_Hooks.RegisterHook( Hooks::aslp::Player::PostAddToFullPack, @this.fnPostAddToFullPack );
        }

        if( !projectiles )
        {
            g_Hooks.RegisterHook( Hooks::aslp::Entity::ShouldCollide, @this.fnShouldCollide );
        }
    }

    void Shutdown()
    {
        g_Hooks.RemoveHook( Hooks::aslp::Player::PreMovement, @this.fnPreMovement );
        g_Hooks.RemoveHook( Hooks::aslp::Player::PostAddToFullPack, @this.fnPostAddToFullPack );
        g_Hooks.RemoveHook( Hooks::aslp::Entity::ShouldCollide, @this.fnShouldCollide );
    }

    PostAddToFullPackHook@ fnPostAddToFullPack = PostAddToFullPackHook( PostAddToFullPack );
    PreMovementHook@ fnPreMovement = PreMovementHook( PreMovement );
    ShouldCollideHook@ fnShouldCollide = ShouldCollideHook( ShouldCollide );

    bool monsters = false;
    bool projectiles = false;
    bool boost = true;
    bool nodraw = false;
    int rendermode = kRenderTransTexture;
    int renderamt = 100;
}

CAntiClipConfig g_Config;

void MapInit()
{
#if METAMOD_DEBUG // Testing allied npcs cliping
    g_Game.PrecacheOther( "monster_barney" );
#endif

    g_Config.Update();
}

HookReturnCode PreMovement( playermove_t@& out pmove, MetaResult &out meta_result )
{
    if( pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO )
    {
        return HOOK_CONTINUE;
    }

    CBasePlayer@ player = g_PlayerFuncs.FindPlayerByIndex( pmove.player );

    int numphysent = 0;

    for( int j = numphysent; j < pmove.numphysent; j++ )
    {
        physent_t@ physent = pmove.GetPhysEntByIndex(j);

        if( physent is null )
            continue;

        if( physent.name == "player" )
        {
            // No boosting? Skip immediatelly
            if( !g_Config.boost )
                continue;

            CBasePlayer@ other = g_PlayerFuncs.FindPlayerByIndex( physent.info );

            if( other is null )
                continue;

            if( ( player.pev.button & IN_DUCK ) != 0 )
                continue;

            // Standing player
            if( ( other.pev.button & IN_DUCK ) == 0 && pmove.origin.z < physent.origin.z + 72 )
                continue;

            // Crouching player
            if( pmove.origin.z < physent.origin.z + 54 )
                continue;
        }
        else if( !g_Config.monsters )
        {
            CBaseEntity@ entity = g_EntityFuncs.Instance( physent.info );

            if( entity !is null && entity.IsMonster() )
            {
                if( !entity.IsAlive() )
                    continue;

                // Do not clip on ally monsters
                if( player.IRelationship( entity ) == R_AL )
                {
                    if( !g_Config.boost )
                        continue;

                    if( ( player.pev.button & IN_DUCK ) != 0 )
                    {
                        if( pmove.origin.z - pmove.view_ofs.z < physent.origin.z + physent.maxs.z + pmove.view_ofs.z )
                            continue;
                    }
                    else if( pmove.origin.z < physent.origin.z + physent.maxs.z + 36 )
                        continue;
                }
            }
        }

        pmove.SetPhysEntByIndex( physent, numphysent++ );
    }

    pmove.numphysent = numphysent;

    return HOOK_CONTINUE;
}

HookReturnCode PostAddToFullPack( ClientPacket@ packet, MetaResult &out meta_result )
{
    // If npc is clipping then we don't care about non-player entities.
    if( g_Config.monsters && packet.playerIndex == 0 )
        return HOOK_CONTINUE;

    if( packet.host is null || packet.entity is null )
        return HOOK_CONTINUE;

    // Skip if the packet is the host
    if( packet.entity is packet.host )
        return HOOK_CONTINUE;

    auto playerHost = g_EntityFuncs.Instance( packet.host );
    auto entityPacket = g_EntityFuncs.Instance( packet.entity );

    if( playerHost is null || entityPacket is null )
        return HOOK_CONTINUE;

    if( !entityPacket.IsPlayer() )
    {
        if( g_Config.monsters || !entityPacket.IsMonster() )
            return HOOK_CONTINUE;
    }

    // Is the host intersecting the packet?
    if( entityPacket.IsAlive() && playerHost.IRelationship( entityPacket ) == R_AL && playerHost.Intersects( entityPacket ) )
    {
        if( g_Config.nodraw )
        {
            packet.state.effects |= EF_NODRAW;
        }
        else
        {
            packet.state.rendermode = g_Config.rendermode;
            packet.state.renderamt = g_Config.renderamt;
        }
    }

    packet.state.solid = SOLID_NOT;

    return HOOK_CONTINUE;
}

HookReturnCode ShouldCollide( CBaseEntity@ toucher, CBaseEntity@ other, MetaResult &out meta_resut, bool&out Collide )
{
    if( toucher is null || other is null )
        return HOOK_CONTINUE;

    if( toucher.IsPlayer() && other.IsPlayer() )
    {
        // Player can melee while inside another player and hit something else
        if( other.Intersects( toucher ) )
        {
            Collide = false;
            meta_resut = MetaResult::Supercede;
        }
        return HOOK_HANDLED;
    }

    auto owner = g_EntityFuncs.Instance( other.pev.owner );

    // Don't touch allied projectiles
    if( owner !is null && toucher.IRelationship( owner ) == R_AL )
    {
        Collide = false;
        meta_resut = MetaResult::Supercede;
        return HOOK_HANDLED;
    }

    return HOOK_CONTINUE;
}
#endif
