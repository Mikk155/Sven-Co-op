namespace DDD_ANGRYNPC
{
    void ANGRYNPC( int iDifficulty )
    {
        if( iDifficulty >= 97 )
        {
            CBaseEntity@ pScript = null;

            while( ( @pScript = g_EntityFuncs.FindEntityByClassname( pScript, string( "" ).EndsWith( "scripted_sequence" ) ) ) !is null )
            {
                CBaseEntity@ pMonster = null;

                while( ( @pMonster = g_EntityFuncs.FindEntityByClassname( pScript, "monster*" ) ) ) !is null )
                {
                    if( pMonster.pev.targetname != pScript.GetTargetname() && pMonster.IsMonster() )
                    {
                        CBaseMonster@ pNPC = cast<CBaseMonster@>(pMonster);
                        if( pNPC.m_hEnemy.GetEntity() is null || !pNPC.m_hEnemy.GetEntity().IsAlive() )
                        {
                            array<EHandle> PlayerAlive;

                            for( int playerID = 1; playerID <= g_Engine.maxClients; playerID++ )
                            {
                                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( playerID );

                                if( pPlayer is null || !pPlayer.IsAlive() )
                                    continue;

                                PlayerAlive.insertLast( pPlayer );
                            }

                            CBasePlayer@ pPlayer = cast<CBasePlayer@>(PlayerAlive[Math.RandomLong( 0, PlayerAlive.length()-1 )].GetEntity());

                            if( pPlayer !is null)
                                pNPC.m_hEnemy = @pPlayer;
                        }
                    }
                }
            }
		}
    }
}