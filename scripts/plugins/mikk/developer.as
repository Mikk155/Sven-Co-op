#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @PlayerPreThink );
    Mikk.UpdateTimer( pThink, "Think", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES );
}

CScheduledFunction@ pThink;

dictionary g_Players;

CClientCommand CMD( "dev", "Sets developer mode for developer plugin, on/off", @Command );

void Command( const CCommand@ args )
{
    string ID = Mikk.PlayerFuncs.GetSteamID( g_ConCommandSystem.GetCurrentPlayer() );

    if( args[1] == "on" || args[1] == "true" || atoi( args[1] ) == 1 )
    {
        g_Players[ID] = true;
    }
    else if( g_Players.exists(ID) )
    {
        g_Players.delete(ID);
    }
}

string Spawnpoints;

void Think()
{
    CBaseEntity@ pSpawnpoints = null;

    while( ( @pSpawnpoints = g_EntityFuncs.FindEntityByClassname( pSpawnpoints, 'info_player_*' ) ) !is null )
    {
    }
}

HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
{
    if( pPlayer !is null && g_Players.exists( Mikk.PlayerFuncs.GetSteamID( pPlayer ) ) )
    {
        string left, right, top;
        left = right = top = '';

        dictionary g_Data = GetInfo( pPlayer );

        array<string> str = g_Data.getKeys();

        str.sortAsc();

        left = "Time: " + Floor( g_Engine.time, 1 ) + '\n';

        for( uint ui = 0; ui < str.length(); ui++ )
        {
            if( ui < 16 )
            {
                left += str[ui] + ": " + string( g_Data[ str[ui] ] ) + '\n';
            }
            else if( ui < 32 )
            {
                right += string( g_Data[ str[ui] ] ) + " :" + str[ui] + '\n';
            }
        }

        HUDTextParams textParams;
        textParams.x = 0.0;
        textParams.effect = 0;
        textParams.r1 = 0;
        textParams.g1 = 255;
        textParams.b1 = 0;
        textParams.fadeinTime = 0;
        textParams.fadeoutTime = 0;
        textParams.holdTime =1;

        textParams.x = -1;
        textParams.y = 1.0;
        textParams.channel = 1;
        top = 'angles: ' + Floor( pPlayer.pev.angles.x, 1 ) + ' ' + Floor( pPlayer.pev.angles.y, 1 ) + '\n';
        top += 'velocity: ' + Floor( pPlayer.pev.velocity.x, 1 ) + ' ' + Floor( pPlayer.pev.velocity.y, 1 ) + ' ' + Floor( pPlayer.pev.velocity.z, 1 ) + '\n';
        top += "origin: " + pPlayer.pev.origin.ToString() + '\n';
        g_PlayerFuncs.HudMessage( pPlayer, textParams, top );

        textParams.y = -1;

        textParams.x = 0.0;
        textParams.channel = 2;
        g_PlayerFuncs.HudMessage( pPlayer, textParams, left );
        textParams.x = 1.0;
        textParams.channel = 4;
        g_PlayerFuncs.HudMessage( pPlayer, textParams, right );
    }
    return HOOK_CONTINUE;
}

string Floor( float flFrom, int decimals )
{
    string strFrom = string( flFrom );

    string todec = strFrom.SubString( strFrom.Find( '.', 0 ), strFrom.Length() );
    strFrom = strFrom.SubString( 0, strFrom.Find( '.', 0 ) );

    for( int i = 0; i <= decimals && !todec.IsEmpty(); i++ )
    {
        strFrom += todec[0];
        todec = todec.SubString( 1, todec.Length() );

    }
    return strFrom;
}

dictionary GetInfo( CBasePlayer@ pPlayer )
{
    dictionary g_Data;

    float f1, f2;

    f1 = g_EngineFuncs.CVarGetFloat( "sv_friction" );
    f2 = pPlayer.pev.friction;
    g_Data[ "friction" ] = string( f1 ) + ( f2 != 1.0 ? ' * ' + string( f2 ) + " (" + string( int( f1 * f2 ) ) + ")" : '' );

    f1 = g_EngineFuncs.CVarGetFloat( "sv_gravity" );
    f2 = pPlayer.pev.gravity;
    g_Data[ "gravity" ] = string( f1 ) + ( f2 != 1.0 ? ' * ' + string( f2 ) + " (" + string( int( f1 * f2 ) ) + ")" : '' );

    g_Data[ "air_finished" ] = Floor( pPlayer.pev.air_finished - g_Engine.time, 1 );

    TraceResult tr;

    Vector anglesAim = pPlayer.pev.v_angle + pPlayer.pev.punchangle;
    g_EngineFuncs.MakeVectors( anglesAim );
    Vector vecSrc = pPlayer.GetGunPosition();
    Vector vecDir = g_Engine.v_forward;

//    g_Utility.TraceLine( vecSrc, vecSrc + vecDir * 8192, dont_ignore_monsters, pPlayer.edict(), tr );

    g_Data[ "texture" ] = g_Utility.TraceTexture( null, vecSrc, vecSrc + vecDir * 8192 );


    return g_Data;
}