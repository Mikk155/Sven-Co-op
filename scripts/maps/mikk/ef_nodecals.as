#include "utils"

namespace ef_nodecals
{
    void Register()
    {
        g_Scheduler.SetTimeout( "ef_flags_init", 0.0f );
    }

    void ef_flags_init()
    {
        CBaseEntity@ pFuncs = null;
        while( ( @pFuncs = g_EntityFuncs.FindEntityByClassname( pFuncs, "func_*" ) ) !is null )
        {
            if( pFuncs !is null && atoi( g_Util.GetCKV( pFuncs, '$i_efnodecals' ) ) == 1 )
            {
                pFuncs.pev.effects |= EF_NODECALS;
            }
        }
    }
}