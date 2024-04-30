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

/*
    @prefix #include PlayerFuncs
    @body #include "${1:../../}mikk/PlayerFuncs"
    @description Utilidades relacionadas a jugadores
*/
namespace PlayerFuncs
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [PlayerFuncs::'+s+'] '+d+'\n' );}

    /*
        @prefix PlayerFuncs PlayerFuncs::bottomcolor bottomcolor colormap
        @body PlayerFuncs::bottomcolor( CBasePlayer@ pPlayer )
        @description Separa y retorna los colores del jugador
    */
    float bottomcolor( CBasePlayer@ pPlayer )
    {
        return float( float( uint8( ( pPlayer.pev.colormap & 0xFF00 ) >> 8 ) ) / 255.0f );
    }

    /*
        @prefix PlayerFuncs PlayerFuncs::topcolor topcolor colormap
        @body PlayerFuncs::topcolor( CBasePlayer@ pPlayer )
        @description Separa y retorna los colores del jugador
    */
    float topcolor( CBasePlayer@ pPlayer )
    {
        return float( float( uint8( pPlayer.pev.colormap & 0x00FF ) ) / 255.0f );
    }

    /*
        @prefix PlayerFuncs PlayerFuncs::FindPlayerBySteamID FindPlayerBySteamID SteamID
        @body PlayerFuncs::FindPlayerBySteamID( const string &in m_iszSteamID )
        @description Busca y retorna a un jugador mediante su Steam ID
    */
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

    /*
        @prefix PlayerFuncs PlayerFuncs::GetSteamID GetSteamID SteamID
        @body PlayerFuncs::GetSteamID( CBasePlayer@ pPlayer )
        @description Obtiene la Steam ID de un jugador, agregando prefijos para Bots
    */
    string GetSteamID( CBasePlayer@ pPlayer )
    {
        string ID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
        return ( ID == "BOT" ? ID + string( pPlayer.entindex() ) : ID );
    }

    /*
        @prefix PlayerFuncs PlayerFuncs::RespawnPlayer RespawnPlayer
        @body PlayerFuncs::RespawnPlayer( CBasePlayer@ pPlayer )
        @description Revive y Reaparece a un jugador.
    */
    bool RespawnPlayer( CBasePlayer@ pPlayer )
    {
        pPlayer.Revive();
        g_PlayerFuncs.RespawnPlayer( pPlayer );
        return pPlayer.IsAlive();
    }
}
