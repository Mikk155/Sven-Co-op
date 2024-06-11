void MonsterSpawnAlert( CBaseMonster@ pSquadmaker, CBaseEntity@ pMonster )
{
    if( pMonster is null || !pMonster.IsMonster() )
        return;

    CBaseMonster@ monster = cast<CBaseMonster@>( pMonster );

    if( monster is null )
        return;

    array<int> index;

    for( int i = 1; i <= g_Engine.maxClients; i++ )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

        if( pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsAlive() )
            index.insertLast(i);
    }

    if( index.length() > 0 )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index[ Math.RandomLong( 0, index.length() - 1 ) ] );

        if( pPlayer !is null )
            monster.PushEnemy( pPlayer, pPlayer.pev.origin );
    }
}
