/*
	Equip players on fire or touch.

INSTALL:

#include "mikk/entities/utils"
#include "mikk/entities/game_equip_individual"

void MapInit()
{
	RegisterGameEquipIndividual();
}

*/

void RegisterGameEquipIndividual() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "game_equip_individual", "game_equip_individual" );
}

class game_equip_individual : ScriptBaseEntity
{
	void Spawn() 
	{
        self.pev.movetype = MOVETYPE_NONE;

		if( string(self.pev.targetname).IsEmpty() )
		{
			self.pev.solid = SOLID_TRIGGER;
		}
		else
		{
			self.pev.solid = SOLID_NOT;
		}

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

        BaseClass.Spawn();
	}

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
		if( string( self.pev.target ) == "!activator" )
		{
			EquipPlayer( pActivator );
		}
		else
		{
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer !is null )
				{
					EquipPlayer( pPlayer );
				}
			}
		}
	}

    void Touch(CBaseEntity@ pOther )
    {
		if( pOther is null || !pOther.IsPlayer() )
			return;

		if( string( self.pev.target ) == "!activator" )
		{
			EquipPlayer( pOther );
		}
		else
		{
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer !is null )
				{
					EquipPlayer( pPlayer );
				}
			}
		}
	}
}

mixin class game_equip_base
{
    dictionary g_MaxPlayers;

    bool SavePlayerSteamID( CBasePlayer@ pPlayer )
    { 
        string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

        if( pPlayer is null  )
            return false;

        if( !g_MaxPlayers.exists(SteamID) ) //Si el SteamID no existe, que continue
        {
            //Something

            g_MaxPlayers[SteamID]; //Se guarda su SteamID despues de usar

            return true; //Ha sido guardado el SteamID
        }

         return false; //El SteamID ya existia, so, no hizo nada
    }
}