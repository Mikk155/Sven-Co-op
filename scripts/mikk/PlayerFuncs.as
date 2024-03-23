//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

class MKPlayerFuncs
{
    // prefix: "Mikk.PlayerFuncs.GetColormap", "GetColormap", "colormap", "bottomcolor", "topcolor", "Hue"
    // description: Gets bottomcolor and topcolor from the given player as a RGBA values
    // body: Mikk.PlayerFuncs
    void GetColormap( CBasePlayer@ pPlayer, RGBA &out TopRGB, RGBA &out BotRGB )
    {
        if( pPlayer is null )
            return;

        uint8 TopUi = pPlayer.pev.colormap & 0x00FF;
        uint8 BotUi = ( pPlayer.pev.colormap & 0xFF00 ) >> 8;

        float Top_hue = float(TopUi) / 255.0f;
        float Bot_hue = float(BotUi) / 255.0f;

        TopRGB = HUEtoRGB( Top_hue );
        BotRGB = HUEtoRGB( Bot_hue );
    }

    // prefix: "Mikk.PlayerFuncs.ClientCommand", "ClientCommand", "Command"
    // description: Executes a console command on the given player or all players if bAllPlayers is true
    // body: Mikk.PlayerFuncs
    void ClientCommand( string_t m_iszCommand, CBasePlayer@ pPlayer, bool bAllPlayers = false )
    {
        if( pPlayer is null && !bAllPlayers )
            return;

        if( bAllPlayers )
        {
            NetworkMessage msg( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
                msg.WriteString( ';' + m_iszCommand + ';' );
            msg.End();
        }
        else
        {
            NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
                msg.WriteString( ';' + m_iszCommand + ';' );
            msg.End();
        }
    }

    // prefix: "Mikk.PlayerFuncs.FindPlayerBySteamID", "FindPlayerBySteamID", "SteamID"
    // description: Get the CBasePlayer@ instance of the given SteamID
    // body: Mikk.PlayerFuncs
    CBasePlayer@ FindPlayerBySteamID( const string &in m_iszSteamID )
    {
        CBasePlayer@ pPlayer = null;

        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( ( @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer ) ) !is null
            && pPlayer.IsConnected() && m_iszSteamID == string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) )
                break;
        }
        return pPlayer;
    }

    // prefix: "Mikk.PlayerFuncs.GetSteamID", "GetSteamID", "SteamID"
    // description: Return the SteamID of the given player, BOTS will be enumerated by their index
    // body: Mikk.PlayerFuncs
    string GetSteamID( CBasePlayer@ pPlayer )
    {
        string ID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
        return ( ID == "BOT" ? ID + string( pPlayer.entindex() ) : ID );
    }

    // prefix: "Mikk.PlayerFuncs.RespawnPlayer", "RespawnPlayer"
    // description: Revives the given player and then relocates him to a valid spawnpoint, returns true if revived
    // body: Mikk.PlayerFuncs
    bool RespawnPlayer( CBasePlayer@ pPlayer )
    {
        CBaseEntity@ pSpawnPoint = null;

        while( g_PlayerFuncs.IsSpawnPointValid( ( @pSpawnPoint = g_EntityFuncs.FindEntityByClassname( pSpawnPoint, "info_player_*" ) ), pPlayer ) )
        {
            pPlayer.Revive();
            g_PlayerFuncs.RespawnPlayer( pPlayer );
            return true;
        }
        return false;
    }

    void PlayerSay( CBaseEntity@ pPlayer, string m_szMessage )
    {
        NetworkMessage m( MSG_ALL, NetworkMessages::NetworkMessageType(74), null );
            m.WriteByte( pPlayer.entindex() );
            m.WriteByte( 2 ); // tell the client to color the player name according to team
            m.WriteString( m_szMessage + '\n' );
        m.End();
    }
}