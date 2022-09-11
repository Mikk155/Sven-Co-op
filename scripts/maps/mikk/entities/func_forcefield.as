/*
	trigger something once per player

INSTALL:

#include "mikk/entities/utils"
#include "mikk/entities/func_forcefield"

void MapInit()
{
	RegisterFuncForceField();
}

*/

void RegisterFuncForceField() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "func_forcefield", "func_forcefield" );
}

class func_forcefield : ScriptBaseEntity
{
	private bool toggle = false;
	private float FieldPriority = 1;
	private Vector NV_COLOR( 150, 200, 200 );
	private int	iRadius	= 48;
	private int	iLife = 2;
	private int	iDecay = 1;

	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
		if( szKey == "fieldpriority" )
		{
			FieldPriority = atof( szValue );
			return true;
		}
		else if( szKey == "minhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		} 
		else if( szKey == "maxhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else 
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Spawn() 
	{
        self.Precache();

        self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_NOT;

		UTILS::SetSize( self );

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( self.pev.SpawnFlagBitSet( 1 ) )
		{
			toggle = true;
		}
		else
		{
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		
        BaseClass.Spawn();
	}

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
		if( toggle )
		{
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		else
		{
			SetThink( ThinkFunction( this.Disable ) );
			self.pev.nextthink = g_Engine.time + 0.2f;
		}
		toggle = !toggle;
	}

	void Disable()
	{
		if( self.pev.renderamt > 0 )
			self.pev.renderamt -= 30;
		else
			SetThink( null );

		self.pev.nextthink = g_Engine.time + 0.2f;
	}

	void TriggerThink() 
	{
		if( self.pev.renderamt < 200 )
			self.pev.renderamt += 30;
		
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			CustomKeyvalues@ ckCanPass = pPlayer.GetCustomKeyvalues();
			CustomKeyvalue kcvCanPass = ckCanPass.GetKeyvalue("$i_ShieldPass");
			int iPlayerPass = int(kcvCanPass.GetFloat());

			if( iPlayerPass >= FieldPriority && UTILS::InsideZone( pPlayer, self ) )
			{
				g_EntityFuncs.FireTargets( string(self.pev.netname), pPlayer, pPlayer, USE_ON );
				continue;
			}
			else
			{
				g_EntityFuncs.FireTargets( string(self.pev.netname), pPlayer, pPlayer, USE_OFF );
			}

			if( FieldPriority > iPlayerPass && UTILS::InsideZone( pPlayer, self ) )
			{
				pPlayer.pev.velocity.y = -pPlayer.pev.velocity.x *1.5;
				pPlayer.pev.velocity.x = -pPlayer.pev.velocity.y *1.5;

				self.SUB_UseTargets( @self, USE_TOGGLE, 0 );
			}
		}

		Vector vecSrc = self.pev.origin;
		NetworkMessage netMsg( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, self.edict() );
		netMsg.WriteByte( TE_DLIGHT );
		netMsg.WriteCoord( vecSrc.x );
		netMsg.WriteCoord( vecSrc.y );
		netMsg.WriteCoord( vecSrc.z );
		netMsg.WriteByte( iRadius );
		netMsg.WriteByte( int(NV_COLOR.x) );
		netMsg.WriteByte( int(NV_COLOR.y) );
		netMsg.WriteByte( int(NV_COLOR.z) );
		netMsg.WriteByte( iLife );
		netMsg.WriteByte( iDecay );
		netMsg.End();
		
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
}