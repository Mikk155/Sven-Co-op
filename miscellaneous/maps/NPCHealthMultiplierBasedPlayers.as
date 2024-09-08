void UpdateHealth( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fValue )
{
    int iPlayers = g_PlayerFuncs.GetNumPlayers();

    if( iPlayers == 0 )
        return;

    float Multiply = ( iPlayers * 1.25 ) - iPlayers;
    
    if( Multiply < 1.0 )
        return;

    CBaseEntity@ pEntity = null;

    while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'monster_*' ) ) !is null )
    {
        //g_Game.AlertMessage( at_console, '%1\'s health %2 * %3 = %4\n', pEntity.GetClassname(), pEntity.pev.health, Multiply, pEntity.pev.health * Multiply );
        pEntity.pev.health = pEntity.pev.max_health = pEntity.pev.health * Multiply;
    }
}
