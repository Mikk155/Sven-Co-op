/*
INSTALL:

#include "mikk/trigger_elseif"

void MapInit()
{
	RegisterCBaseConditions();
}
*/
#include "utils"

void RegisterCBaseConditions() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseElseIfConditions", "trigger_elseif" );
}

class CBaseElseIfConditions : ScriptBaseEntity
{
    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
        if( pActivator !is null )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

            // If you want to add more conditions feel free to do a pull request.
            array<bool> Conditions = 
            {
                pPlayer.HasSuit(),
                g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) == string( self.pev.noise1 ),
                ( ( self.pev.origin - pPlayer.pev.origin ).Length() <= atoi( self.pev.noise1 ) )
            };

            if( Conditions[ atoi( self.pev.health ) ] )
            {
                UTILS::TriggerMode( self.pev.target, pPlayer, 0.0f );

                UTILS::Debug("\nDEBUG-: Condition true for " + pPlayer.pev.netname + ", fired '" + self.pev.target + "'\n\n");
            }
            else 
            {
                UTILS::TriggerMode( self.pev.netname, pPlayer, 0.0f );
                UTILS::Debug("\nDEBUG-: Condition false for " + pPlayer.pev.netname + ", fired '" + self.pev.netname + "'\n\n");
            }

            UTILS::TriggerMode( self.pev.noise, ( self.pev.SpawnFlagBitSet( 1 ) ) ? pActivator : self, 0.0f );
            UTILS::Debug("\nDEBUG-: Conditions verified. fired '" + self.pev.noise + "'\n\n");
        }
        else
        {
            UTILS::TriggerMode( self.pev.message, self, 0.0f );
            UTILS::Debug("\nDEBUG-: pActivator is NULL. fired '" + self.pev.message + "'\n\n");
        }
    }
}