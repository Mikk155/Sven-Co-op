DDDCvars ddd_cvars;

CConCommand g_Cvars( "DynamicDifficultyDeluxe", "Dynamic Difficulty Deluxe CVars", @SetCvars, ConCommandFlag::AdminOnly );

CClientCommand g_DiffChange( "diff", "- Change difficulty (ADMIN)", @cmdDiffManipulate );

void cmdDiffManipulate( const CCommand@ args )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    if( pPlayer is null || !pPlayer.IsConnected() )
        return;

    if( g_PlayerFuncs.AdminLevel( pPlayer ) == ADMIN_NO )
    {
        m_Language.PrintMessage( pPlayer, msg.diffforce_no, ML_CONSOLE );
        return;
    }

    SaveVote( args[1] );
    m_Language.PrintMessage( null, msg.diffforce_yes, ML_CHAT, true, { { '$admin$', string( pPlayer.pev.netname ) }, { '$diff$', string( g_DDD.diff ) } } );
    m_PlayerFuncs.ExecCommandAll( 'spk "limitlesspotential/cs/aboose.wav"' );
}

void SetCvars( const CCommand@ args )
{
    if( args[1] == 'vote' )
    {
        if( args[2] == 'cooldown' )
        {
            ddd_cvars.votes_cooldown = atoi( args[3] );
        }
        else if( args[2] == 'time' )
        {
            ddd_cvars.votes_time = atoi( args[3] );
        }
        else if( args[2] == 'allowin' )
        {
            ddd_cvars.votes_allowin = atoi( args[3] );
        }
    }
    else if( args[1] == 'disable' )
    {
        ddd_cvars.disabled = atoi( args[2] );
    }
    else if( args[1] == 'barnacle' )
    {
        if( args[2] == 'enable' )
        {
            func_barnacle_speed.enable = atoi( args[3] );
        }
        else if( args[2] == 'diff' )
        {
            func_barnacle_speed.diff = atoi( args[3] );
        }
    }
    else if( args[1] == 'armorvest' )
    {
        if( args[2] == 'enable' )
        {
            func_armor_vest.enable = atoi( args[3] );
        }
        else if( args[2] == 'reduction' )
        {
            func_armor_vest.reduction = atof( args[3] );
        }
    }
    else if( args[1] == 'uncrab' )
    {
        if( args[2] == 'enable' )
        {
            func_zombie_uncrab.enable = atoi( args[3] );
        }
        else if( args[2] == 'diff' )
        {
            func_zombie_uncrab.diff = atoi( args[3] );
        }
    }
    else if( args[1] == 'agrunt' )
    {
        if( args[2] == 'punch' )
        {
            if( args[3] == 'diff' )
            {
                func_alien_grunt.diff_punch = atoi( args[4] );
            }
            else
            {
                func_alien_grunt.enable_punch = atoi( args[3] );
            }
        }
        else if( args[2] == 'stun' )
        {
            if( args[3] == 'diff' )
            {
                func_alien_grunt.diff_stun = atoi( args[4] );
            }
            else
            {
                func_alien_grunt.enable_stun = atoi( args[3] );
            }
        }
        else if( args[2] == 'berserk' )
        {
            if( args[3] == 'diff' )
            {
                func_alien_grunt.diff_berserk = atoi( args[4] );
            }
            else
            {
                func_alien_grunt.enable_berserk = atoi( args[3] );
            }
        }
    }
    else if( args[1] == 'islave' )
    {
        if( args[2] == 'zap' )
        {
            if( args[3] == 'diff' )
            {
                func_alien_slave.diff_zap = atoi( args[4] );
            }
            else
            {
                func_alien_slave.enable_zap = atoi( args[3] );
            }
        }
    }
    else if( args[1] == 'appearflags' )
    {
        func_appearflags.enable = atoi( args[2] );
    }
    else if( args[1] == 'voltigore' )
    {
        if( args[2] == 'gib' )
        {
            if( args[3] == 'diff' )
            {
                func_voltigore.diff_gib = atoi( args[4] );
            }
            else
            {
                func_voltigore.enable_gib = atoi( args[3] );
            }
        }
    }
    else if( args[1] == 'deathdrop' )
    {
        if( args[2] == 'grenade' )
        {
            if( args[3] == 'diff' )
            {
                func_deathdrop.diff_grenade = atoi( args[4] );
            }
            else
            {
                func_deathdrop.enable_grenade = atoi( args[3] );
            }
        }
    }
    else if( args[1] == 'player' )
    {
        if( args[2] == 'health' )
        {
            if( args[3] == 'diff' )
            {
                func_player.diff_maxhealth = atoi( args[4] );
            }
            else
            {
                func_player.enable_maxhealth = atoi( args[3] );
            }
        }
        else if( args[2] == 'armor' )
        {
            if( args[3] == 'diff' )
            {
                func_player.diff_maxarmor = atoi( args[4] );
            }
            else
            {
                func_player.enable_maxarmor = atoi( args[3] );
            }
        }
        else if( args[2] == 'gib' )
        {
            if( args[3] == 'diff' )
            {
                func_player.diff_gib = atoi( args[4] );
            }
            else
            {
                func_player.enable_gib = atoi( args[3] );
            }
        }
    }
    else if( args[1] == 'squad' )
    {
        if( args[2] == 'diff' )
        {
            func_squad_alert.diff = atoi( args[3] );
        }
        else
        {
            func_squad_alert.enable = atoi( args[2] );
        }
    }
    else if( args[1] == 'alert' )
    {
        if( args[2] == 'diff' )
        {
            func_monster_alert.diff = atoi( args[3] );
        }
        else
        {
            func_monster_alert.enable = atoi( args[2] );
        }
    }

    g_EngineFuncs.ServerPrint( '[DDD] ' + args.GetCommandString() + '\n' );
}

final class DDDCvars
{
    int disabled = 0;

    int votes_cooldown = 60;
    int votes_time = 15;
    int votes_allowin = 30;

    // Speed up for hornets
    bool func_proj_speed_hornet = true;

    // Speed up for garg stomp
    bool func_proj_speed_garg_stomp = true;

    // voltigore beam speed
    //bool func_proj_speed_voltigorebeam = true;

    // Speed of bullsquit split
    bool func_proj_speed_bullsquid = true;

    // Speed of pitdrone spikes
    bool func_proj_speed_pitdrone = true;

    // Speed of spore grenades
    bool func_proj_speed_spore = true;

    // Gonome split speed
    bool func_proj_speed_gonome = true;

    // squads will be alerted if any member does
    bool func_squad_alert = true;
    
    // Monsters will go to the attacker's location if they receive damage (exlcude crossbow, silencer glock etc )
    bool func_monster_alert = true;

    // Monster will inspectionate the area when a player uses a weapon
    bool func_monster_inspect_area = false;

    // always gib the player
    bool func_always_gib = true;

    // Reflect damage dealth to ally players
    bool func_reflect_friendlyfire = true;
}