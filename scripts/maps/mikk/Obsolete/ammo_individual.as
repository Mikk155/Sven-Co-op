// Moved to ammo_custom

/*
	A custom script that will add new ammunition to the game. this ammunitions has a special feature.
	Every item will be able to be take'd ONCE Per player. an attempt to play with the same ammo ammout as HLSP campaigns.

	Credits:
	Mikk idea
	Gaftherman Script
	
	
#include "gaftherman/misc/ammo_individual"

void MapInit()
{
	RegisterAmmoIndividual();
}

void MapActivate()
{
	AmmoIndividualRemap();
}



	If you're mapper then you can use this by 2 diferent ways.
	
	1 - Hardcode the classnames in your maps and do not use AmmoIndividualRemap()
	2 - use AmmoIndividualRemap() and exclude some items by adding custom keyvalue "$i_ignore_item"
	
	CTRL+F "-Planned"
*/

/*enum ammo_individual
{
    SF_AI_START_OFF = 1 << 0, //Mis huevos Can't pick up - Moved to flag 384 ( TOUCH + USE ONLY )
	SF_AI_USE_ONLY = 1 << 1 - Moved to flag 256 ( USE ONLY )
	
	Gaf turkey. usa stock flags. p pavo -Mikk gaming
}*/

void RegisterAmmoIndividual()
{
	DefaultRegister( "ammo_9mmclip_individual" );
	DefaultRegister( "ammo_9mmAR_individual" );
	DefaultRegister( "ammo_9mmbox_individual" );
	DefaultRegister( "ammo_buckshot_individual" );
	DefaultRegister( "ammo_ARgrenades_individual" );
	DefaultRegister( "ammo_357_individual" );
	DefaultRegister( "ammo_762_individual" );
	DefaultRegister( "ammo_556_individual" );
	DefaultRegister( "ammo_556clip_individual" );
	DefaultRegister( "ammo_crossbow_individual" );
	DefaultRegister( "ammo_gaussclip_individual" );
	DefaultRegister( "ammo_rpgclip_individual" );
	DefaultRegister( "ammo_sporeclip_individual" );
	DefaultRegister( "ammo_uziclip_individual" );
	DefaultRegister( "ammo_medkit_individual" );
	DefaultRegister( "ammo_snarks_individual" );
	DefaultRegister( "ammo_handgrenade_individual" );
	DefaultRegister( "ammo_tripmine_individual" );
	DefaultRegister( "item_battery_individual" );
	DefaultRegister( "item_healthkit_individual" );
	DefaultRegister( "weaponbox_individual" );
	DefaultRegister( "ammo_satchel_individual" ); // Mis huevos se van a bugear.
	//DefaultRegister( "func_recharge_individual" );
}

void AmmoIndividualRemap()
{
	Reemplazar( "ammo_9mmbox", "ammo_9mmbox_individual" );
	Reemplazar( "ammo_glockclip", "ammo_9mmclip_individual" );
	Reemplazar( "ammo_9mmclip", "ammo_9mmclip_individual" );
	Reemplazar( "ammo_9mmAR", "ammo_9mmAR_individual" );
	Reemplazar( "ammo_buckshot", "ammo_buckshot_individual" );
	Reemplazar( "ammo_ARgrenades", "ammo_ARgrenades_individual" );
	Reemplazar( "ammo_357", "ammo_357_individual" );
	Reemplazar( "ammo_762", "ammo_762_individual" );
	Reemplazar( "ammo_556", "ammo_556_individual" );
	Reemplazar( "ammo_556clip", "ammo_556clip_individual" );
	Reemplazar( "ammo_crossbow", "ammo_crossbow_individual" );
	Reemplazar( "ammo_gaussclip", "ammo_gaussclip_individual" );
	Reemplazar( "ammo_rpgclip", "ammo_rpgclip_individual" );
	Reemplazar( "ammo_sporeclip", "ammo_sporeclip_individual" );
	Reemplazar( "ammo_uziclip", "ammo_uziclip_individual" );
	Reemplazar( "ammo_medkit", "ammo_medkit_individual" );
	Reemplazar( "weapon_snark", "ammo_snarks_individual" );
	Reemplazar( "weapon_handgrenade", "ammo_handgrenade_individual" );
	Reemplazar( "weapon_tripmine", "ammo_tripmine_individual" );
	Reemplazar( "item_battery", "item_battery_individual" );
	Reemplazar( "item_healthkit", "item_healthkit_individual" );
	Reemplazar( "weapon_satchel", "ammo_satchel_individual" );
	//Reemplazar( "func_recharge_individual", "func_recharge_individual" ); Pavo. para cuando? hacer esto en serio me gano. -Planned
}

class weaponbox_individual : ScriptBasePlayerItemEntity, ammo_base
{	
	private int m_il9mm, m_ilbuckshot, m_ilARgrenades, m_ilTM, m_ilHG, m_ilsnarks, m_ilsporeclip, m_ilrockets, m_iluranium, m_ilbolts, m_il556, m_il357, m_ilm40a1;
	private array<string> Names;
	private array<int> Values;
	private array<int> MaxAmmo;

	void Spawn()
	{
		SpawnDefault( "models/w_weaponbox.mdl" );
	}

	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
		if( szKey == "9mm" ) 
		{
			m_il9mm = atoi( szValue );
			return true;
		} 
		else if( szKey == "buckshot" ) 
		{
			m_ilbuckshot = atoi( szValue );
			return true;
		} 
		else if( szKey == "ARgrenades" ) 
		{
			m_ilARgrenades = atoi( szValue );
			return true;
		} 
		else if( szKey == "Trip Mine" || szKey == "TM"  ) 
		{
			m_ilTM = atoi( szValue );
			return true;
		} 
		else if( szKey == "Hand Grenade" || szKey == "HG" ) 
		{
			m_ilHG = atoi( szValue );
			return true;
		} 
		else if( szKey == "snarks" ) 
		{
			m_ilsnarks = atoi( szValue );
			return true;
		} 
		else if( szKey == "sporeclip" ) 
		{
			m_ilsporeclip = atoi( szValue );
			return true;
		} 
		else if( szKey == "rockets" ) 
		{
			m_ilrockets = atoi( szValue );
			return true;
		} 
		else if( szKey == "uranium" ) 
		{
			m_iluranium = atoi( szValue );
			return true;
		} 
		else if( szKey == "bolts" ) 
		{
			m_ilbolts = atoi( szValue );
			return true;
		} 
		else if( szKey == "556" ) 
		{
			m_il556 = atoi( szValue );
			return true;
		} 
		else if( szKey == "357" ) 
		{
			m_il357 = atoi( szValue );
			return true;
		} 
		else if( szKey == "m40a1" ) 
		{
			m_ilm40a1 = atoi( szValue );
			return true;
		}/*
		else if( szKey == "satchel" ) -not added yet. Meanwhile use this value if you want.
		{
			m_ilm40a1 = atoi( szValue );
			return true;
		} Maybe value para el satchel? Algún dia. -Planned */
		else 
			return BaseClass.KeyValue( szKey, szValue );
    }

	bool AddAmmo( CBaseEntity@ pOther )
	{
		if( m_il9mm != 0 )
		{
			Values.insertLast( m_il9mm );
			Names.insertLast( "9mm" );
			MaxAmmo.insertLast( 255 );
		}

		if( m_ilbuckshot != 0 )
		{
			Values.insertLast( m_ilbuckshot );
			Names.insertLast( "buckshot" );
			MaxAmmo.insertLast( 125 );
		}

		if( m_ilARgrenades != 0 )
		{
			Values.insertLast( m_ilARgrenades );
			Names.insertLast( "ARgrenades" );
			MaxAmmo.insertLast( 10 );
		}

		if( m_ilTM != 0 )
		{
			Values.insertLast( m_ilTM );
			Names.insertLast( "Trip Mine" );
			MaxAmmo.insertLast( 5 );
		}

		if( m_ilHG != 0 )
		{
			Values.insertLast( m_ilHG );
			Names.insertLast( "Hand Grenade" );
			MaxAmmo.insertLast( 10 );
		}

		if( m_ilsnarks != 0 )
		{
			Values.insertLast( m_ilsnarks );
			Names.insertLast( "snarks" );
			MaxAmmo.insertLast( 15 );
		}

		if( m_ilsporeclip != 0 )
		{
			Values.insertLast( m_ilsporeclip );
			Names.insertLast( "sporeclip" );
			MaxAmmo.insertLast( 30 );
		}

		if( m_ilrockets != 0 )
		{
			Values.insertLast( m_ilrockets );
			Names.insertLast( "rockets" );
			MaxAmmo.insertLast( 5 );
		}

		if( m_iluranium != 0 )
		{
			Values.insertLast( m_iluranium );
			Names.insertLast( "uranium" );
			MaxAmmo.insertLast( 100 );
		}

		if( m_ilbolts != 0 )
		{
			Values.insertLast( m_ilbolts );
			Names.insertLast( "bolts" );
			MaxAmmo.insertLast( 50 );
		}

		if( m_il556 != 0 )
		{
			Values.insertLast( m_il556 );
			Names.insertLast( "556" );
			MaxAmmo.insertLast( 600 );
		}

		if( m_ilm40a1 != 0 )
		{
			Values.insertLast( m_ilm40a1 );
			Names.insertLast( "m40a1" );
			MaxAmmo.insertLast( 15 );
		}

		if( m_il357 != 0 )
		{
			Values.insertLast( m_il357 );
			Names.insertLast( "357" );
			MaxAmmo.insertLast( 36 );
		}

		return AddAmmoDefault2( cast<CBasePlayer@>( pOther ), Values, Names, MaxAmmo ); 
	}
}

class ammo_9mmclip_individual : ScriptBasePlayerItemEntity, ammo_base
{	
	void Spawn()
	{
		SpawnDefault( "models/w_9mmclip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 17, "9mm", 255 );
	}
}

class ammo_9mmAR_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_mp5_clip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 30, "9mm", 255 );
	}
}

class ammo_9mmbox_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_chainammo.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 200, "9mm", 255 );
	}
}

class ammo_buckshot_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_shotbox.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 12, "buckshot", 125 );
	}
}

class ammo_ARgrenades_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_argrenade.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 2, "ARgrenades", 10 );
	}
}

class ammo_357_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_357ammobox.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 6, "357", 36 );
	}
}

class ammo_762_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_m40a1clip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 5, "m40a1", 15 );
	}
}

class ammo_556_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_saw_clip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 100, "556", 600 );
	}
}

class ammo_556clip_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_9mmarclip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 30, "556", 600 );
	}
}

class ammo_crossbow_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_crossbow_clip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 5, "bolts", 50 );
	}
}

class ammo_gaussclip_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_gaussammo.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 20, "uranium", 100 );
	}
}

class ammo_rpgclip_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_rpgammo.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 1, "rockets", 5 );
	}
}

class ammo_sporeclip_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/spore.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 1, "sporeclip", 30 );
	}
}

class ammo_uziclip_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_uzi_clip.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 32, "9mm", 255 );
	}
}

class ammo_medkit_individual : ScriptBasePlayerItemEntity, ammo_base
{
	void Spawn()
	{
		SpawnDefault( "models/w_medkit.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), 50, "health", 100 );
	}
}

class ammo_snarks_individual : ScriptBasePlayerItemEntity, ammo_base_c
{
	void Spawn()
	{
		SpawnDefault( "models/w_sqknest.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), "weapon_snark", "snarks", 15 );
	}
}

class ammo_satchel_individual : ScriptBasePlayerItemEntity, ammo_base_c
{
	void Spawn()
	{
		SpawnDefault( "models/w_satchel.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), "weapon_satchel", "Satchel Charge", 5 );
	}
}

class ammo_handgrenade_individual : ScriptBasePlayerItemEntity, ammo_base_c 
{
	void Spawn()
	{
		SpawnDefault( "models/w_grenade.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), "weapon_handgrenade", "Hand Grenade", 10 );
	}
}

class ammo_tripmine_individual : ScriptBasePlayerItemEntity, ammo_base_c 
{
	void Spawn()
	{
		SpawnDefault( "models/w_tripmine.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return AddAmmoDefault( cast<CBasePlayer@>( pOther ), "weapon_tripmine", "Trip Mine", 5 );
	}
}

class item_battery_individual : ScriptBasePlayerItemEntity
{
	private bool Activated = true;
	dictionary g_MaxPlayers;

	void Spawn()
	{ 
		Precache();

		if( self.SetupModel() == false )
			g_EntityFuncs.SetModel( self, "models/w_battery.mdl" );
		else //Custom model
			g_EntityFuncs.SetModel( self, self.pev.model );

        if( self.pev.SpawnFlagBitSet( 384 )  )
		{	
            Activated = false;
		}
		
		BaseClass.Spawn();
	}

	void Precache()
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel("models/w_battery.mdl");
		else //Custom model
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound("items/gunpickup2.wav");
	}
		
	void AddArmor( CBasePlayer@ pPlayer )
	{	
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        int pct;

		if( pPlayer is null || pPlayer.pev.armorvalue >= 100 && pPlayer.HasSuit() || !pPlayer.HasSuit() || g_MaxPlayers.exists(steamId)  )
			return;
		
        g_MaxPlayers[steamId] = @pPlayer;

		pPlayer.pev.armorvalue += int(g_EngineFuncs.CVarGetFloat( "sk_battery" ));
		pPlayer.pev.armorvalue = Math.min( pPlayer.pev.armorvalue, 100 );

		//Battery sound
		g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
					
		NetworkMessage msg( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
			msg.WriteString( "item_battery" );
		msg.End();

		// Suit reports new power level
		// For some reason this wasn't working in release build -- round it.
		pct = int(float(pPlayer.pev.armorvalue * 100.0) * (1.0 / 100) + 0.5);
		pct = (pct / 5);
		if (pct > 0)
			pct--;

		//EMIT_SOUND_SUIT(ENT(pev), szcharge);
		pPlayer.SetSuitUpdate( "!HEV_" + pct + "P", false, 30 );
				
		// Trigger targets
		self.SUB_UseTargets( pPlayer, USE_TOGGLE, 0 );
	}

	void Touch( CBaseEntity@ pOther )
	{
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() || !Activated || self.pev.SpawnFlagBitSet( 256 ) )
			return;
				
		AddArmor( cast<CBasePlayer@>( pOther ) );
	}
		
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
        if( self.pev.SpawnFlagBitSet( 384 ) && !Activated )
		{	
            Activated = !Activated;
		}

		if( pActivator.IsPlayer() && Activated )
		{
			AddArmor( cast<CBasePlayer@>( pActivator ) );
		}
	}		
}

class item_healthkit_individual : ScriptBasePlayerItemEntity
{
	private bool Activated = true;
	dictionary g_MaxPlayers;

	void Spawn()
	{ 
		Precache();

		if( self.SetupModel() == false )
			g_EntityFuncs.SetModel( self, "models/w_medkit.mdl" );
		else //Custom model
			g_EntityFuncs.SetModel( self, self.pev.model );

        if( self.pev.SpawnFlagBitSet( 384 )  )
		{	
            Activated = false;
		}

		BaseClass.Spawn();
	}

	void Precache()
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel("models/w_medkit.mdl");
		else //Custom model
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound("items/smallmedkit1.wav");
	}
		
	void AddHealth( CBasePlayer@ pPlayer )
	{	
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		if( pPlayer is null || pPlayer.pev.health == pPlayer.pev.max_health || g_MaxPlayers.exists(steamId)  )
			return;
			
		pPlayer.TakeHealth( g_EngineFuncs.CVarGetFloat( "sk_healthkit" ), DMG_GENERIC );

        g_MaxPlayers[steamId] = @pPlayer;

		NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
			message.WriteString( "item_healthkit" );
		message.End();

		g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, "items/smallmedkit1.wav", 1, ATTN_NORM );

        // Trigger targets
        self.SUB_UseTargets( pPlayer, USE_TOGGLE, 0 );
	}

	void Touch( CBaseEntity@ pOther )
	{
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() || !Activated || self.pev.SpawnFlagBitSet( 256 ) )
			return;
				
		AddHealth( cast<CBasePlayer@>( pOther ) );
	}
		
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
        if( self.pev.SpawnFlagBitSet( 384 ) && !Activated )
		{	
            Activated = !Activated;
		}

		if( pActivator.IsPlayer() && Activated )
		{
			AddHealth( cast<CBasePlayer@>( pActivator ) );
		}
	}		
}

mixin class ammo_base
{
	private bool Activated = true;
	dictionary g_MaxPlayers;

	void SpawnDefault( string ammo_model )
	{ 
		PrecacheDefault( ammo_model );

		if( self.SetupModel() == false )
			g_EntityFuncs.SetModel( self, ammo_model );
		else //Custom model
			g_EntityFuncs.SetModel( self, self.pev.model );

        if( self.pev.SpawnFlagBitSet( 384 )  )
		{	
            Activated = false;
		}

		BaseClass.Spawn();
	}

	void PrecacheDefault( string ammo_model )
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( ammo_model );
		else //Custom model
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmoDefault( CBasePlayer@ pPlayer, int& in GiveAmmo, string& in Type, int& in MaxAmmo  ) 
	{ 
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		if( pPlayer is null  )
			return false;

		if( !g_MaxPlayers.exists(steamId) )
		{
			if( pPlayer.GiveAmmo( GiveAmmo, Type, MaxAmmo ) != -1 )
			{
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
			}
			g_MaxPlayers[steamId] = @pPlayer;
			return true;
		}
		return false;
	}

	bool AddAmmoDefault2( CBasePlayer@ pPlayer, array<int> GiveAmmo, array<string> Type, array<int> MaxAmmo ) 
	{ 
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		if( pPlayer is null  )
			return false;

		if( !g_MaxPlayers.exists(steamId) )
		{
			g_EngineFuncs.ServerPrint( "Length: "+GiveAmmo.length()+"\n" );

			for( uint i = 0; i < GiveAmmo.length(); ++i ) 
			{
				if( pPlayer.GiveAmmo( GiveAmmo[i], Type[i], MaxAmmo[i] ) != -1 )
				{
					g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
				}
			}
			g_MaxPlayers[steamId] = @pPlayer;
			return true;
		}
		return false;
	}

	void Touch( CBaseEntity@ pOther )
	{
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() || !Activated || self.pev.SpawnFlagBitSet( 256 ) )
			return;
				
		AddAmmo( cast<CBasePlayer@>( pOther ));
	}
		
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
        if( self.pev.SpawnFlagBitSet( 384 ) && !Activated )
		{	
            Activated = !Activated;
		}

		if( pActivator.IsPlayer() && Activated )
		{
			AddAmmo( cast<CBasePlayer@>( pActivator ));
		}
	}	
}

mixin class ammo_base_c
{
	private bool Activated = true;
	dictionary g_MaxPlayers;

	void SpawnDefault( string ammo_model )
	{ 
		PrecacheDefault( ammo_model );

		if( self.SetupModel() == false )
			g_EntityFuncs.SetModel( self, ammo_model );
		else //Custom model
			g_EntityFuncs.SetModel( self, self.pev.model );

        if( self.pev.SpawnFlagBitSet( 384 )  )
		{	
            Activated = false;
		}

		BaseClass.Spawn();
	}

	void PrecacheDefault( string ammo_model )
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( ammo_model );
		else //Custom model
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmoDefault( CBasePlayer@ pPlayer, string& in Type2, string& in Type, int& in MaxAmmo  ) 
	{ 
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		if( pPlayer is null  )
			return false;

		if( !g_MaxPlayers.exists(steamId) )
		{
			if( pPlayer.GiveAmmo( 0, Type, MaxAmmo ) != -1 )
			{
				g_MaxPlayers[steamId] = @pPlayer;

				pPlayer.GiveNamedItem( Type2 );

				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
				return true;
			}
		}
		return false;
	}

	void Touch( CBaseEntity@ pOther )
	{
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() || !Activated || self.pev.SpawnFlagBitSet( 256 ) )
			return;
				
		AddAmmo( cast<CBasePlayer@>( pOther ));
	}
		
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
        if( self.pev.SpawnFlagBitSet( 384 ) && !Activated )
		{	
            Activated = !Activated;
		}

		if( pActivator.IsPlayer() && Activated )
		{
			AddAmmo( cast<CBasePlayer@>( pActivator ));
		}
	}	
}

void DefaultRegister( string ammo_name )
{
	g_CustomEntityFuncs.RegisterCustomEntity( ammo_name, ammo_name );
    g_ItemRegistry.RegisterItem( ammo_name, "" );
	g_Game.PrecacheOther( ammo_name );
}

void Reemplazar( string item_para_buscar, string item_para_reemplazar )
{
    for( int i = 0; i < g_Engine.maxEntities; ++i ) 
    {
        CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );

        if( pEntity is null ) 
			continue;

        if( pEntity.pev.classname != item_para_buscar )
			continue;
			
		if( pEntity.GetCustomKeyvalues().HasKeyvalue( "$i_ignore_item" ) )
			continue;
			
		g_EntityFuncs.Create( item_para_reemplazar, pEntity.pev.origin, pEntity.pev.angles, false);// Keep spawnflags del anterior? -Planned
		g_EntityFuncs.Remove( pEntity );
    }
}