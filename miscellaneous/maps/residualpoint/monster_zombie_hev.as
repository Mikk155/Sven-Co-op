/*

Wall climber Zombie
Author  :Goodman3 (https://github.com/goodman3/gm3s_svencoop_scripts)
Contact :272992860@qq.com
Special Thanks: DrAbc (https://github.com/DrAbcrealone/Abc-AngelScripts-For-Svencoop)
===================================

A modified zombie that climbs walls to reach it's enemy.

Usage: 	MonsterZombieHev::Register();

===================================

*/
namespace MonsterZombieHev
{
	const array<string> pAttackHitSounds =
	{
		"zombie/claw_strike1.wav",
		"zombie/claw_strike2.wav",
		"zombie/claw_strike3.wav",
	};
	const array<string> pAttackMissSounds =
	{
		"zombie/claw_miss1.wav",
		"zombie/claw_miss2.wav",
	};
	const array<string> pAttackSounds =
	{
		"zombie/zo_attack1.wav",
		"zombie/zo_attack2.wav",
	};
	const array<string> pIdleSounds =
	{
		"zombie/zo_idle1.wav",
		"zombie/zo_idle2.wav",
		"zombie/zo_idle3.wav",
		"zombie/zo_idle4.wav",
	};
	const array<string> pAlertSounds =
	{
		"zombie/zo_alert10.wav",
		"zombie/zo_alert20.wav",
		"zombie/zo_alert30.wav",
	};
	const array<string> pPainSounds =
	{
		"zombie/zo_pain1.wav",
		"zombie/zo_pain2.wav",
	};

	CBaseEntity@ CheckTraceHullAttack( CBaseMonster@ pThis, float flDist, int iDamage, int iDmgType ) 
	{
		TraceResult tr;

		if (pThis.IsPlayer()) 
		{
			Math.MakeVectors( pThis.pev.angles );
		} 
		else 
		{
			Math.MakeAimVectors( pThis.pev.angles );
		}

		Vector vecStart = pThis.pev.origin;
		vecStart.z += pThis.pev.size.z * 0.5;
		Vector vecEnd = vecStart + (g_Engine.v_forward * flDist );

		g_Utility.TraceHull( vecStart, vecEnd, dont_ignore_monsters, head_hull, pThis.edict(), tr );
		
		if ( tr.pHit !is null ) 
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
			if ( iDamage > 0 ) 
			{
				pEntity.TakeDamage( pThis.pev, pThis.pev, iDamage, iDmgType );
			}
			return pEntity;
		}
		return null;
	}
	
/*
class CZombie : public CBaseMonster
{
public:

	void HandleAnimEvent( MonsterEvent_t *pEvent );

	// No range attacks

*/
	const string ZOMBIE_MODEL = "models/mikk/monsters/zombie_hev.mdl";
	const float YAW_SPEED = 120;
	const int ZOMBIE_FLINCH_DELAY = 2;
	const int ZOMBIE_AE_ATTACK_RIGHT = 1;
	const int ZOMBIE_AE_ATTACK_LEFT = 2;
	const int ZOMBIE_AE_ATTACK_BOTH = 3;
	const int g_iHealth = int(g_EngineFuncs.CVarGetFloat( "sk_zombie_health" ) * 1.5);
	const int g_iOneSlash = int(g_EngineFuncs.CVarGetFloat( "sk_zombie_dmg_one_slash" ) * 0.7);
	const int g_iBothSlash = int(g_EngineFuncs.CVarGetFloat( "sk_zombie_dmg_both_slash" ) * 0.7);
	const string ZOMBIE_NAME = "Zombie Hev";
	const string FZOMBIE_NAME = "Friendly Zombie Hev";

	class CMonsterZombieHev : ScriptBaseMonsterEntity
	{
	
		private int m_iSoundVolume = 1;
		private	int m_iVoicePitch = PITCH_NORM;	
		private float m_flNextFlinch;	
		
		void Spawn()
		{
		
			Precache();
			
			g_EntityFuncs.SetModel(self, ZOMBIE_MODEL);
			g_EntityFuncs.SetSize(self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX);
			
			pev.solid			        = SOLID_SLIDEBOX;
			pev.movetype		        = MOVETYPE_STEP;
			self.m_bloodColor	        = BLOOD_COLOR_GREEN;
			if( self.pev.health == 0.0f )
			{
				self.pev.health = g_iHealth;
			}
			self.pev.view_ofs		   	= VEC_VIEW;
			self.m_flFieldOfView        = 0.5;
			self.m_MonsterState		    = MONSTERSTATE_NONE;
			self.m_afCapability			= bits_CAP_DOORS_GROUP;
			if( self.IsPlayerAlly() )
				self.m_FormattedName = FZOMBIE_NAME;
			else
				self.m_FormattedName = ZOMBIE_NAME;

			if( self.IsPlayerAlly() )
				SetUse( UseFunction( this.FollowerUse ) );

			self.MonsterInit();
		}

		int ObjectCaps( void )
		{
			if( self.IsPlayerAlly() )
				return FCAP_IMPULSE_USE;
			else
				return BaseClass.ObjectCaps();
		}

		void PainSound()
		{
			int pitch = 95 + Math.RandomLong(0,9);

			if (Math.RandomLong(0,5) < 2)
			switch (Math.RandomLong(0,1))
			{
				case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_pain1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_pain1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
			}
		
		}

		void AlertSound()
		{
			int pitch = 95 + Math.RandomLong(0,9);
			switch (Math.RandomLong(0,2))
			{
				case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_alert10.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_alert20.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 2: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_alert30.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
			}
		}	

		void IdleSound()
		{
			int pitch = 100 + Math.RandomLong(-5,5);
			switch (Math.RandomLong(0,3))
			{
				case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_idle1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_idle2.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 2: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_idle3.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 3: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_idle4.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
			}
		}	

		void AttackSound()
		{
			int pitch = 100 + Math.RandomLong(-5,5);
			switch (Math.RandomLong(0,1))
			{
				case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_attack1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "zombie/zo_attack2.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
			}
		}

		void AttackHitSound()
		{
			int pitch = 100 + Math.RandomLong(-5,5);
			switch (Math.RandomLong(0,2))
			{
				case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 2: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
			}	
		}

		void AttackMissSound()
		{
			int pitch = 100 + Math.RandomLong(-5,5);
			switch (Math.RandomLong(0,1))
			{
				case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "zombie/claw_miss1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
				case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "zombie/claw_miss1.wav", m_iSoundVolume, ATTN_NORM, 0, pitch); break;
			}	
		}

		void SetYawSpeed()
		{
			pev.yaw_speed = YAW_SPEED;
		}

		int	Classify()
		{
			return	self.GetClassification(CLASS_ALIEN_MONSTER);
		}

		void Precache()
		{
			//BaseClass.Precache();
			g_Game.PrecacheModel(ZOMBIE_MODEL);
			for(uint i = 0; i < pAttackHitSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pAttackHitSounds[i]);
			}	
			for(uint i = 0; i < pAttackMissSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pAttackMissSounds[i]);
			}			
			for(uint i = 0; i < pAttackSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pAttackSounds[i]);
			}			
			for(uint i = 0; i < pIdleSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pIdleSounds[i]);
			}
			for(uint i = 0; i < pAlertSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pAlertSounds[i]);
			}			
			for(uint i = 0; i < pPainSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pPainSounds[i]);
			}
		}	

		void TraceAttack( entvars_t@ pevAttacker, float flDamage, const Vector& in vecDir, TraceResult& in ptr, int bitsDamageType)
		{
		
			//g_Game.AlertMessage( at_console, "Hitbox: " +  ptr.iHitgroup + "\n" );
		
			if( ptr.iHitgroup == HITGROUP_HEAD || ptr.iHitgroup == HITGROUP_RIGHTARM || ptr.iHitgroup == HITGROUP_LEFTARM || ptr.iHitgroup == HITGROUP_CHEST )
			{
				self.m_bloodColor = BLOOD_COLOR_GREEN;
			}
			else
			{
				g_Utility.Sparks( ptr.vecEndPos );
				g_Utility.Ricochet( ptr.vecEndPos, 1.0 );
				self.m_bloodColor = DONT_BLEED;
				flDamage *= 0.8;
			}

			BaseClass.TraceAttack( pevAttacker, flDamage, vecDir, ptr, bitsDamageType );
		}

		int IgnoreConditions()
		{
			int iIgnore = 0;
			
			if ((self.m_Activity == ACT_MELEE_ATTACK1) || (self.m_Activity == ACT_MELEE_ATTACK1))
			{	
				if (m_flNextFlinch >= g_Engine.time)
					iIgnore |= (bits_COND_LIGHT_DAMAGE|bits_COND_HEAVY_DAMAGE);
			}

			if ((self.m_Activity == ACT_SMALL_FLINCH) || (self.m_Activity == ACT_BIG_FLINCH))
			{
				if (m_flNextFlinch < g_Engine.time)
					m_flNextFlinch = g_Engine.time + ZOMBIE_FLINCH_DELAY;
			}

			return iIgnore;
			
		}
		
		bool CheckRangeAttack1( float flDot, float flDist )
		{ 
			return false;
		}

		bool CheckRangeAttack2( float flDot, float flDist )
		{ 
			return false;
		}

		int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
		{
			if( pevAttacker is null )
				return 0;

			CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pevAttacker );

			if( self.CheckAttacker( pAttacker ) )
				return 0;

			// Take 25% damage from bullets
			if ( (bitsDamageType & DMG_BULLET) != 0 || (bitsDamageType & DMG_CLUB) != 0 || (bitsDamageType & DMG_SLASH) != 0 )
				flDamage *= 0.25;
			
			// HACK HACK -- until we fix this.
			if( self.IsAlive() )
			{
				PainSound();

				if( pevAttacker.classname == "player" )
				{
					float points = Math.min(flDamage, pev.health)*0.05f;
					pevAttacker.frags += points;
				}
			}
				
			return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
		}

		void HandleAnimEvent( MonsterEvent@ pEvent )
		{
			switch( pEvent.event )
			{
				case ZOMBIE_AE_ATTACK_RIGHT:
				{
					CBaseEntity@ pHurt = CheckTraceHullAttack(self, 70, g_iOneSlash, DMG_SLASH );
					if ( pHurt !is null )
					{
						if ( pHurt.pev.flags & ( FL_MONSTER | FL_CLIENT ) != 0 )
						{
							pHurt.pev.punchangle.z = -18;
							pHurt.pev.punchangle.x = 5;
							pHurt.pev.velocity = pHurt.pev.velocity - g_Engine.v_right * 100;
						}
						// Play a random attack hit sound
						AttackHitSound();
					}
					else
					{
						AttackMissSound();
					}
					
					if(Math.RandomLong(0,1)>0)
					{
						AttackSound();
					}
				}
				break;				
				case ZOMBIE_AE_ATTACK_LEFT:
				{
					CBaseEntity@ pHurt = CheckTraceHullAttack(self, 70, g_iOneSlash, DMG_SLASH );
					if ( pHurt !is null )
					{
					
						if ( pHurt.pev.flags & ( FL_MONSTER | FL_CLIENT ) != 0 )
						{
							pHurt.pev.punchangle.z = 18;
							pHurt.pev.punchangle.x = 5;
							pHurt.pev.velocity = pHurt.pev.velocity - g_Engine.v_right * 100;
						}
						// Play a random attack hit sound
						AttackHitSound();
					}
					else
					{
						AttackMissSound();
					}
					
					if(Math.RandomLong(0,1)>0)
					{
						AttackSound();
					}
				}
				break;
				case ZOMBIE_AE_ATTACK_BOTH:
				{
					CBaseEntity@ pHurt = CheckTraceHullAttack(self, 70, g_iBothSlash, DMG_SLASH );
					if ( pHurt !is null )
					{
					
						if ( pHurt.pev.flags & ( FL_MONSTER | FL_CLIENT ) != 0 )
						{
							pHurt.pev.punchangle.x = 5;
							pHurt.pev.velocity = pHurt.pev.velocity - g_Engine.v_right * 100;
						}
						// Play a random attack hit sound
						AttackHitSound();
					}
					else
					{
						AttackMissSound();
					}
					
					if(Math.RandomLong(0,1)>0)
					{
						AttackSound();
					}
				}
				break;
				
				default:
					BaseClass.HandleAnimEvent( pEvent );
					break;
			}
		}

		//=========================================================
		// FollowerUse
		//=========================================================
		void FollowerUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
		{
			self.FollowerPlayerUse( pActivator, pCaller, useType, flValue );
			
			CBaseEntity@ pTarget = self.m_hTargetEnt;
			
			if( pTarget is pActivator )
			{
				AlertSound();
			}
			else
			{
				IdleSound();
			}
		}
	}

array<ScriptSchedule@>@ monster_zombie_custom_schedules;
		
	ScriptSchedule slZombieWaitForClimb (
			//bits_COND_ENEMY_OCCLUDED	|
			bits_COND_NO_AMMO_LOADED,
			0,
			"ZombieWaitForClimb"
	);		
	ScriptSchedule slZombieAfterClimb (
			//bits_COND_ENEMY_OCCLUDED	|
			bits_COND_NO_AMMO_LOADED,
			0,
			"ZombieAfterClimb"
	);

	void InitSchedules()
	{
		slZombieWaitForClimb.AddTask( ScriptTask(TASK_GET_PATH_TO_ENEMY_LKP) );
		slZombieWaitForClimb.AddTask( ScriptTask(TASK_WALK_PATH) );
		slZombieWaitForClimb.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
		slZombieWaitForClimb.AddTask( ScriptTask(TASK_WAIT, 1.0) );
		slZombieAfterClimb.AddTask( ScriptTask(TASK_WAIT, 1.0) );
		slZombieAfterClimb.AddTask( ScriptTask(TASK_TURN_RIGHT) );
		slZombieAfterClimb.AddTask( ScriptTask(TASK_TURN_RIGHT) );
		slZombieAfterClimb.AddTask( ScriptTask(TASK_TURN_RIGHT) );
		array<ScriptSchedule@> scheds = {slZombieWaitForClimb,slZombieAfterClimb};
		@monster_zombie_custom_schedules = @scheds;
		//g_taskWait = ScriptTask(TASK_WAIT, 1.0);
	}

	void Register()
	{
		InitSchedules();
		g_CustomEntityFuncs.RegisterCustomEntity( "MonsterZombieHev::CMonsterZombieHev", "monster_zombie_hev" );
	}
}