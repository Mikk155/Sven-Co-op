const bool p_Customizable = true;

#include "mikk/entities/utils"
#include "mikk/entities/trigger_inbutton"
#include "mikk/entities/env_spritehud"
#include "mikk/entities/trigger_inout"
#include "mikk/entities/trigger_once_mp"
#include "mikk/entities/game_text_custom"
#include "mikk/entities/trigger_once_individual"
#include "cof/pistols/weapon_cofglock"
#include "cof/special/weapon_cofsyringe"
#include "ins2/handg/weapon_ins2beretta"
#include "ins2/handg/weapon_ins2usp"
#include "ins2/explo/weapon_ins2mk2"
#include "ins2/brifl/weapon_ins2g3a3"
#include "ins2/carbn/weapon_ins2m4a1"
#include "ins2/melee/weapon_ins2kabar"
#include "ins2/arifl/weapon_ins2l85a2"

void MapInit()
{
	INS2_USP::Register();
	INS2_G3A3::Register();
	INS2_M4A1::Register();
	INS2_KABAR::Register();
	INS2_L85A2::Register();
	INS2_M9BERETTA::Register();
	INS2_MK2GRENADE::Register();
	RegisterCoFGLOCK();
	RegisterCoFSYRINGE();
	
	RegisterTriggerInButtons();
	RegisterEnvSpriteHud();
	RegisterAntiRushEntity();
	RegisterCustomTextGame();
	RegisterTriggerOnceIndividual();
	RegisterCBaseInOut("trigger_inout");
	g_SoundSystem.PrecacheSound("player/hud_nightvision.wav");
	g_SoundSystem.PrecacheSound("items/flashlight2.wav");
}

void MapStart()
{
	TCISUTILS::FixAmbientGeneric();

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary nvPlayer;

// Workaround until i decide to do the map logic
dictionary rpPlayer;
HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	if( rpPlayer.exists(SteamID) )
		return HOOK_CONTINUE;

	g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );

	rpPlayer[SteamID] = @pPlayer;

	return HOOK_CONTINUE;
}

namespace TCISUTILS
{
	void FixAmbientGeneric()
	{
		CBaseEntity@ self = null;

		// Workaround. not ripent for yet x[
		while((@self = g_EntityFuncs.FindEntityByClassname(self, "ambient_generic")) !is null)
		{
			if( string( self.pev.message ).StartsWith ("!") )
			{
				dictionary MyScriptedSentence;
				MyScriptedSentence ["targetname"]	= string( self.pev.targetname );
				MyScriptedSentence ["sentence"]		= string( self.pev.message );
				MyScriptedSentence ["entity"]		= string( self.pev.targetname );
				MyScriptedSentence ["volume"]		= "10";
				MyScriptedSentence ["attenuation"]	= "3";
				g_EntityFuncs.CreateEntity( "scripted_sentence", MyScriptedSentence, true );
				
				g_Game.AlertMessage( at_console, "\nMAP DEBUG-: Created scripted_sentence for "+self.pev.targetname+" that plays a sentence.\n\n" );

				self.pev.message = "";
			}
		}
	}
	// Code taken from Neo's night vision script.
	void NVision( CBaseEntity@ pTriggerScript )
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			
			if( pPlayer.FlashlightIsOn() )
			{
				// Yeah. we want goggles :D
				pPlayer.BlockWeapons( pTriggerScript );
				// Env_spritehud
				g_EntityFuncs.FireTargets( "NVGOGGLESHUD", pPlayer, pPlayer, USE_ON );
				
				if( !nvPlayer.exists(szSteamId) ) 
				{
					g_PlayerFuncs.ScreenFade( pPlayer, Vector( 110, 255, 40 ), 0.01f, 0.5f, 12, FFADE_OUT | FFADE_STAYOUT);
					g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "player/hud_nightvision.wav", 0.8f, ATTN_NORM, 0, PITCH_NORM );

					nvPlayer[szSteamId] = true;
				}

				Vector vecSrc = pPlayer.EyePosition();
				NetworkMessage netMsg( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
				netMsg.WriteByte( TE_DLIGHT );
				netMsg.WriteCoord( vecSrc.x );
				netMsg.WriteCoord( vecSrc.y );
				netMsg.WriteCoord( vecSrc.z );
				netMsg.WriteByte( 48 );
				netMsg.WriteByte( 110 );
				netMsg.WriteByte( 255 );
				netMsg.WriteByte( 40 );
				netMsg.WriteByte( 2 );
				netMsg.WriteByte( 1 );
				netMsg.End();
			}
			else if( nvPlayer.exists(szSteamId) && !pPlayer.FlashlightIsOn() )
			{
				pPlayer.UnblockWeapons( pTriggerScript );
				g_EntityFuncs.FireTargets( "NVGOGGLESHUD", pPlayer, pPlayer, USE_OFF );
			
				g_PlayerFuncs.ScreenFade( pPlayer, Vector( 110, 255, 40 ), 0.01f, 0.5f, 12, FFADE_IN);
				g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "items/flashlight2.wav", 0.8f, ATTN_NORM, 0, PITCH_NORM );
				nvPlayer.delete(szSteamId);
			}
		}
	}
}	// End of namespace.