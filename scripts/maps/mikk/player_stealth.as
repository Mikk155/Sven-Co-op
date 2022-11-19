/*

INSTALL:
#include "mikk/player_stealth"

void MapInit()
{
    RegisterPlayerStealth();
}

*/

#include "utils"

void RegisterPlayerStealth()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "player_stealth", "player_stealth" );
}

class player_stealth : ScriptBaseEntity
{
    private bool Toggle	= true;

    void Spawn()
    {
        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            Toggle = false;
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;

        BaseClass.Spawn();
	}
	
    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        switch(useType)
        {
            case USE_ON:
            {
                Toggle = true;
            }
            break;

            case USE_OFF:
            {
                Toggle = false;
            }
            break;

            default:
            {
                Toggle = !Toggle;
            }
            break;
        }
    }
	
    void TriggerThink() 
    {
        if( !Toggle )
        {
            self.pev.nextthink = g_Engine.time + 0.5f;
            return;
        }

        CBaseEntity@ pEnemy = null;
        while( ( @pEnemy = g_EntityFuncs.FindEntityByTargetname( pEnemy, string( self.pev.target ) )) !is null )
        {
            CBaseMonster@ pMoster = cast<CBaseMonster@>(pEnemy);

            if( pMoster.m_hEnemy.GetEntity() !is null )
            {
                CBaseEntity@ pTeleport = null;
                while( ( @pTeleport = g_EntityFuncs.FindEntityByTargetname( pTeleport, self.pev.netname )) !is null )
                {
                    pMoster.m_hEnemy.GetEntity().SetOrigin( pTeleport.pev.origin );
                    g_EntityFuncs.FireTargets( string( self.pev.message ), pMoster.m_hEnemy.GetEntity(), pMoster.m_hEnemy.GetEntity(), USE_TOGGLE, 0.0f, 0.0f );
                    UTILS::Debug("\n\nTS DEBUG-: Player '"+pMoster.m_hEnemy.GetEntity().pev.netname+"' has been spotted. fired target and teleported.\n\n");
                }
                pMoster.m_hEnemy = null;
            }
        }
        self.pev.nextthink = g_Engine.time + 0.1f;
    }
}