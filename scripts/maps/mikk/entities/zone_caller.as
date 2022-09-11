/*
	a brush entity that will drop a message or a custom one if set. telling players to press E to trigger something.
	Useful if you want to give information about something but dont actually spam it into player's face.
	you could use this in conjunction with Outerbeast's game_popup.
	https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/game_popup.as


INSTALL:

#include "mikk/entities/utils"
#include "mikk/entities/zone_caller"

void MapInit()
{
	RegisterZoneCaller();
}

*/

void RegisterZoneCaller()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "zone_caller", "zone_caller" );
}

class zone_caller : ScriptBaseEntity, MLAN::MoreKeyValues
{
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		SexKeyValues(szKey, szValue);

		return true;
	}

    void Spawn()
	{
		self.pev.movetype 	= MOVETYPE_NONE;
		self.pev.solid 		= SOLID_NOT;
		self.pev.effects	|= EF_NODRAW;
		
		UTILS::SetSize( self );

		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		SetThink( ThinkFunction( this.TriggerThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;

        BaseClass.Spawn();
	}
	
	void TriggerThink() 
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			if( UTILS::InsideZone( pPlayer, self ) )
			{
				int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

				//g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, string(ReadLanguages(iLanguage))+"\n");
				g_PlayerFuncs.PrintKeyBindingString(pPlayer, string(ReadLanguages(iLanguage))+'\n');

				if( self.pev.health == 0 )
					if( pPlayer.pev.button & IN_USE != 0)
						g_EntityFuncs.FireTargets( ""+self.pev.target+"", pPlayer, pPlayer, USE_TOGGLE );
			}
		}
		self.pev.nextthink = g_Engine.time + 0.3f;
	}
}