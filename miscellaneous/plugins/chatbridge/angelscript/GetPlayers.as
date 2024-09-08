void GetPlayers( int &out AllPlayers, int &out AlivePlayers = 0)
{
    int z=0,x=0;

    for( int i = 1; i <= g_Engine.maxClients; i++ )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

        if( pPlayer !is null )
        {
            z++;

            if( pPlayer.IsAlive() )
                x++;
        }
    }
    AllPlayers = z;
    AlivePlayers = x;
}