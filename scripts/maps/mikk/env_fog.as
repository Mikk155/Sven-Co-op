namespace env_fog
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "env_fog::env_fog", "env_fog_individual" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: env_fog\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Show fog to activator only. created for the use of env_fog in xen maps only (displacer teleport)\n"
        );
    }

    enum env_fog_flags{ INVIDIDUALFOG = 2 };

    CScheduledFunction@ g_Fog = g_Scheduler.SetTimeout( "FindEnvFogs", 0.0f );

    void FindEnvFogs()
    {
        CBaseEntity@ pFog = null;

        while( ( @pFog = g_EntityFuncs.FindEntityByClassname( pFog, "env_fog" ) ) !is null )
        {
            if( pFog.pev.SpawnFlagBitSet( INVIDIDUALFOG ) && pFog !is null )
            {
                dictionary g_keyvalues =
                {
                    { "frags", string( pFog.pev.rendercolor.x ) },
                    { "health", string( pFog.pev.rendercolor.y ) },
                    { "max_health", string( pFog.pev.rendercolor.z ) },
                    { "netname", string( pFog.pev.iuser2 ) },
                    { "message", string( pFog.pev.iuser3 ) },
                    { "targetname", pFog.GetTargetname()  }
                };

                CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( "env_fog_individual", g_keyvalues );
                
                if( pTriggerScript !is null )
                {
                    g_EntityFuncs.Remove( pFog );
                }
            }
        }
    }

    class env_fog : ScriptBaseEntity
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
                    msg.WriteShort(0); //id
                    msg.WriteByte( ( State ) ? 1 : 0 ); //enable state
                    msg.WriteCoord(0); //unused
                    msg.WriteCoord(0); //unused
                    msg.WriteCoord(0); //unused
                    msg.WriteShort(0); //radius
                    msg.WriteByte( int(self.pev.frags) );
                    msg.WriteByte( int(self.pev.health) );
                    msg.WriteByte( int(self.pev.max_health) );
                    msg.WriteShort( atoi(self.pev.netname) ); //start dist
                    msg.WriteShort( atoi(self.pev.message) ); //end dist
                msg.End();
            }
        }
    }
}// end namespace