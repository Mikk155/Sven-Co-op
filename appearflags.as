#include 'as_register'

namespace appearflags
{
    void MapStart()
    {
        MatchEntities();

        m_ScriptInfo.SetScriptInfo
        (
            {
                { "script", "appearflags" },
                { "description", "Allow to configurate entitie\'s appearence status" }
            }
        );
    }

    void MatchCustom( CBaseEntity@ pTriggerScript )
    {
        MatchEntities( atoui( pTriggerScript.pev.frags ) );
        pTriggerScript.Use( null, null, USE_OFF, 0.0f );
    }

    enum APPEARFLAGS_FLAGS
    {
        APPEARFLAGS_NO_AFFECT = 0,
        APPEARFLAGS_NOT_IN = 1,
        APPEARFLAGS_ONLY_IN = 2,

        APPEARFLAGS_CUSTOMMODE_DISABLED = 0,
        APPEARFLAGS_CUSTOMMODE_ENABLED = 1,
        APPEARFLAGS_CUSTOMMODE_IGNORED = 2
    }

    void MatchEntities( uint m_uiCustomMode = APPEARFLAGS_CUSTOMMODE_IGNORED )
    {
        CBaseEntity@ pEntity = null;

        for( int eidx = 2 + g_Engine.maxClients; eidx <= g_EngineFuncs.NumberOfEntities(); ++eidx ) 
        {
            if( ( @pEntity = g_EntityFuncs.Instance( eidx ) ) !is null )
            {
                int iValue;

                if( m_uiCustomMode == APPEARFLAGS_CUSTOMMODE_IGNORED )
                {
                    if( m_CustomKeyValue.HasKey( pEntity, '$i_appearflags_classicmode' ) )
                    {
                        m_CustomKeyValue.GetValue( pEntity, '$i_appearflags_classicmode', iValue );

                        if( iValue == APPEARFLAGS_NOT_IN && g_ClassicMode.IsEnabled()
                        or iValue == APPEARFLAGS_ONLY_IN && !g_ClassicMode.IsEnabled() )
                        {
                            Remove( pEntity );
                        }
                    }

                    if( m_CustomKeyValue.HasKey( pEntity, '$i_appearflags_classicmode' ) )
                    {
                        m_CustomKeyValue.GetValue( pEntity, '$i_appearflags_survivalmode', iValue );

                        bool SurvivalIsActive = ( int( g_EngineFuncs.CVarGetFloat( 'mp_survival_supported' ) ) + int( g_EngineFuncs.CVarGetFloat( 'mp_survival_starton' ) ) == 2 );

                        if( iValue == APPEARFLAGS_NOT_IN && SurvivalIsActive
                        or iValue == APPEARFLAGS_ONLY_IN && !SurvivalIsActive )
                        {
                            Remove( pEntity );
                        }
                    }
                }
                else
                {
                    if( m_CustomKeyValue.HasKey( pEntity, '$i_appearflags_classicmode' ) )
                    {
                        m_CustomKeyValue.GetValue( pEntity, '$i_appearflags_custommode', iValue );

                        if( iValue == APPEARFLAGS_NOT_IN && m_uiCustomMode == APPEARFLAGS_CUSTOMMODE_ENABLED
                        or iValue == APPEARFLAGS_ONLY_IN && m_uiCustomMode == APPEARFLAGS_CUSTOMMODE_DISABLED )
                        {
                            Remove( pEntity );
                        }
                    }
                }
            }
        }
    }

    void Remove( CBaseEntity@ pEntity )
    {
        g_EntityFuncs.Remove( pEntity );
        m_Debug.Server( '[appearflags] Removed entity "' + pEntity.GetClassname() + '"', DEBUG_LEVEL_ALMOST );
    }
}