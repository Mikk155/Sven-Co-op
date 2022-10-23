/*
    A script that will allow you to add "new" skills for your monsters so server operators can customize it by editing only one file.
    The system works by reading a file located into "scripts/maps/skills/(modname).cfg"


How to setup? you have to add a custom keyvalue to the monsters.
"$f_sk_monster_health" "anything else"

Then into scripts/maps/skills/your mod name.cfg you have to use it the same way as skill.cfg
sk_monster_health 350

The cfg file name will be what you specify in the first argument when registering the entity.

This script will multiply the value in 0.05 for every 1 player that is connected.
if you want to disable this feature put anything else for the second value when registering the entity.


INSTALL:
#include "mikk/skill"

void MapInit()
{
    RegisterCustomSkills( "cfgname", "plrbalance" );
}



Know issues:

 - Doesn't work on monster/squad makers

*/

string ks_LoadCFG, ks_CFGName, iz_Multiplier, ks_Value, ks_Skill, ks_line;

void RegisterCustomSkills( const string CFGName, const int plrbalance )
{
    ks_CFGName = CFGName;
    if( plrbalance == "plrbalance" ) { iz_Multiplier = plrbalance; }

    // let a small delay just in case entities are not initialized yet
    g_Scheduler.SetTimeout( "SetSkillsOnMonsters", 2.0f );
}

void SetSkillsOnMonsters()
{
    ks_LoadCFG = "scripts/maps/skills/" + ks_CFGName + ".cfg";
    File@ pFile = g_FileSystem.OpenFile( ks_LoadCFG, OpenFile::READ );

    if( pFile is null or !pFile.IsOpen() )
    {
        g_EngineFuncs.ServerPrint("WARNING! Failed to open " + ks_LoadCFG + " no custom skills loaded!\n");
        return;
    }

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( ks_line );

        if( ks_line.Length() < 1 or ks_line[0] == '/' and ks_line[1] == '/' )
            continue;
    
        ks_Skill = ks_line;
        ks_Value = ks_line;

        ks_Skill.Replace( " ", "" );
        ks_Skill.Replace( "0", "" );
        ks_Skill.Replace( "1", "" );
        ks_Skill.Replace( "2", "" );
        ks_Skill.Replace( "3", "" );
        ks_Skill.Replace( "4", "" );
        ks_Skill.Replace( "5", "" );
        ks_Skill.Replace( "6", "" );
        ks_Skill.Replace( "7", "" );
        ks_Skill.Replace( "8", "" );
        ks_Skill.Replace( "9", "" );
        ks_Value.Replace( " ", "" );
        ks_Value.Replace( ks_Skill, "" );

        CBaseEntity@ pMonster = null;

        while( ( @pMonster = g_EntityFuncs.FindEntityByClassname( pMonster, "*" ) ) !is null )
        {
            if( pMonster is null )
                return;

            if( pMonster.GetCustomKeyvalues().HasKeyvalue( "$f_" + ks_Skill ) )
            {
                g_Game.AlertMessage( at_console, "Updated custom skill '" + ks_Skill + "' -> '" + ks_Value + "' for '" + string( pMonster.pev.classname ) + "'\n" );
                
				// You can actually modify any entity that uses health as well like func_tank, breakables.
				pMonster.pev.health = atof( ks_Value );
                pMonster.pev.max_health = atof( ks_Value );
            }
        }
    }

    pFile.Close();
}