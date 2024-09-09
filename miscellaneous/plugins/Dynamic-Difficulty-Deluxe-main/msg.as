CMSG msg;
final class CMSG
{
    string msgPath = 'Dynamic-Difficulty-Deluxe/global_messages.ini';

    dictionary diff_voted, diff_updated, vote_menu, vote_showinfo, vote_startvote, vote_cooldown, vote_diffstarted, vote_notenought,
    changes, nochanges, agrunt_berserk, appearflags, barnacle_speed, zombie_uncrab, deathdrop_grenade, voltigore_explode, projectiles_speed,
    player_cap_health, player_cap_armor, agrunt_punchpush, agrunt_stun, squad_alerted, monster_alert, always_gib, diff_current, using_ddd,
    reflect_friendlyfire, islave_zap, diffforce_no, diffforce_yes
    ;

    // dictionary de dictionarys :XD:
    dictionary proper_diff;

    dictionary GetProperDiff()
    {
        if( string( g_DDD.diff ) == '100' )
        {
            return dictionary( proper_diff[ '100' ] );
        }
        else if( g_DDD.diff >= 95 && g_DDD.diff < 99 )
        {
            return dictionary( proper_diff[ '95' ] );
        }
        else if( g_DDD.diff == 99 )
        {
            return dictionary( proper_diff[ '99' ] );
        }

        return dictionary( proper_diff[ string( g_DDD.diff )[0] ] );
    }

    void PluginInit()
    {
        dictionary df;
        global_messages( df, 'diff 0', true, msgPath ); proper_diff[ '0' ] = df;
        global_messages( df, 'diff 10', true, msgPath ); proper_diff[ '1' ] = df;
        global_messages( df, 'diff 20', true, msgPath ); proper_diff[ '2' ] = df;
        global_messages( df, 'diff 30', true, msgPath ); proper_diff[ '3' ] = df;
        global_messages( df, 'diff 40', true, msgPath ); proper_diff[ '4' ] = df;
        global_messages( df, 'diff 50', true, msgPath ); proper_diff[ '5' ] = df;
        global_messages( df, 'diff 60', true, msgPath ); proper_diff[ '6' ] = df;
        global_messages( df, 'diff 70', true, msgPath ); proper_diff[ '7' ] = df;
        global_messages( df, 'diff 80', true, msgPath ); proper_diff[ '8' ] = df;
        global_messages( df, 'diff 90', true, msgPath ); proper_diff[ '9' ] = df;
        global_messages( df, 'diff 95', true, msgPath ); proper_diff[ '95' ] = df;
        global_messages( df, 'diff 99', true, msgPath ); proper_diff[ '99' ] = df;
        global_messages( df, 'diff 100', true, msgPath ); proper_diff[ '100' ] = df;

        global_messages( barnacle_speed, 'barnacle speed up', true, msgPath );
        global_messages( vote_notenought, 'vote failed no votes', true, msgPath );
        global_messages( vote_diffstarted, 'vote started', true, msgPath );
        global_messages( vote_cooldown, 'vote on cooldown', true, msgPath );
        global_messages( vote_startvote, 'vote start', true, msgPath );
        global_messages( vote_showinfo, 'vote info', true, msgPath );
        global_messages( vote_menu, 'vote menu', true, msgPath );
        global_messages( diff_updated, 'diff updated', true, msgPath );
        global_messages( diff_current, 'diff current', true, msgPath );
        global_messages( using_ddd, 'diff advice', true, msgPath );
        global_messages( diff_voted, 'diff voted', true, msgPath );
        global_messages( nochanges, 'diff no changes', true, msgPath );
        global_messages( changes, 'diff changes', true, msgPath );
        global_messages( diffforce_no, 'diff admin no access', true, msgPath );
        global_messages( diffforce_yes, 'diff admin updated', true, msgPath );
        global_messages( zombie_uncrab, 'zombie uncrab', true, msgPath );
        global_messages( agrunt_berserk, 'agrunt berserk', true, msgPath );
        global_messages( agrunt_punchpush, 'agrunt punch', true, msgPath );
        global_messages( agrunt_stun, 'agrunt stun', true, msgPath );
        global_messages( islave_zap, 'islave zap', true, msgPath );
        global_messages( appearflags, 'appearflags', true, msgPath );
        global_messages( voltigore_explode, 'voltigore gib', true, msgPath );
        global_messages( deathdrop_grenade, 'deathdrop grenade', true, msgPath );
        global_messages( player_cap_health, 'player cap health', true, msgPath );
        global_messages( player_cap_armor, 'player cap armor', true, msgPath );
        global_messages( always_gib, 'player always gib', true, msgPath );
        global_messages( squad_alerted, 'squad protect', true, msgPath );
        global_messages( monster_alert, 'monster alert', true, msgPath );


        /*
        m_FileSystem.GetKeyAndValue( m_szPath + 'reflect_friendlyfire.txt', reflect_friendlyfire, true );
        m_FileSystem.GetKeyAndValue( m_szPath + 'projectiles_speed.txt', projectiles_speed, true );
        */
    }
}