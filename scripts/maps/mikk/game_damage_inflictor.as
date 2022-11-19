/*

INSTALL:

#include "mikk/game_damage_inflictor"

void MapInit()
{
    RegisterDamageInflictorEntity();
}
*/

#include "utils"

void RegisterDamageInflictorEntity() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseDamageInflictor", "game_damage_inflictor" );
}

class CBaseDamageInflictor : ScriptBaseEntity, UTILS::MoreKeyValues
{
    private float messagetime = 0.0f;
    private float duration = 2.0f;
    private float holdtime = 0.0f;
    private float delay = 0.0f;
    private int loadtime = 0;

    bool KeyValue( const string& in szKey, const string& in szValue ) 
    {
        ExtraKeyValues(szKey, szValue);

        if( szKey == "messagetime" )
        {
            messagetime = atof( szValue );
        }
        else if( szKey == "loadtime" )
        {
            loadtime = atoi( szValue );
        }
        else if( szKey == "holdtime" )
        {
            holdtime = atof( szValue );
        }
        else if( szKey == "duration" )
        {
            duration = atof( szValue );
        }
        else if( szKey == "delay" )
        {
            delay = atof( szValue );
        }
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }
        return true;
    }

    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
		if( multisource() )
		{
			self.pev.nextthink = g_Engine.time + 0.1f;
			return;
		}

        CBaseEntity@ pInflictor = g_EntityFuncs.Instance( pActivator.pev.dmg_inflictor );

        if( pInflictor.IsPlayer() && loadtime > 0 )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>(pInflictor);
            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
        }

        UTILS::TriggerMode( self.pev.target, pInflictor, delay );

        UTILS::TriggerMode( self.pev.message, pInflictor, messagetime );
        
        if( !self.pev.SpawnFlagBitSet( 1 ) )
            g_PlayerFuncs.ScreenFade( cast<CBasePlayer@>(pInflictor), self.pev.rendercolor, duration, holdtime, int( self.pev.renderamt ), int( self.pev.health ) );
    }
}