/*
    a "Tool" for getting titles.txt into a bunch of game_text ( or game_text_custom ) into a text file ready for copypaste into your maps.
    useful for porting mods that uses titles.txt for showing messages. refeer to the wiki for more information:
    https://github.com/Mikk155/Sven-Co-op/wiki/lazy-port-mod's-titles.txt-Spanish
    
*/
string EntityName = "game_text";
bool RipentStyle = true;
bool DebugMode = true;

void MapInit()
{
    ReadTitles();
}

void ReadTitles()
{
    File@ pFile = g_FileSystem.OpenFile( "scripts/maps/store/titles/titles.txt", OpenFile::READ );
    File@ FileSaveConvert = g_FileSystem.OpenFile( "scripts/maps/store/titles/newtitles.txt", OpenFile::WRITE );

    if( pFile is null || !pFile.IsOpen() || FileSaveConvert is null || !FileSaveConvert.IsOpen()  ) 
        return;

    FileSaveConvert.Write( "" );

    string line;
    string latestx = "-1";
    string latesty = "0.67";
    string latesteffect = "0";
    string latestcolor = "100 100 100";
    string latestcolor2 = "240 110 0";
    string latestfadein = "1.5";
    string latestfadeout = "0.5";
    string latestfxtime = "0.25";
    string latestholdtime = "1.2";
    string latesttargetname;
    string latestmessage;

    bool capsule = false;
    bool read = false;
    bool finishread = false;

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );
            
        if( line.Find("//") != String::INVALID_INDEX ) 
            continue;

        if( line.Find("$position") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestx = SubLines[1];
            latesty = SubLines[2];
            if( DebugMode ) g_Game.AlertMessage( at_console, "x: "+latestx+"\n" );
            if( DebugMode ) g_Game.AlertMessage( at_console, "y: "+latesty+"\n" );
        }
        else if( line.Find("$effect") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latesteffect = SubLines[1];
            if( DebugMode ) g_Game.AlertMessage( at_console, "effect: "+latesteffect+"\n" );
        }
        else if( line.Find("$color2") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestcolor2 = SubLines[1] + " " + SubLines[2] + " " + SubLines[3];
            if( DebugMode ) g_Game.AlertMessage( at_console, "color2: "+latestcolor2+"\n" );
        }
        else if( line.Find("$color") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestcolor = SubLines[1] + " " + SubLines[2] + " " + SubLines[3];
            if( DebugMode ) g_Game.AlertMessage( at_console, "color: "+latestcolor+"\n" );
        }
        else if( line.Find("$fadein") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestfadein = SubLines[1];
            if( DebugMode ) g_Game.AlertMessage( at_console, "fadein: "+latestfadein+"\n" );
        }
        else if( line.Find("$fadeout") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestfadeout = SubLines[1];
            if( DebugMode ) g_Game.AlertMessage( at_console, "fadeout: "+latestfadeout+"\n" );
        }
        else if( line.Find("$fxtime") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestfxtime = SubLines[1];
            if( DebugMode ) g_Game.AlertMessage( at_console, "fxtime: "+latestfxtime+"\n" );
        }
        else if( line.Find("$holdtime") != String::INVALID_INDEX )
        {
            array<string> SubLines = line.Split(" ");
            latestholdtime = SubLines[1];
            if( DebugMode ) g_Game.AlertMessage( at_console, "holdtime: "+latestholdtime+"\n" );
        }
        else if( line.Find("{") != String::INVALID_INDEX )
        {
            capsule = true;
            if( DebugMode ) g_Game.AlertMessage( at_console, "{\n" ); 
        }
        else if( line.Find("}") != String::INVALID_INDEX )
        {
            capsule = false;
            finishread = true;
            if( DebugMode ) g_Game.AlertMessage( at_console, "}\n" ); 
        }
        else if( capsule && !read )
        {
            read = true;
            if( DebugMode ) g_Game.AlertMessage( at_console, "Name of the sentence: "+latesttargetname+"\n" ); 
        }
        else
        {
            if( !capsule )
            {
                latesttargetname = line;
                if( DebugMode ) g_Game.AlertMessage( at_console, latesttargetname + "\n" );
            }
        }

        if( read )
        {
            if( !finishread  )
            {
                if( latestmessage.IsEmpty() )
                {
                    latestmessage = line;
                }
                else if( line.IsEmpty() )
                {
                    latestmessage = latestmessage  + "\\n";
                } 
                else
                {
                    latestmessage = latestmessage + "\\n" + line;
                }

                if( DebugMode ) g_Game.AlertMessage( at_console, "Sentence: "+latestmessage+"\n" );
            } 
        }
        else
        {
            latestmessage = "";
        }

        if( finishread )
        {
            if( !RipentStyle )
            {
                FileSaveConvert.Write( "\"entity\"\n" );
            }
            FileSaveConvert.Write( "{\n" );
            FileSaveConvert.Write( "" + "\"classname\""+" \""+EntityName+"\"\n");
            FileSaveConvert.Write( "" + "\"x\""+" \""+latestx+"\"\n");
            FileSaveConvert.Write( "" + "\"y\""+" \""+latesty+"\"\n" );
            FileSaveConvert.Write( "" + "\"effect\""+" \""+latesteffect+"\"\n" );
            FileSaveConvert.Write( "" + "\"color\""+" \""+latestcolor+"\"\n" );
            FileSaveConvert.Write( "" + "\"color2\""+" \""+latestcolor2+"\"\n" );
            FileSaveConvert.Write( "" + "\"fadein\""+" \""+latestfadein+"\"\n" );
            FileSaveConvert.Write( "" + "\"fadeout\""+" \""+latestfadeout+"\"\n" );
            FileSaveConvert.Write( "" + "\"fxtime\""+" \""+latestfxtime+"\"\n" );
            FileSaveConvert.Write( "" + "\"holdtime\""+" \""+latestholdtime+"\"\n" );
            FileSaveConvert.Write( "" + "\"message\""+" \""+latestmessage+"\"\n" );
            FileSaveConvert.Write( "" + "\"name\""+" \""+latesttargetname+"\"\n" );
            FileSaveConvert.Write( "}\n" );

            dictionary Saved;
            Saved ["x"] = latestx;
            Saved ["y"] = latesty;
            Saved ["effect"] = latesteffect;
            Saved ["color"] = latestcolor;
            Saved ["color2"] = latestcolor2;
            Saved ["fadein"] = latestfadein;
            Saved ["fadeout"] = latestfadeout;
            Saved ["fxtime"] = latestfxtime;
            Saved ["holdtime"] = latestholdtime;
            Saved ["message"] = latestmessage;
            Saved ["targetname"] = latesttargetname;
            g_EntityFuncs.CreateEntity( EntityName, Saved, true ); 

            if( DebugMode )
            {
                if( !RipentStyle )
                {
                    g_Game.AlertMessage( at_console, "\"entity\"\n" ); 
                }
                g_Game.AlertMessage( at_console, "{\n" ); 
                g_Game.AlertMessage( at_console, "" + "\"classname\""+" \""+EntityName+"\"\n" ); 
                g_Game.AlertMessage( at_console, "" + "\"x\""+" \""+latestx+"\"\n" ); 
                g_Game.AlertMessage( at_console, "" + "\"y\""+" \""+latesty+"\"\n" ); 
                g_Game.AlertMessage( at_console, "" + "\"effect\""+" \""+latesteffect+"\"\n" );
                g_Game.AlertMessage( at_console, "" + "\"color\""+" \""+latestcolor+"\"\n" ); 
                g_Game.AlertMessage( at_console, "" + "\"color2\""+" \""+latestcolor2+"\"\n" ); 
                g_Game.AlertMessage( at_console, "" + "\"fadein\""+" \""+latestfadein+"\"\n" );
                g_Game.AlertMessage( at_console, "" + "\"fadeout\""+" \""+latestfadeout+"\"\n" );
                g_Game.AlertMessage( at_console, "" + "\"fxtime\""+" \""+latestfxtime+"\"\n" );
                g_Game.AlertMessage( at_console, "" + "\"holdtime\""+" \""+latestholdtime+"\"\n" );
                g_Game.AlertMessage( at_console, "" + "\"message\""+" \""+latestmessage+"\"\n" );
                g_Game.AlertMessage( at_console, "}\n" ); 

                g_Game.AlertMessage( at_console, "\n" ); 
            }

            finishread = false;
            read = false;
        }
    }

    FileSaveConvert.Close();
    pFile.Close();
}
