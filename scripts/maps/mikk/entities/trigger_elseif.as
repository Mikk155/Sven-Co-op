/*
INSTALL:

#include "mikk/entities/trigger_elseif"

void MapInit()
{
	RegisterCBaseConditions();
}
*/
#include "utils"

void RegisterCBaseConditions() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBasePlayers", "player_elseif" );
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseMonsters", "monster_elseif" );
}

class CBasePlayers : ScriptBaseEntity
{
    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
		if( pActivator !is null and pActivator.IsPlayer() )
        {
            CBasePlayer@ pPlr = cast<CBasePlayer@>( pActivator );

            // If you want to add more conditions feel free to do a pull request.
            array<bool> Conditions = 
            {
                pPlr.HasSuit()
            };

            if( Conditions[ atoi( self.pev.health ) ] )
            {
                UTILS::TriggerMode( self.pev.target, pPlr );
                g_Game.AlertMessage( at_console, "\nDEBUG-: Condition true for " + pPlr.pev.netname + ", fired '" + self.pev.target + "'\n\n");
            }
            else 
            {
                UTILS::TriggerMode( self.pev.netname, pPlr );
                g_Game.AlertMessage( at_console, "\nDEBUG-: Condition false for " + pPlr.pev.netname + ", fired '" + self.pev.netname + "'\n\n");
            }
        }
    }
}

class CBaseMonsters : ScriptBaseEntity
{
    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
		if( pActivator !is null and pActivator.IsMonster() )
        {
            CBaseMonster@ pMtr = cast<CBaseMonster@>( pActivator );

            // If you want to add more conditions feel free to do a pull request.
            array<bool> Conditions = 
            {
                pMtr.IsPlayerAlly()
            };

            if( Conditions[ atoi( self.pev.health ) ] )
            {
                UTILS::TriggerMode( self.pev.target, pMtr );
                g_Game.AlertMessage( at_console, "\nDEBUG-: Condition true for " + pMtr.pev.classname + ", fired '" + self.pev.target + "'\n\n");
            }
            else 
            {
                UTILS::TriggerMode( self.pev.netname, pMtr );
                g_Game.AlertMessage( at_console, "\nDEBUG-: Condition false for " + pMtr.pev.classname + ", fired '" + self.pev.netname + "'\n\n");
            }
        }
    }
}