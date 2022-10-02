/*
	Da feedback:

	- Leave here any feedback.

	- multiplicador
	tomar skls default y multiplicarlos dependiendo la difficulty
			if( pEntity.GetCustomKeyvalues().HasKeyvalue( "$i_dyndiff_skip" ) )
				continue;

	- quitar medkits

	- activar roaming monsters

	- flashlight limitada

	-

	-

	-

	-

	-

	-

*/
#include "DDD/DDD_VOTE"
#include "DDD/DDD_MLAN"
#include "DDD/DDD_ATELE"
#include "DDD/DDD_HOSTNAME"
#include "DDD/DDD_ANGRYNPC"
#include "DDD/DDD_SETCVARS"
#include "DDD/DDD_DEATHDROP"
#include "DDD/DDD_LIGHTCONTROL"
#include "DDD/DDD_PLAYERKILLED"
#include "../../maps/mikk/DupeFix"
#include "../../maps/mikk/entities/utils"

/*
    |===============================|
    |	Start of customizable zone	|
    |===============================|
*/

// The name of the plugin messages shown in chat
const string strMessagerName = "DDD Plugin";

// set a number from 0 to 100 if you want to FORCE a difficulty when a map starts. 
const string strForceDifficulty = "";

// true = Disable votes.
bool blDisableVotes = false;

// Time to vote
float flVoteTime = 15;

// Percentage for required to vote
float flVotePercentage = 51;

// Time in seconds for votes to be on cooldown
float flVoteCooldown = 60;

// Choose a type of vote from 0 to 2
int VoteType = 0;
// 0 = casual vote of "yes" and "not" using your mouse
// 1 = vote menu the same as buy menu style
// 2 = let players writte in chat to vote


// Name of your server. leave empty to not add "diff %" at the hostname.
const string strHostname = "[US] Limitless Potential (Hardcore + Anti-Rush)";
// Your server's hostname will look like "[US] Limitless Potential (Hardcore + Anti-Rush) Difficulty 99% (Impossible)"

/*
    ||===============================||
    ||  End of customizable zone	 ||
    ||===============================||
*/


// ================  AUTO  ================
void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk
        ----------------------------------------
        Dynamic Difficulty Deluxe I

             .e$$$$e.
           e$$$$$$$$$$e
          $$$$$$$$$$$$$$
         d$$$$$$$$$$$$$$b
         $$$$$$$$$$$$$$$$
        4$$$$$$$$$$$$$$$$F
        4$$$$$$$$$$$$$$$$F
         $$$* *$$$$* *$$$
         $$F   4$$F   4$$
         '$F   4$$F   4$*
          $$   $$$$   $P
          4$$$$$*^$$$$$%
           $$$$F  4$$$$
            *$$$ee$$$*
            . *$$$$F4
             $     .$
             *$$$$$$*
              ^$$$$
    
        Plugin made by Mikk
	
        Type in chat /ddd to open information menu
	
        Download from the main repository: https://github.com/Mikk155

        Some code taken from:

        Gaftherman
        https://github.com/Gaftherman

        Rick
        https://github.com/RedSprend
        "
    );

    g_Module.ScriptInfo.SetContactInfo
    (
        "https://discord.gg/VsNnE3A7j8
        ----------------------------------------
        "
    );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

int flDifficulty = 0;

void MapInit()
{
    if( ExcludedMapList() )
        return;

    g_CustomEntityFuncs.RegisterCustomEntity( "dddmaker", "dddmaker" );

    DDD_ATELE::ATELEPRECACHE();

    if( strForceDifficulty != "" )
    {
        flDifficulty = atoi( strForceDifficulty );
    }
}

void MapActivate()
{
    if( ExcludedMapList() )
        return;

    UpdateDifficulty();
}

void MapStart()
{
    if( ExcludedMapList() )
        return;

    CSurvival::AmmoDupeFix( true, ( flDifficulty < 60 ) ? false : false, false );

    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );

    g_Scheduler.SetInterval( "DDDTHINK", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

bool ExcludedMapList()
{
	string szExcludedMapList = "scripts/plugins/mikk/DDD/DDD_EXCLUDE_MAPLIST.txt";
	File@ pFile = g_FileSystem.OpenFile( szExcludedMapList, OpenFile::READ );

	if( pFile is null || !pFile.IsOpen() )
	{
		g_EngineFuncs.ServerPrint("WARNING! Failed to open "+szExcludedMapList+"\n");
		return false;
	}

	string strMap = g_Engine.mapname;
	strMap.ToLowercase();

	string line;

	while( !pFile.EOFReached() )
	{
		pFile.ReadLine( line );
		line.Trim();

		if( line.Length() < 1 || line[0] == '/' && line[1] == '/' || line[0] == '#' || line[0] == ';' )
			continue;

		line.ToLowercase();

		if( strMap == line )
		{
			pFile.Close();
			return true;
		}

		if( line.EndsWith("*", String::CaseInsensitive) )
		{
			line = line.SubString(0, line.Length()-1);

			if( strMap.Find(line) != Math.SIZE_MAX )
			{
				pFile.Close();
				return true;
			}
		}
	}

	pFile.Close();

	return false;
}

void UpdateDifficulty()
{
    BlipSound();
    DDD_ATELE::ATELE( flDifficulty );
    DDD_SETCVARS::SETCVARS( flDifficulty );
	DDD_ANGRYNPC::ANGRYNPC( flDifficulty );
    DDD_PLAYERKILLED::PLAYERKILLED( flDifficulty );
    DDD_LIGHTCONTROL::SETGLOBALLIGHT( flDifficulty );
    DDD_HOSTNAME::HOSTNAME( flDifficulty, strHostname );
}

void BlipSound()
{
    NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
        message.WriteString( "spk buttons/bell1" );
    message.End();
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ pArguments = pParams.GetArguments();

    if ( pArguments.ArgC() >= 1 )
    {
        if( pArguments[0] == "/ddd" )
        {
            MLANGUAGE::MSG( pPlayer, "motd", "", "", "", strMessagerName );
        }
        else if( pArguments[0] == "/diff" )
        {
            if( ExcludedMapList() )
            {
                MLANGUAGE::MSG( pPlayer, "disabledmap", "", "", "", strMessagerName );
                return HOOK_CONTINUE;
            }

            if( pArguments[0] == "/admin_diff" && !pArguments[1].IsEmpty() )
            {
                flDifficulty = int( pArguments[1] );

                MLANGUAGEALL::MSG( "admin", string( pPlayer.pev.netname ), flDifficulty, "", strMessagerName );

                UpdateDifficulty();
            }

            if( blDisableVotes )
            {
                MLANGUAGE::MSG( pPlayer, "disabledvotes", "", "", "", strMessagerName );
                return HOOK_CONTINUE;
            }

            if( !pArguments[1].IsEmpty() )
            {
                if( atoi( pArguments[1] ) > 100 or string( pArguments[1] ) < 0 )
                {
                    MLANGUAGE::MSG( pPlayer, "wrong_value", "", "", "", strMessagerName );
                }
                else
                {
                    DDDVOTE::VOTE( pPlayer, strMessagerName, flVoteTime, flVotePercentage, atoi( pArguments[1] ), VoteType, flVoteCooldown );
                }
            }
            else
            {
                MLANGUAGE::MSG( pPlayer, "empty_value", "", "", "", strMessagerName );
            }
        }
        else if( pArguments[0] == "diff" )
        {
            MLANGUAGE::MSG( pPlayer, "show_diff", flDifficulty, "", "", strMessagerName );
            if( ExcludedMapList() )
            {
                MLANGUAGE::MSG( pPlayer, "show_diffdisabled", flDifficulty, "", "", strMessagerName );
                return HOOK_CONTINUE;
            }
        }
    }
    return HOOK_CONTINUE;
}

namespace DIFFYCALLBACK
{
    void Diff( int currentdiff )
    {
        flDifficulty = currentdiff;
        UpdateDifficulty();
        MLANGUAGEALL::MSG( "vote_passed", currentdiff, "", "", strMessagerName );
    }
}

void DDDTHINK()
{
    for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if(pPlayer is null or !pPlayer.IsConnected() )
            continue;

        if( flDifficulty >= 98 )
        {
            NETWORKMSG::ViewMode( 0, pPlayer );
        }
    }
    DDD_DEATHDROP::DEATHDROP( flDifficulty );
}

dictionary keys;
class dddmaker : ScriptBaseEntity
{
    void Precache()
    {
        BaseClass.Precache();
        g_Game.PrecacheOther( string( self.pev.netname ) );
        g_Game.PrecacheModel( string( self.pev.model ) );
        g_Game.PrecacheGeneric( string( self.pev.model ) );
    }

    void Spawn()
    {
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        BaseClass.Spawn();
    }

    // Trigger the entity and if the current difficulty is less than keyvalue "frags" spawn the monster classname that's in "netname" keyvalue
    // Also those keys enumerated bellow are supported as well.
    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( self.pev.frags < flDifficulty )
            return;

        keys ["origin"]			= "" + self.GetOrigin().ToString();
        keys ["angles"]			= "" + self.pev.angles.ToString();
        keys ["spawnflags"]		= "" + self.pev.spawnflags;
        keys ["targetname"]		= "" + self.GetTargetname();
        keys ["dmg"]			= "" + self.pev.dmg;
        keys ["target"]			= "" + self.pev.target;
        keys ["health"]			= "" + self.pev.health;
        keys ["max_health"]		= "" + self.pev.max_health;
        keys ["message"]		= "" + self.pev.message;
        keys ["model"]			= "" + self.pev.model;

        g_EntityFuncs.CreateEntity( self.pev.netname, keys, true );
    }
}