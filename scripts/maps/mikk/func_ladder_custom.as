#include "utils"

namespace func_ladder_custom
{
    void Register()
    {
        g_Scheduler.SetTimeout( "func_ladder_custom_init", 0.0f );
    }

    void func_ladder_custom_init()
    {
        CBaseEntity@ self = null;
        while( ( @self = g_EntityFuncs.FindEntityByClassname( self, "func_ladder" ) ) !is null )
        {
            if( self !is null )
            {
                string rendermode = g_Util.GetCKV( self, '$s_rendermode' );
                string renderamt = g_Util.GetCKV( self, '$s_renderamt' );
                string rendercolor = g_Util.GetCKV( self, '$s_rendercolor' );
                string renderfx = g_Util.GetCKV( self, '$s_renderfx' );

                if( !rendermode.IsEmpty() )
                {
                    self.pev.rendermode = atoi( rendermode );
                }
                if( !renderamt.IsEmpty() )
                {
                    self.pev.renderamt = uint8( atoi( renderamt ) );
                }
                if( !renderfx.IsEmpty() )
                {
                    self.pev.renderfx = atoi( renderfx );
                }
                if( !rendercolor.IsEmpty() )
                {
                    self.pev.rendercolor = g_Util.StringToVec( rendercolor );
                }
            }
        }
    }
}