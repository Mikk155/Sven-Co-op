DDDPlayer func_player;

final class DDDPlayer
{
    int enable_maxhealth = 1;
    int diff_maxhealth = 70;

    int enable_maxarmor = 1;
    int diff_maxarmor = 70;

    int enable_gib = 1;
    int diff_gib = 100;

    bool active( int tu, int td )
    {
        return ( tu == 1 && g_DDD.diff >= td );
    }

    void UpdatePlayerHealth( CBasePlayer@ pPlayer )
    {
        if( active( enable_maxhealth, diff_maxhealth ) )
        {
            pPlayer.pev.max_health = Clamp( 'maxhealth', diff_maxhealth );
        }

        if( active( enable_maxarmor, enable_maxarmor ) )
        {
            pPlayer.pev.armortype = Clamp( 'maxarmor', diff_maxarmor );
        }

        if( pPlayer.pev.armorvalue > Clamp( 'maxarmor', 0 ) )
        {
            pPlayer.pev.armorvalue = Clamp( 'maxarmor', 0 );
        }

        if( pPlayer.pev.health > Clamp( 'maxhealth', 0 ) )
        {
            pPlayer.pev.health = Clamp( 'maxhealth', 0 );
        }
    }

    double Clamp( string & in m_iszCvar, int & in iDifference )
    {
        // Stupid shit returns zero
        float cvar = 100 /*g_EngineFuncs.CVarGetFloat( m_iszCvar )*/;
        double NewValue = cvar - ( g_DDD.diff - iDifference ) * (cvar - 1) / ( cvar - iDifference );
        return NewValue;
    }

    void UpdateDifficulty()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsAlive() )
            {
                UpdatePlayerHealth( pPlayer );
            }
        }
    }
}