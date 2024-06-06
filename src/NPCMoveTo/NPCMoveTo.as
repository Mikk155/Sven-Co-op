#include "json"
#include "UserMessages"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Gaftherman | https://github.com/Mikk155/Sven-Co-op" );

    g_Hooks.RegisterHook( Hooks::ASLP::Engine::ClientCommand, @ClientCommand );

    pJson.load( 'plugins/mikk/NPCMoveTo.json' );
}

json pJson;

float time;

HookReturnCode ClientCommand( CBasePlayer@ pPlayer, const string& in m_iszCommand, META_RES& out meta_result )
{
    if( pPlayer !is null
    && m_iszCommand == 'npc_moveto'
    && ( pJson[ 'observers can use', false ] || pPlayer.IsAlive() )
    && g_Engine.time > pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_npcmoveto_cooldown' ).GetFloat() )
    {
        TraceResult tr;

        Vector anglesAim = pPlayer.pev.v_angle + pPlayer.pev.punchangle;
        g_EngineFuncs.MakeVectors( anglesAim );
        Vector vecSrc = pPlayer.GetGunPosition();
        Vector vecDir = g_Engine.v_forward;

        g_Utility.TraceLine( vecSrc, vecSrc + vecDir * 8192, dont_ignore_monsters, pPlayer.edict(), tr );

        Vector VecPos = tr.vecEndPos;
        VecPos.z -= ( ( tr.vecPlaneNormal.z < 0 ) ? 4 : 0 );

        UserMessages::Implosion( VecPos, uint8( pJson[ 'radius', 32 ] ), uint8( pJson[ 'count', 32 ] ), uint8( pJson[ 'life', 2 ] ) );

        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$f_npcmoveto_cooldown', g_Engine.time + pJson[ 'player cooldown', 0.0 ] );
    }
    return HOOK_CONTINUE;
}