#include "GetUniqueID"

namespace Player
{
    CBasePlayer@ FindPlayerBySteamID( const string&in authID )
    {
        CBasePlayer@ player = null;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            if( ( @player = g_PlayerFuncs.FindPlayerByIndex( i ) ) !is null
            && player.IsConnected() && authID == GetUniqueID( player ) )
                break;
        }
        return player;
    }
}
