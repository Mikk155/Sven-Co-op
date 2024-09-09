DDDAppearFlags func_appearflags;

final class DDDAppearFlags
{
    int enable = 0;

    dictionary MatchedMonsters;

    void MapActivate()
    {
        if( enable == 0 )
            return;

        const array<string> eidx = MatchedMonsters.getKeys();

        if( eidx.length() > 0 )
        {
            CBaseEntity@ pEntity = null;

            for( uint i = 0; i < eidx.length(); i++ )
            {
                if( ( @pEntity = g_EntityFuncs.Instance( atoi( eidx[i] ) ) ) !is null )
                {
                    int iMin, iMax;
                    m_CustomKeyValue.GetValue( pEntity, '$i_ddd_appearance_min', iMin );
                    m_CustomKeyValue.GetValue( pEntity, '$i_ddd_appearance_max', iMax );

                    if(m_CustomKeyValue.HasKey( pEntity, '$i_ddd_appearance_max' ) && g_DDD.diff > iMax
                    or m_CustomKeyValue.HasKey( pEntity, '$i_ddd_appearance_min' ) && g_DDD.diff < iMin )
                    {
                        if( pEntity.IsMonster() )
                            if( string( MatchedMonsters[ string( pEntity.entindex() ) ] ) != '' )
                                m_EntityFuncs.Trigger( string( MatchedMonsters[ string( pEntity.entindex() ) ] ), pEntity, null, USE_TOGGLE, 0.0f );

                        g_EntityFuncs.Remove( pEntity );

                        MatchedMonsters.delete( string( eidx[i] ) );
                    }
                }
            }
        }
    }
}