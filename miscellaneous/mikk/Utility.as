class MKUtility
{
    // prefix: "UpdateTimer"
    // description: Clears and sets a CScheduledFunction@ function with the given parameters
    // body: Mikk.Utility
    void UpdateTimer( CScheduledFunction@ &out pTimer, string &in szFunction, float flTime, int iRepeat = 0 )
    {
        if( pTimer !is null )
        {
            g_Scheduler.RemoveTimer( pTimer );
        }

        @pTimer = g_Scheduler.SetInterval( "Think", flTime, iRepeat );
    }
}