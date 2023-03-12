#include "utils"
namespace env_fog
{
    void Register()
    {
        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#env_fog\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Show fog to activator only. created for the use of env_fog in xen maps only (displacer teleport)\n"
        );

        g_CustomEntityFuncs.RegisterCustomEntity( "env_fog::entity", "env_fog_individual" );
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @Connect );
    }

    CScheduledFunction@ g_Fog = g_Scheduler.SetTimeout( "FindEnvFogs", 0.0f );

    void FindEnvFogs()
    {
        CBaseEntity@ pFog = null;

        while( ( @pFog = g_EntityFuncs.FindEntityByClassname( pFog, "env_fog" ) ) !is null )
        {
            if( pFog.pev.SpawnFlagBitSet( 2 ) && pFog !is null )
            {
                dictionary g_keyvalues =
                {
                    { "targetname", pFog.GetTargetname() },
                    { "netname", string( pFog.pev.iuser2 ) },
                    { "message", string( pFog.pev.iuser3 ) },
                    { "frags", string( pFog.pev.rendercolor.x ) },
                    { "health", string( pFog.pev.rendercolor.y ) },
                    { "max_health", string( pFog.pev.rendercolor.z ) },
                    { "target", ( pFog.pev.SpawnFlagBitSet( 1 ) ) ? "off" : "on" }
                };

                CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( "env_fog_individual", g_keyvalues );
                
                if( pTriggerScript !is null )
                {
                    g_EntityFuncs.Remove( pFog );
                }
            }
        }
    }

    class entity : ScriptBaseEntity
    {
        private bool State = false;

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( pActivator !is null && pActivator.IsPlayer() )
            {
                if( useType == USE_ON ) State = true;
                else if( useType == USE_OFF ) State = false;
                else State = !State;

                NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::Fog, cast<CBasePlayer@>( pActivator ).edict() );
                    msg.WriteShort(0); // id
                    msg.WriteByte( ( State ) ? 1 : 0 ); // enable state
                    msg.WriteCoord(0); // unused
                    msg.WriteCoord(0); // unused
                    msg.WriteCoord(0); // unused
                    msg.WriteShort(0); // radius unused
                    msg.WriteByte( int(self.pev.frags) ); // red
                    msg.WriteByte( int(self.pev.health) ); // green
                    msg.WriteByte( int(self.pev.max_health) ); // blue
                    msg.WriteShort( atoi(self.pev.netname) ); // start distance
                    msg.WriteShort( atoi(self.pev.message) ); // end distance
                msg.End();
            }
        }
    }

    HookReturnCode Connect( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        CBaseEntity@ pIndiFog = null;
        while( ( @pIndiFog = g_EntityFuncs.FindEntityByClassname( pIndiFog, "env_fog_individual" ) ) !is null )
        {
            if( pIndiFog.pev.target == "on" )
            {
                // Give it some time for player completelly joins the server
                g_Scheduler.SetTimeout( "EnableFog", 2.0f, EHandle(pIndiFog), EHandle(pPlayer) );
            }
        }
        return HOOK_CONTINUE;
    }
    
    void EnableFog( EHandle fog, EHandle player )
    {
        if( player.IsValid() && fog.IsValid() )
        {
            cast<CBaseEntity@>(fog).Use( cast<CBasePlayer@>(player.GetEntity()), null, USE_ON, 0.0f );
        }
    }
}
// End of namespace