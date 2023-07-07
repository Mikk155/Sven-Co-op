const string iszConfigFile = 'scripts/plugins/mikk/dynamic_hostname.txt';
const bool KeepHostName = true;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );
}

string iszHostname, line, iszMap, iszTitle;

void MapStart()
{
    if( iszHostname.IsEmpty() )
    {
        iszHostname = g_EngineFuncs.CVarGetString( 'hostname' );
    }

    bool matched = false;

    File@ pFile = g_FileSystem.OpenFile( iszConfigFile, OpenFile::READ );

    if( pFile is null || !pFile.IsOpen() || KeepHostName && iszHostname.IsEmpty() )
    {
        g_Game.AlertMessage( at_console, 'Can NOT open "' + iszConfigFile + '"\n' );
        return;
    }

    iszMap = string( g_Engine.mapname ).ToLowercase();

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );
        line.Trim();

        if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
            continue;

        array<string> iszSplit = {'',''};

        iszSplit = line.Split( ' ' );

        iszSplit[0].ToLowercase();

        if( iszMap == iszSplit[0] )
        {
            iszTitle = iszSplit[1];
            matched = true;
            break;
        }

        if( iszSplit[0].EndsWith( "*", String::CaseInsensitive ) )
        {
            iszSplit[0] = iszSplit[0].SubString( 0, iszSplit[0].Length()-1 );

            if( iszMap.Find( iszSplit[0] ) != Math.SIZE_MAX )
            {
                iszTitle = iszSplit[1];
                matched = true;
                break;
            }
        }
    }

    if( matched )
    {
        g_EngineFuncs.ServerCommand("hostname \"" + iszHostname + " " + iszTitle + "\"\n");
        g_EngineFuncs.ServerExecute();
    }
}
