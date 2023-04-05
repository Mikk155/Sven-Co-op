#include "utils"
namespace env_fog_custom
{
    class env_fog_custom : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private bool State = false;

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( pActivator !is null && pActivator.IsPlayer() )
            {
                if( useType == USE_ON )
				{
					State = true;
				}
                else if( useType == USE_OFF )
				{
					State = false;
				}
				else
				{
					State = !State;
				}

                NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::Fog, cast<CBasePlayer@>( pActivator ).edict() );
                    msg.WriteShort(0);
                    msg.WriteByte( ( State ) ? 1 : 0 );
                    msg.WriteCoord(0);
                    msg.WriteCoord(0);
                    msg.WriteCoord(0);
                    msg.WriteShort(0);
                    msg.WriteByte( int( self.pev.rendercolor.x ) );
                    msg.WriteByte( int( self.pev.rendercolor.y ) );
                    msg.WriteByte( int( self.pev.rendercolor.z ) );
                    msg.WriteShort( atoi(self.pev.netname) );
                    msg.WriteShort( atoi(self.pev.message) );
                msg.End();
            }
        }
		
		void UpdateOnRemove()
		{
            for( int i = 1; i <= g_Engine.maxClients; i++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                if( pPlayer !is null )
                {
					self.Use( pPlayer, self, USE_OFF, 0.0f );
                }

            }
			BaseClass.UpdateOnRemove();
		}
    }

    void remap_fog()
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
                    { "rendercolor", pFog.pev.rendercolor.ToString() },
                    { "spawnflags", string( pFog.pev.spawnflags ) }
                };

                CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( "env_fog_custom", g_keyvalues );
                
                if( pTriggerScript !is null )
                {
                    g_EntityFuncs.Remove( pFog );
                }
            }
        }
    }

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        CBaseEntity@ pIndiFog = null;
        while( ( @pIndiFog = g_EntityFuncs.FindEntityByClassname( pIndiFog, "env_fog_custom" ) ) !is null )
        {
            if( pIndiFog.pev.SpawnFlagBitSet( 1 ) )
            {
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
	bool Register = g_Util.CustomEntity( 'env_fog_custom::env_fog_custom','env_fog_custom' );
	bool PlayerJoin = g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @env_fog_custom::ClientPutInServer );
    CScheduledFunction@ g_Fog = g_Scheduler.SetTimeout( "remap_fog", 0.0f );
}