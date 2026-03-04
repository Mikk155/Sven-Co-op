#include "../mikk155/meta_api/core"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();
    g_Config.Update();
}

#if METAMOD_PLUGIN_ASLP
class CAntiClipConfig
{
    void Shutdown()
    {
        g_Hooks.RemoveHook( Hooks::aslp::Player::PreMovement, @PreMovement );
    }

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

        g_Hooks.RegisterHook( Hooks::aslp::Player::PreMovement, @PreMovement );
    }

    bool monsters = false;
    bool boost = true;
    bool nodraw = false;
    int rendermode = kRenderTransTexture;
    int renderamt = 100;

    bool ShouldPacketFilter {
        get {
            return ( this.nodraw || this.rendermode > kRenderNormal  );
        }
    }

    bool state;
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

    int numphysent = -1;

    for( int j = numphysent; j <= pmove.numphysent; j++ )
    {
        physent_t@ physent = pmove.GetPhysEntByIndex(j);

        if( physent is null )
            continue;

        CBasePlayer@ s1 = g_PlayerFuncs.FindPlayerByIndex( physent.info );

        if( physent.IsPlayer() )
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

            if( entity !is null )
            {
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
#endif
