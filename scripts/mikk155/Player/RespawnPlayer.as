namespace Player
{
    /**
    *   @brief Respawn the given player without making him lose his weapon loadout.
    **/
    bool RespawnPlayer( CBasePlayer@ player )
    {
        player.Revive();
        g_PlayerFuncs.RespawnPlayer( player );
        return player.IsAlive();
    }
}
