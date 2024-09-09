DDDVoltigore func_voltigore;

final class DDDVoltigore
{
    int enable_gib = 1;
    int diff_gib = 1;

    bool active( int tu, int td )
    {
        return ( tu == 1 && g_DDD.diff >= td );
    }
}