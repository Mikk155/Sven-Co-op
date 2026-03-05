namespace Player
{
    /**
    *   @brief Get a player unique steam ID. whatever this is a bot or sv_lan is 1 we add a unique identifier
    **/
    string GetUniqueID( CBasePlayer@ player )
    {
        if( player is null )
        {
            return String::EMPTY_STRING;
        }

        string authID = g_EngineFuncs.GetPlayerAuthId( player.edict() );

        if( authID == "BOT" )
        {
            snprintf( authID, "BOT_%1", string( player.pev.netname ) );
        }
        else if( authID == "STEAM_ID_LAN" )
        {
            snprintf( authID, "LAN_%1", string( player.pev.netname ) );
        }

        return authID;
    }
}
