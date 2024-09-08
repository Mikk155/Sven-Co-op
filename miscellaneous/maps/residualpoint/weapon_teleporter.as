/*  
* The original Half-Life version of the mp5
*/

enum Mp5Animation
{
	MP5_LONGIDLE = 0,
	MP5_IDLE1,
	MP5_LAUNCH,
	MP5_RELOAD,
	MP5_DEPLOY,
	MP5_FIRE1,
	MP5_FIRE2,
	MP5_FIRE3,
};

const int MP5_DEFAULT_GIVE 	= 999;
const int MP5_DEFAULT_GIVE2 = 200;
const int MP5_MAX_AMMO		= 999;
const int MP5_MAX_AMMO2 	= 200;
const int MP5_MAX_CLIP 		= 50;
const int MP5_WEIGHT 		= 5;

class weapon_hlmp5 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int m_iShell;
	int	m_iSecondaryAmmo;
	int m_iSprModel;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/mikk/weapons/w_teleporter.mdl" );

		self.m_iDefaultAmmo = MP5_DEFAULT_GIVE;
		self.m_iDefaultSecAmmo = MP5_DEFAULT_GIVE2;

		self.m_iSecondaryAmmoType = 0;
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/mikk/weapons/v_teleporter.mdl" );
		g_Game.PrecacheModel( "models/mikk/weapons/w_teleporter.mdl" );
		g_Game.PrecacheModel( "models/p_displacer.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		m_iSprModel = g_Game.PrecacheModel( "sprites/dot.spr" );
		g_Game.PrecacheModel( "sprites/laserbeam.spr" );
		g_Game.PrecacheModel( "sprites/glow01.spr" );

		g_Game.PrecacheModel( "models/grenade.mdl" );

		g_Game.PrecacheModel( "models/w_9mmARclip.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );              

		//These are played by the model, needs changing there
		g_SoundSystem.PrecacheSound( "hl/items/clipinsert1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/cliprelease1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/guncock1.wav" );

		g_SoundSystem.PrecacheSound( "hl/weapons/hks1.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/hks2.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/hks3.wav" );

		g_SoundSystem.PrecacheSound( "hl/weapons/glauncher.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/glauncher2.wav" );

		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= MP5_MAX_AMMO;
		info.iMaxAmmo2 	= MP5_MAX_AMMO2;
		info.iMaxClip 	= MP5_MAX_CLIP;
		info.iSlot 		= 2;
		info.iPosition 	= 4;
		info.iFlags 	= 0;
		info.iWeight 	= MP5_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
			
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();

		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/mikk/weapons/v_teleporter.mdl" ), self.GetP_Model( "models/p_displacer.mdl" ), MP5_DEPLOY, "mp5" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void PrimaryAttack()
	{
		g_EngineFuncs.MakeVectors(m_pPlayer.pev.v_angle);
		Vector vecSrc = m_pPlayer.GetOrigin() + m_pPlayer.pev.view_ofs;
		Vector vecAiming = g_Engine.v_forward;	

		TraceResult tr;
		g_Utility.TraceHull(vecSrc, vecSrc + vecAiming * 2000, dont_ignore_monsters, human_hull, m_pPlayer.edict(), tr);
		Vector endResult = tr.vecEndPos;	

			// don't fire underwater					   // Out of ammo		//Couldn't find anywhere to put it.
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 || tr.flFraction == 1.0 || tr.flFraction == 0.0 || tr.fAllSolid != 0)
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			return;
		}

		Test();

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( MP5_FIRE1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( MP5_FIRE2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( MP5_FIRE3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/hks1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );	

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.5;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		
		m_pPlayer.SetOrigin(endResult);
		m_pPlayer.pev.velocity = Vector(0,0,0);
		m_pPlayer.pev.flFallVelocity = 0.0f;
	}

	void SecondaryAttack()
	{
			// don't fire underwater					   // Out of ammo
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
			return;
		}

		Test();

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		m_pPlayer.m_iExtraSoundTypes = bits_SOUND_DANGER;
		m_pPlayer.m_flStopExtraSoundTime = WeaponTimeBase() + 0.2;

		m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) - 1 );

		m_pPlayer.pev.punchangle.x = -10.0;

		self.SendWeaponAnim( MP5_LAUNCH );

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		if ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) != 0 )
		{
			// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/glauncher.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		else
		{
			// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/glauncher2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
	
		Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );

		// we don't add in player velocity anymore.
		if( ( m_pPlayer.pev.button & IN_DUCK ) != 0 )
		{
			g_EntityFuncs.ShootBananaCluster( m_pPlayer.pev, 
								m_pPlayer.pev.origin + g_Engine.v_forward * 16 + g_Engine.v_right * 6, 
								g_Engine.v_forward * 900 ); //800
		}
		else
		{
			g_EntityFuncs.ShootBananaCluster( m_pPlayer.pev, 
								m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs * 0.5 + g_Engine.v_forward * 16 + g_Engine.v_right * 6, 
								g_Engine.v_forward * 900 ); //800
		}
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 5;// idle pretty soon after shooting.

		if( m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 )
			// HEV suit - indicate out of ammo condition
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
	}

	void Reload()
	{
		self.DefaultReload( MP5_MAX_CLIP, MP5_RELOAD, 1.5, 0 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void Test()
	{		
		g_EngineFuncs.MakeVectors(m_pPlayer.pev.v_angle);
		Vector vecSrc = m_pPlayer.GetOrigin() + m_pPlayer.pev.view_ofs;
		Vector vecAiming = g_Engine.v_forward;	

		TraceResult tr;
		g_Utility.TraceHull(vecSrc, vecSrc + vecAiming * 2000, dont_ignore_monsters, human_hull, m_pPlayer.edict(), tr);
		Vector endResult = tr.vecEndPos;

		if( tr.flFraction == 0.0f || tr.flFraction <= 0.001f)
			g_Game.AlertMessage( at_console, "Distancia Total: " + "%1" + "\n", "Estas muy cerca, alejate aweonao" );
		else if( tr.flFraction == 1.0f )
			g_Game.AlertMessage( at_console, "Distancia Total: " + "%1" + "\n", "Donde apuntas esta muy lejos pavo :turkey:" );
		else
			g_Game.AlertMessage( at_console, "Distancia Total: " + "%1" + "\n", int(tr.flFraction * 1000) );

		NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, pev.origin );
			message.WriteByte( TE_BEAMSPRITE );
			message.WriteCoord( vecSrc.x ); // Vector start x
			message.WriteCoord( vecSrc.y ); // Vector start y 
			message.WriteCoord( vecSrc.z ); // Vector start z
			message.WriteCoord( endResult.x ); // Vector end x
			message.WriteCoord( endResult.y ); // Vector end y
			message.WriteCoord( endResult.z ); // Vector end z
			message.WriteShort( g_EngineFuncs.ModelIndex("sprites/laserbeam.spr") );
			message.WriteShort( g_EngineFuncs.ModelIndex("sprites/glow01.spr") );
		message.End();

		NetworkMessage message2( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
			message2.WriteByte( TE_SPRITE );
			message2.WriteCoord( endResult.x );	// pos x
			message2.WriteCoord( endResult.y ); // pos y
			message2.WriteCoord( endResult.z ); // pos z
			message2.WriteShort( m_iSprModel );	// model
			message2.WriteByte( 10 );			// size * 10
			message2.WriteByte( 255 );			// brightness
		message2.End();
	}

	void WeaponIdle()
	{
		Test();

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
		case 0:	
			iAnim = MP5_LONGIDLE;	
			break;
		
		case 1:
			iAnim = MP5_IDLE1;
			break;
			
		default:
			iAnim = MP5_IDLE1;
			break;
		}

		self.SendWeaponAnim( iAnim );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );// how long till we do this again.
	}
}

string GetHLMP5Name()
{
	return "weapon_hlmp5";
}

void RegisterHLMP5()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlmp5", GetHLMP5Name() );
	g_ItemRegistry.RegisterWeapon( GetHLMP5Name(), "hl_weapons", "municion imaginaria", "granadas imaginarias" );
}
