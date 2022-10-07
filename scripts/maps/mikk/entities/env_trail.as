/*
INSTALL:

#include "mikk/entities/env_trail"

void MapInit()
{
	RegisterCBaseTrail();
}
*/

void RegisterCBaseTrail()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CBaseTrail", "env_trail" );
}

enum CBaseTrail_flags
{
    SF_ETRAIL_START_ON = 1 << 0
}

class CBaseTrail : ScriptBaseEntity
{
	EHandle hTargetEnt = null;
	private bool Toggle = true;

	void Precache()
	{
		g_Game.PrecacheModel( string( self.pev.model ) );
		g_Game.PrecacheGeneric( string( self.pev.model ) );
		BaseClass.Precache();
	}

	void Spawn()
	{
        self.Precache();

        self.pev.movetype   = MOVETYPE_NONE;
        self.pev.solid      = SOLID_NOT;

		// to pass activator requires to trigger the entity anyways
		SetTarget( null );

        g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( self.pev.SpawnFlagBitSet( SF_ETRAIL_START_ON ) )
		{
			Toggle = false;
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + self.pev.frags + 0.1f;
		}

		BaseClass.Spawn();
	}

	// Entity to use origin at. if null = @This, if "!activator" = activator
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
        switch(useType)
        {
            case USE_ON:
            {
				SetThink( ThinkFunction( this.TriggerThink ) );
				Toggle = false;
            }
            break;

            case USE_OFF:
            {
         	   SetThink( null );
			   Toggle = true;
            }
            break;

            default:
            {
				if( Toggle )
				{
					SetThink( ThinkFunction( this.TriggerThink ) );
			   		Toggle = false;
				}
				else
				{
					SetThink( null );
			  	 	Toggle = true;
				}
            }
            break;
        }

		SetTarget( ( pActivator is null ) ? null : pActivator );

		self.pev.nextthink = g_Engine.time + self.pev.frags + 0.1f;
	}

	void SetTarget( CBaseEntity@ pActivator )
	{
		if( string( self.pev.target ).IsEmpty() )
		{
			hTargetEnt = self;
		}
		else if( string( self.pev.target ) == "!activator" )
		{
			hTargetEnt = pActivator;
		}
		else
		{
			hTargetEnt = g_EntityFuncs.FindEntityByTargetname( hTargetEnt, string( self.pev.target ) );
		}
	}

	void TriggerThink()
	{
		if( hTargetEnt.GetEntity() !is null )
		{
			if( hTargetEnt.GetEntity().IsMonster() && !hTargetEnt.GetEntity().IsAlive() )
			{
				self.pev.nextthink = g_Engine.time + self.pev.frags + 0.1f;
				return;
			}

			int iEntityIndex = g_EntityFuncs.EntIndex(hTargetEnt.GetEntity().edict());
			NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
				message.WriteByte( TE_BEAMFOLLOW );
				message.WriteShort( iEntityIndex );
				message.WriteShort( int( g_Game.PrecacheModel( self.pev.model ) ) );
				message.WriteByte( int( self.pev.health ) );
				message.WriteByte( int( self.pev.scale ) );
				message.WriteByte( int( self.pev.rendercolor.x ) );
				message.WriteByte( int( self.pev.rendercolor.y ) );
				message.WriteByte( int( self.pev.rendercolor.z ) );
				message.WriteByte( int( self.pev.renderamt ) );
			message.End();
		}
		self.pev.nextthink = g_Engine.time + self.pev.frags + 0.1f;
	}
}