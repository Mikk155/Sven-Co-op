/*
INSTALL:

#include "mikk/env_render_fade"

void MapInit()
{
    RegisterRenderProgressive();
}
*/

#include "utils"

void RegisterRenderProgressive() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseRenderProgressive", "env_render_fade" );
}

class CBaseRenderProgressive : ScriptBaseEntity
{
    void Use( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( string(self.pev.message).IsEmpty() ) self.pev.message = "0.1f";
        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + atof(self.pev.message);
    }

    void TriggerThink()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, self.pev.target ) ) !is null )
        {
            if( pEntity.pev.renderamt == self.pev.renderamt )
            {
                UTILS::TriggerMode( self.pev.netname, self, 0.0f );
                SetThink( null );
            }

            if( self.pev.renderamt > pEntity.pev.renderamt )
                pEntity.pev.renderamt += 1;
            else
                pEntity.pev.renderamt -= 1;
        }
        self.pev.nextthink = g_Engine.time + atof(self.pev.message);
    }
}