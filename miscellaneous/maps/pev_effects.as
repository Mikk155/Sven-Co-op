#include 'utils/CUtils'
#include 'utils/Reflection'

namespace pev_effects
{
    void Register()
    {
        g_Scheduler.SetTimeout( "pev_effects_init", 0.0f );
    }

    void pev_effects_init()
    {
        CBaseEntity@ pFuncs = null;
        while( ( @pFuncs = g_EntityFuncs.FindEntityByClassname( pFuncs, "func_*" ) ) !is null )
        {
            int iFX = atoi( g_Util.CKV( pFuncs, '$i_enum_effect' ) );

            if( iFX == 0 )
            {
                continue;
            }

            g_Util.Debug();
            g_Util.Debug( '[pev_effects] Added effects "' + string( iFX ) + '" to "' + string( pFuncs.pev.classname ) + '"' );
            g_Util.Debug();

            if( iFX == EF_BRIGHTFIELD ) { pFuncs.pev.effects |= EF_BRIGHTFIELD; }
            if( iFX == EF_MUZZLEFLASH ) { pFuncs.pev.effects |= EF_MUZZLEFLASH; }
            if( iFX == EF_BRIGHTLIGHT ) { pFuncs.pev.effects |= EF_BRIGHTLIGHT; }
            if( iFX == EF_DIMLIGHT ) { pFuncs.pev.effects |= EF_DIMLIGHT; }
            if( iFX == EF_INVLIGHT ) { pFuncs.pev.effects |= EF_INVLIGHT; }
            if( iFX == EF_NOINTERP ) { pFuncs.pev.effects |= EF_NOINTERP; }
            if( iFX == EF_LIGHT ) { pFuncs.pev.effects |= EF_LIGHT; }
            if( iFX == EF_NODRAW ) { pFuncs.pev.effects |= EF_NODRAW; }
            if( iFX == EF_NOANIMTEXTURES ) { pFuncs.pev.effects |= EF_NOANIMTEXTURES; }
            if( iFX == EF_FRAMEANIMTEXTURES ) { pFuncs.pev.effects |= EF_FRAMEANIMTEXTURES; }
            if( iFX == EF_NODECALS ) { pFuncs.pev.effects |= EF_NODECALS; }
        }
    }
}