const string iszConfigFile = 'scripts/plugins/mikk/deadchat_players.txt';

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

bool bInitialised = true;

void MapInit()
{
    BlackListed();
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( bInitialised && pPlayer !is null && !pPlayer.IsAlive() && !pParams.ShouldHide )
    {
        const CCommand@ args = pParams.GetArguments();
        string FullSentence = pParams.GetCommand();

        if( !FullSentence.IsEmpty() )
        {
            pParams.ShouldHide = true;

            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pDead = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pDead !is null && !pDead.IsAlive() )
                {
                    g_PlayerFuncs.ClientPrint( pDead, HUD_PRINTTALK, "[DEAD CHAT] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
                }
            }
        }
    }
    return HOOK_CONTINUE;
}

void BlackListed()
{
    File@ pFile = g_FileSystem.OpenFile( iszConfigFile, OpenFile::READ );

    if( pFile is null || !pFile.IsOpen() )
    {
        g_Game.AlertMessage( at_console, 'Can NOT open "' + iszConfigFile + '"\n' );
        bInitialised = true;
        return;
    }
 
    string strMap = string( g_Engine.mapname );
    strMap.ToLowercase();

    string line;

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );
        line.Trim();

        if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
            continue;

        line.ToLowercase();

        if( strMap == line )
        {
            bInitialised = false;
            return;
        }

        if( line.EndsWith( "*", String::CaseInsensitive ) )
        {
            line = line.SubString( 0, line.Length()-1 );

            if( strMap.Find( line ) != Math.SIZE_MAX )
            {
                bInitialised = false;
                return;
            }
        }
    }
    pFile.Close();
    bInitialised = true;
}