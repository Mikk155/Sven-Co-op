void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "idk" );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @NIGHTVISION::PlayerPreThink );
}

namespace NIGHTVISION
{
	array<string> hGrunts =
	{
		"op4_lance",
		"op4_shephard"
	};

	HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
	{
		if( pPlayer is null || hGrunts.find( g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() ).GetValue( "model" ).ToLowercase() ) < 0 )
			return HOOK_CONTINUE;

		if( pPlayer.pev.impulse == 100 )
		{
			g_NightVision.Toggle( pPlayer );
		}

		g_NightVision.Think( pPlayer );

		return HOOK_CONTINUE;
	}

	enum NV_STATE
	{
		NV_NONE = -1,
		NV_OFF,
		NV_ON
	}

	CNightVision g_NightVision;

	final class CNightVision
	{
		int State( CBasePlayer@ pPlayer, const NV_STATE mode = NV_NONE )
		{
			if( pPlayer !is null )
			{
				string kv = "$i_fieldintensity_nightvision";

				int state = pPlayer.GetCustomKeyvalues().GetKeyvalue( kv ).GetInteger();

				if( mode != NV_NONE )
				{
					state = mode;
            		g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), kv, string( state ) );
				}
				return state;
			}
			return NV_OFF;
        }

		void Toggle( CBasePlayer@ pPlayer )
		{
			if( pPlayer !is null )
			{
				State( pPlayer, ( !pPlayer.FlashlightIsOn() ? NV_ON : NV_OFF ) );

				int iflag = State( pPlayer );
				NetworkMessage fog( MSG_ONE_UNRELIABLE, NetworkMessages::Fog, pPlayer.edict() );
					fog.WriteShort(0);
					fog.WriteByte(iflag);
					fog.WriteCoord(0);
					fog.WriteCoord(0);
					fog.WriteCoord(0);
					fog.WriteShort(0);
					fog.WriteByte(0); // R
					fog.WriteByte(10); // G
					fog.WriteByte(0); // B
					fog.WriteShort(10); // StartDist
					fog.WriteShort(500); // EndDist
				fog.End();

				NetworkMessage mlight( MSG_ONE_UNRELIABLE, NetworkMessages::NetworkMessageType(12), pPlayer.edict() );
				mlight.WriteByte( 0 );
				mlight.WriteString( iflag == NV_ON ? "z" : "m" );
				mlight.End();
			}
		}

		void Think( CBasePlayer@ pPlayer )
		{
			if( pPlayer !is null && State( pPlayer ) == NV_ON )
			{
				g_PlayerFuncs.ScreenFade( pPlayer, Vector( 40, 150, 40 ), 0.5, 0.0, 255, ( FFADE_MODULATE ) );

				NetworkMessage dlight( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
					dlight.WriteByte( TE_DLIGHT );

					dlight.WriteCoord( pPlayer.pev.origin.x );
					dlight.WriteCoord( pPlayer.pev.origin.y );
					dlight.WriteCoord( pPlayer.pev.origin.z );

					dlight.WriteByte( 32 );	// Radius
					dlight.WriteByte( 255 );
					dlight.WriteByte( 255 );
					dlight.WriteByte( 255 );
					dlight.WriteByte( 255 ); // Life
					dlight.WriteByte( 255 ); // Noise
				dlight.End();

				g_Game.AlertMessage( at_console, "Sexito\n" );
			}
		}
	}
}