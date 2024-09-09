DDDAlienSlave func_alien_slave;

final class DDDAlienSlave
{
    int enable_zap = 1;
    int diff_zap = 1;

    float zapspeed;

    void UpdateDifficulty()
    {
        if( active( enable_zap, diff_zap ) )
        {
            g_EngineFuncs.CVarSetFloat( 'sk_islave_speed_zap', AlienSlaveZapp() );
        }
    }

    const float AlienSlaveZapp()
    {
        return float( zapspeed + float( 0.020f * g_DDD.diff ) );
    }

    void MapInit()
    {
        zapspeed = g_EngineFuncs.CVarGetFloat( 'sk_islave_speed_zap' );
    }

    bool active( int tu, int td )
    {
        return ( tu == 1 && g_DDD.diff >= td );
    }
}