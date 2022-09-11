/*
	Simple plugin i've did for UHS's owner onichan demand
	
	"plugin"
	{
		"name" "Halloween"
		"script" "mikk/Halloween"
	}
*/

dictionary keyvalues;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

void MapInit()
{
	HALLOWEEN::PrecacheThing();
}

void MapStart()
{
	HALLOWEEN::SpawnEntities();
	HALLOWEEN::ChangeModelos();
   @HALLOWEEN::g_entity = g_Scheduler.SetInterval( "Entitys", 17 );
	g_Scheduler.SetInterval( "ReloadModels", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
	
}

const array<string> ArrayCandys = {
	"ammo_9mmclip",
	"ammo_357",
	"ammo_762",
	"ammo_556clip",
	"ammo_ARgrenades",
	"ammo_buckshot",
	"ammo_crossbow",
	"ammo_gaussclip",
	"ammo_rpgclip",
	"ammo_sporeclip",
	"weapon_357",
	"weapon_9mmAR",
	"weapon_9mmhandgun",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_displacer",
	"weapon_eagle",
	"weapon_egon",
	"weapon_gauss",
	"weapon_grapple",
	"weapon_handgrenade",
	"weapon_m16",
	"weapon_hornetgun",
	"weapon_m249",
	"weapon_pipewrench",
	"weapon_medkit",
	"weapon_minigun",
	"weapon_satchel",
	"weapon_rpg",
	"weapon_shockrifle",
	"weapon_snark",
	"weapon_sporelauncher",
	"weapon_sniperrifle",
	"weapon_shotgun",
	"weapon_tripmine",
	"weapon_uzi",
	"weapon_uziakimbo",
	"monster_handgrenade",
	"monster_snark",
	"monster_headcrab",
	"monster_stukabat",
	"monster_sqknest",
	"monster_shockroach",
	"monster_babycrab"
};

const array<string> ArrayPrecacheModels = {
	"islave",
	"agrunt",
	"garg",
	"gonome",
	"candy",
	"big_mom",
	"controller",
	"controller",
	"hassassin",
	"hgrunt",
	"hgrunt_devil",
	"hgrunt_scarecrow",
	"houndeye",
	"hornet",
	"isare",
	"scientist",
	"zombie"
};

const array<string> ArrayMonsters = {
	"monster_scientist",
	"monster_alien_slave",
	"monster_human_assassin",
	"monster_houndeye",
	"monster_alien_controller",
	"monster_alien_grun",
	"monster_gonome",
	"monster_gargantua",
	"monster_bigmomma",
	"monster_zombie*"
};

void ReloadModels()
{
	CBaseEntity@ pMonster = null;
	while((@pMonster = g_EntityFuncs.FindEntityByClassname(pMonster, "monster_*")) !is null)
	{
		for( uint i = 0; i < ArrayMonsters.length(); i++ )
		{
			if( string( pMonster.pev.classname ) == ArrayMonsters[i] and !string( pMonster.pev.model ).StartsWith ("models/halloween"))
			{
				// It was monster_human_grunt but i've removed it since those models doesn't have animations for shooting.
				// Weak shit. i need to learn modeling x[
				if( string(pMonster.pev.classname).StartsWith ("monster_zombie") )
				{
					HALLOWEEN::FireTargets( "halloween_hgrunt_"+ int(Math.RandomFloat( 0, 3 )) , pMonster );
					g_Game.AlertMessage( at_console, "Changed model "+pMonster.pev.classname+"\n" );
				}
				else if( pMonster.pev.classname == "monster_alien_slave" )
				{
					HALLOWEEN::FireTargets( "halloween_monster_alien_slave_"+ int(Math.RandomFloat( 0, 1 )) , pMonster );
					g_Game.AlertMessage( at_console, "Changed model "+pMonster.pev.classname+"\n" );
				}
				else if( pMonster.IsAlive() )
				{
					HALLOWEEN::FireTargets( "halloween_"+pMonster.pev.classname, pMonster );
					g_Game.AlertMessage( at_console, "Changed model "+pMonster.pev.classname+"\n" );
				}
			}
		}
	}

	CBaseEntity@ pCandys = null;
	while((@pCandys = g_EntityFuncs.FindEntityByClassname(pCandys, "ammo_*")) !is null)
	{
		if( !string( pCandys.pev.model ).StartsWith ("models/halloween") )
		{
			HALLOWEEN::FireTargets( "halloween_candy", pCandys );
			g_Game.AlertMessage( at_console, "Changed model "+pCandys.pev.classname+"\n" );
		}
	}
}

// Start of Angela Luna's code

//DeadDrop
//Created by Angela Luna 
//Discord ".Angela14#0002"

CScheduledFunction@ g_explosion = null;
const int e_rat = 1; 

namespace HALLOWEEN
{
	CScheduledFunction@ g_entity = null;

	void Entitys()
	{
		CBaseEntity@ rat = null;

		while( ( @rat = g_EntityFuncs.FindEntityByClassname( rat, "monster_*" ) ) !is null )
		{
			if( !string(rat.pev.classname).EndsWith ("dead") ) // Fix for dead body doing infinite drops
			{
				float flRandom = Math.RandomFloat( 0, 1 );

				if( flRandom <= 0.50 )
				{
					if( rat.IsAlive() == false || rat.pev.health < -1)
					{
						array<CBaseEntity@> booms(e_rat);	
						
						for (int y = 0; y < e_rat; ++y) 
						{
							@booms[y] = g_EntityFuncs.Create( ArrayCandys[Math.RandomLong( 0, ArrayCandys.length()-1 )] ,rat.pev.origin + Vector(Math.RandomLong(0, 0), Math.RandomLong(0, 0), 0 ), Vector(0, 0, 0), false);	  
							g_Game.AlertMessage( at_console, "Created Candybox by "+rat.pev.classname+"\n" );
						}
					}
				}
			}
		}
	}

// End of Angela Luna's code

	void PrecacheThing()
	{
		for( uint i = 0; i < ArrayCandys.length(); i++ )
		{
			g_Game.PrecacheOther( ArrayCandys[i] );
		}
		
		g_Game.PrecacheGeneric( "gfx/env/blackbk.tga" );
		g_Game.PrecacheGeneric( "gfx/env/blackdn.tga" );
		g_Game.PrecacheGeneric( "gfx/env/blackft.tga" );
		g_Game.PrecacheGeneric( "gfx/env/blacklf.tga" );
		g_Game.PrecacheGeneric( "gfx/env/blackrt.tga" );
		g_Game.PrecacheGeneric( "gfx/env/blackup.tga" );
		
		g_Game.PrecacheGeneric( "gfx/env/blackbk.bmp" );
		g_Game.PrecacheGeneric( "gfx/env/blackdn.bmp" );
		g_Game.PrecacheGeneric( "gfx/env/blackft.bmp" );
		g_Game.PrecacheGeneric( "gfx/env/blacklf.bmp" );
		g_Game.PrecacheGeneric( "gfx/env/blackrt.bmp" );
		g_Game.PrecacheGeneric( "gfx/env/blackup.bmp" );

		for( uint i = 0; i < ArrayPrecacheModels.length(); i++ )
		{
			g_Game.PrecacheModel( "models/halloween/"+ArrayPrecacheModels[i]+".mdl" );
			g_Game.PrecacheGeneric( "models/halloween/"+ArrayPrecacheModels[i]+".mdl" );
		}
	}

	void SpawnEntities()
	{
		keyvalues =	{ { "pattern", "d"}, { "targetname", "MapStarts" } };
		g_EntityFuncs.CreateEntity( "global_light_control", keyvalues, true );
		keyvalues =	{ { "spawnflags", "5"}, { "skyname", "black" }, { "targetname", "MapStarts" } };
		g_EntityFuncs.CreateEntity( "trigger_changesky", keyvalues, true );
		keyvalues =	{ { "delay", "0.5"}, { "target", "MapStarts" } };
		g_EntityFuncs.CreateEntity( "trigger_auto", keyvalues, true );
	}

	void ChangeModelos()
	{
		keyvalues =
		{
			{ "model",	"models/halloween/scientist.mdl" },
			{ "targetname", "halloween_monster_scientist" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/islave.mdl" },
			{ "targetname", "halloween_monster_alien_slave_1" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/isare.mdl" },
			{ "targetname", "halloween_monster_alien_slave_0" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );

		keyvalues =
		{
			{ "model",	"models/halloween/houndeye.mdl" },
			{ "targetname", "halloween_monster_houndeye" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );

		keyvalues =
		{
			{ "model",	"models/halloween/hassassin.mdl" },
			{ "targetname", "halloween_monster_human_assassin" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/controller.mdl" },
			{ "targetname", "halloween_monster_alien_controller" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/agrunt.mdl" },
			{ "targetname", "halloween_monster_alien_grunt" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/garg.mdl" },
			{ "targetname", "halloween_monster_gargantua" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/gonome.mdl" },
			{ "targetname", "halloween_monster_gonome" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/big_mom.mdl" },
			{ "targetname", "halloween_monster_bigmomma" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/candy.mdl" },
			{ "targetname", "halloween_candy" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/hgrunt.mdl" },
			{ "targetname", "halloween_hgrunt_0" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/hgrunt_devil.mdl" },
			{ "targetname", "halloween_hgrunt_1" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/hgrunt_scarecrow.mdl" },
			{ "targetname", "halloween_hgrunt_2" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
		
		keyvalues =
		{
			{ "model",	"models/halloween/zombie.mdl" },
			{ "targetname", "halloween_hgrunt_3" }
		};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", SetActivator( keyvalues ), true );
	}

	dictionary SetActivator( dictionary keyvalkeyvaluestext )
	{
		keyvalkeyvaluestext.set("target", "!activator");
		return keyvalkeyvaluestext;
	}
	
	void FireTargets( const string target, CBaseEntity@ pActivator )
	{
		g_EntityFuncs.FireTargets( target, pActivator, pActivator, USE_TOGGLE );
	}
}