namespace PlayerKilled
{
    void PluginInit()
    {
        if( pJson.getboolean( "PLAYER_KILLED:LOG" ) )
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled::PlayerKilled );
        }
    }

    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        dictionary pReplacement;
        pReplacement["name"] = string( pPlayer.pev.netname );

        if( pAttacker is null )
        {
            ParseMSG( ParseLanguage( pJson, "MSG_PLAYER_DIED", pReplacement ) );
        }
        else
        {
            if( pAttacker is pPlayer )
            {
                ParseMSG( ParseLanguage( pJson, "MSG_PLAYER_SUICIDE", pReplacement ) );
            }
            else
            {
                if( pAttacker.IsPlayer() )
                {
                    pReplacement["killer"] = string( pAttacker.pev.netname );
                }
                else if( pAttacker.IsMonster() )
                {
                    CBaseMonster@ pMonster = cast<CBaseMonster@>( pAttacker );

                    if( !string( pMonster.m_FormattedName ).IsEmpty() )
                    {
                        pReplacement["killer"] = string( pMonster.m_FormattedName ) + " (" + string( pAttacker.pev.classname ) + ")";
                    }
                    else
                    {
                        pReplacement["killer"] = string( pAttacker.pev.classname );
                    }
                }
                pReplacement["killer"] = ( pAttacker.IsPlayer() ? string( pAttacker.pev.netname ) : string( pAttacker.pev.classname ) );
                ParseMSG( ParseLanguage( pJson, "MSG_PLAYER_KILLED", pReplacement ) );
            }
        }

        return HOOK_CONTINUE;
    }
}