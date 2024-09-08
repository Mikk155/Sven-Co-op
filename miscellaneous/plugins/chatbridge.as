#include '../mikk/shared'

#include 'chatbridge/angelscript/Reflection'
#include 'chatbridge/angelscript/ClientSay'
#include 'chatbridge/angelscript/Think'
#include 'chatbridge/angelscript/ClientPutInServer'
#include 'chatbridge/angelscript/ClientDisconnect'
#include 'chatbridge/angelscript/ClientConnected'
#include 'chatbridge/angelscript/PlayerSpawn'
#include 'chatbridge/angelscript/PlayerKilled'
#include 'chatbridge/angelscript/PlayerKilled'
#include 'chatbridge/angelscript/discord_from_server'
#include 'chatbridge/angelscript/discord_to_server'
#include 'chatbridge/angelscript/discord_to_status'
#include 'chatbridge/angelscript/GetEmote'
#include 'chatbridge/angelscript/GetPlayers'
#include 'chatbridge/angelscript/ParseLanguage'
#include 'chatbridge/angelscript/PlayersConnected'
#include 'chatbridge/angelscript/SurvivalEnabled'
#include 'chatbridge/angelscript/MapStarts'

// Metamod plugin ASLP's API
#if ASLP
#include 'chatbridge/angelscript/PlayerPostRevive'
#endif

JSon pJson;
int seconds;
int minutes;
int hours;
int days;
int restarts;
string map;

dictionary weapondata;
HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult  )
{
    if( pPickup !is null && pOther !is null )
    {
        if( pPickup.GetClassname().StartsWith( "weapon_" ) && cast<CBasePlayer>(pOther).HasNamedPlayerItem( pPickup.GetClassname() ) is null )
        {
            ParseMSG( "- ``" + string( pOther.pev.netname ) + " got a " + pPickup.GetClassname() + "``" );
        }
    }
    return HOOK_CONTINUE;
}