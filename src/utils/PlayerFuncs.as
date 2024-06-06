namespace PlayerFuncs
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [PlayerFuncs::'+s+'] '+d+'\n' );}

    float bottomcolor( CBasePlayer@ pPlayer )
    {
        return float( float( uint8( ( pPlayer.pev.colormap & 0xFF00 ) >> 8 ) ) / 255.0f );
    }

    float topcolor( CBasePlayer@ pPlayer )
    {
        return float( float( uint8( pPlayer.pev.colormap & 0x00FF ) ) / 255.0f );
    }

    CBasePlayer@ FindPlayerBySteamID( const string &in m_iszSteamID )
    {
        CBasePlayer@ pPlayer = null;

        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            if( ( @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer ) ) !is null
            && pPlayer.IsConnected() && m_iszSteamID == GetSteamID( pPlayer ) )
                break;
        }
        return pPlayer;
    }

    string GetSteamID( CBasePlayer@ pPlayer )
    {
        string ID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
        return ( ID == "BOT" || ID == "STEAM_ID_LAN" ? ID + ':' + string( pPlayer.entindex() ) : ID );
    }

    bool RespawnPlayer( CBasePlayer@ pPlayer )
    {
        pPlayer.Revive();
        g_PlayerFuncs.RespawnPlayer( pPlayer );
        return pPlayer.IsAlive();
    }
}
