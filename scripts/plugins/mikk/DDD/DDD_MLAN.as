namespace MLANGUAGE
{
    void MSG( CBasePlayer@ pPlayer, const string msg, const string str1, const string str2, const string str3, const string str4 )
    {
		int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

		if( iLanguage == 1 ) // Spanish
		{
		}
		else if( iLanguage == 2 ) // Portuguese
		{
		}
		else if( iLanguage == 3 ) // German
		{
		}
		else if( iLanguage == 4 ) // French
		{
		}
		else if( iLanguage == 5 ) // Italian
		{
		}
		else if( iLanguage == 6 ) // Esperanto
		{
		}
		else // English
		{
			if( msg == "wrong_value" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Wrong difficulty value. can't exceed 100 Percent \n" );
			}
			else if( msg == "empty_value" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] You have to specify a percentage. example:\n" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] /diff 20\n" );
			}
			else if( msg == "show_diffdisabled" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Difficulty is disabled for this map.\n" );
			}
			else if( msg == "show_diff" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Current difficulty is "+str1+" percent.\n" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] say '/ddd' to see more information.\n" );
			}
			else if( msg == "disabledvotes" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Vote for change difficulty is blocked on this server.\n" );
			}
			else if( msg == "tempdisablevote2" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Say diff to accept result. vote time "+str2+"\n" );
			}
			else if( msg == "oncooldown" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Votes are in cooldown for "+str1+" seconds\n" );
			}
			else if( msg == "tempdisablevote" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] a vote to change difficulty to "+str1+" is already in progress.\n" );
			}
			else if( msg == "yupdiff" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] vote to change difficulty to "+str1+" accepted.\n" );
			}
			else if( msg == "vote_passed" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] vote to change difficulty to "+str1+" passed.\n" );
			}
			else if( msg == "disabledmap" )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] This plugin is disabled for this map.\n" );
			}
			else if( msg == "motd" )
			{
    			UTILS::ShowMOTD( pPlayer, "Dynamic Difficulty Deluxe I information",
				"
Dynamic Difficulty Deluxe I ( version 1 ) or know as DDD


It is a plugin that dynamically increases difficulty based on players connected


Alternativelly you can start a vote by saying in chat '/diff (number 0-100)'

admins can force a difficulty instantly by '/admin_diff (number 0-100)'

Features that we've added in order based on difficulty:


Difficulty equal to 0:
Everything is vanilla (Based on the server modifications)


Difficulty greater to 0:
Every 1% of difficulty that is increased....
Monster's health value (BASE) is multiplied by 0.1X
When survival mode is starting no cooldown messages will be shown
cvar 'mp_weaponfadedelay' is divided from 100 to 1 seconds (weapons you drop will disapear after that seconds)
cvar mp_respawndelay is multiplied from 1 to 20 (time you need to wait to re-Spawn)



Difficulty greater to 10:
RNG Alien spawners around a random players every min/max (random) delay between 2400 seconds (40 minutes) to 12000 seconds (200 minutes) in diff 0 while 24 seconds to 120 seconds in diff 100


Difficulty greater to 20:


Difficulty greater to 30:
While survival mode is disabled players can't duplicate weapons by drop and suicide


Difficulty greater to 40:


Difficulty greater to 50:
cvar mp_ammo_respawndelay and mp_item_respawndelay set to -1 that mean ammunition won't re-spawn (only the ones that the map want to respawn infinite will does)
cvar mp_dropweapons set 0 that mean you can't drop weapons or ammo in any way


Difficulty greater to 60:
cvar npc_dropweapons is set to 0 wich mean monsters/npcs will not drop any weapons when die
cvar mp_disable_player_rappel is set to 1 wich mean you can't grapple into players


Difficulty greater to 65:
cvar mp_allowmonsterinfo is set to 0 wich mean you won't see enemies health values when aiming to them


Difficulty greater to 70:
when a monster die it'll have a chance to spawn something on its origin. each 1% of difficulty increases 1% the chance of spawn. list:
monster_alien_slave -> monster_snark
monster_alien_grunt -> monster_sqknest
monster_controller -> monster_stukabat
monster_human X -> monster_handgrenade
monster_zombie X -> monster_headcrab


Difficulty greater to 80:
RNG Monsters spawns around alive players (pick random one) the cooldown of it will be decreased every 1% of difficulty.
meant 1% extra difficulty will decrease the min value in 24 seconds while the max value in 1 minute. default min/max are 2400 seconds and 6000 seconds
Original code by Rick


Difficulty greater to 90:
Map global light will decrease in one value every 1% of difficulty percentage. 100% equals to darkness map


Difficulty greater to 95:
cvar mp_ammo_droprules is set to 1 wich mean when you die you'll drop a weaponbox with all your ammunition from the weapon that you have been using


Difficulty greater to 96:
cvar mp_weapon_droprules is set to 1 wich mean when you die you'll drop your current weapon


Difficulty greater to 97:
Most of the enemies will know where the players are


Difficulty greater to 98:
Players can not use third person mode


Difficulty greater to 99:


Difficulty equal to 100:
Disables all point_checkpoint in the map

				");
			}
		}
	}
}

namespace MLANGUAGEALL
{
    void MSG( const string msg, const string str1, const string str2, const string str3, const string str4 )
    {
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if(pPlayer is null or !pPlayer.IsConnected() )
				continue;

			int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

			if( iLanguage == 1 ) // Spanish
			{
			}
			else if( iLanguage == 2 ) // Portuguese
			{
			}
			else if( iLanguage == 3 ) // German
			{
			}
			else if( iLanguage == 4 ) // French
			{
			}
			else if( iLanguage == 5 ) // Italian
			{
			}
			else if( iLanguage == 6 ) // Esperanto
			{
			}
			else // English
			{
				if( msg == "admin" )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Admin "+str1+" changed difficulty to "+str2+" percent.\n" );
				}
				else if( msg == "vote_start" )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "["+str4+"] Vote to change difficulty to "+str1+" Percent. Vote started by "+str2+"\n" );
				}
			}
		}
	}
}