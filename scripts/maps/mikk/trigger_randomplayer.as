#include "utils"
#include "utils/customentity"

namespace trigger_randomplayer
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_randomplayer::trigger_randomplayer", "trigger_randomplayer" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_randomplayer' ) +
            g_ScriptInfo.Description( 'When fired, Triggers its target with a random player as activator' ) +
            g_ScriptInfo.Wiki( 'trigger_randomplayer' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class trigger_randomplayer : ScriptBaseEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            int eidx = Math.RandomLong( 0, g_PlayerFuncs.GetNumPlayers() );

            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( eidx );

            if( pPlayer !is null )
            {
                g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
            }
        }
    }
}