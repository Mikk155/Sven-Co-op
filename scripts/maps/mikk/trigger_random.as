namespace trigger_random
{
    CScheduledFunction@ g_Random = g_Scheduler.SetTimeout( "FindTriggerRandoms", 0.0f );

    void FindTriggerRandoms()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "trigger_random" ) ) !is null )
        {
            if( pEntity !is null && GetMath( pEntity, "min" ) > -1 && GetMath( pEntity, "max" ) > -1 )
            {
                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName", "trigger_random::SetRandomValue" },
                    { "m_iMode", "2" },
                    { "m_flThinkDelta", "0.1" },
                    { "$f_math_min", GetMath( pEntity, "min" ) },
                    { "$f_math_max", GetMath( pEntity, "max" ) },
                    { "targetname", pEntity.GetTargetname() }
                };
                g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );
                g_EntityFuncs.Remove( pEntity );
            }
        }
        g_Util.ScriptAuthor.insertLast
        (
            "Script: trigger_random\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow ttrigger_random to set a unique random value.\n"
        );
    }

    void SetRandomValue( CBaseEntity@ pTriggerScript )
    {
        int MathResultI = Math.RandomLong( atoi( GetMath( pTriggerScript, "min" ) ), atoi( GetMath( pTriggerScript, "max" ) ) );
        float MathResultF = Math.RandomFloat( atof( GetMath( pTriggerScript, "min" ) ), atof( GetMath( pTriggerScript, "max" ) ) );

        pTriggerScript.GetCustomKeyvalues().SetKeyvalue( "$i_math_result", MathResultI );
        pTriggerScript.GetCustomKeyvalues().SetKeyvalue( "$f_math_result", MathResultF );
        
        pTriggerScript.Use( pTriggerScript, pTriggerScript, USE_TOGGLE, 0.0f );
    }

    string GetMath( CBaseEntity@ pEntity, const string key )
    {
        return string( pEntity.GetCustomKeyvalues().GetKeyvalue( "$f_math_" + key ).GetFloat() );
    }
}// end namespace