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

#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    g_Hooks.RegisterHook( Hooks::ASLP::Engine::ClientCommand, @ClientCommand );
    pJson.load( 'plugins/mikk/NPCMoveTo' );
}

json pJson;

float time;

HookReturnCode ClientCommand( CBasePlayer@ pPlayer, const string& in m_iszCommand, META_RES& out meta_result )
{
    if( pPlayer !is null
    && m_iszCommand == 'npc_moveto' &&
    || ( pPlayer.IsAlive() || Json[ 'observers can use', false ] )
    && ( time > g_Engine.time || Json[ 'global cooldown', false ] ) )
    {
        TraceResult tr;

        Vector anglesAim = pPlayer.pev.v_angle + pPlayer.pev.punchangle;
        g_EngineFuncs.MakeVectors( anglesAim );
        Vector vecSrc = pPlayer.GetGunPosition();
        Vector vecDir = g_Engine.v_forward;

        g_Utility.TraceLine( vecSrc, vecSrc + vecDir * 8192, dont_ignore_monsters, pPlayer.edict(), tr );

        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            m.WriteByte( TE_IMPLOSION );
            m.WriteCoord( tr.vecEndPos.x);
            m.WriteCoord( tr.vecEndPos.y);
            m.WriteCoord( tr.vecEndPos.z - ( ( tr.vecPlaneNormal.z < 0 ) ? 4 : 0 ) );
            m.WriteByte( 32 );
            m.WriteByte( 32 );
            m.WriteByte( 2 );
        m.End();

        time = g_Engine.time + 1.0;
    }
    return HOOK_CONTINUE;
}