#include "utils"

namespace env_message
{
    CScheduledFunction@ g_CTitles = g_Scheduler.SetTimeout( "CTitles", 0.0f );

    // as_command titles ( path to titles relative to scripts/maps/ ).txt
    CCVar g_Titles ( "titles", "mikk/titles.txt", "custom titles.txt file", ConCommandFlag::AdminOnly );

    void CTitles()
    {
        string strFile = 'scripts/maps/' + g_Titles.GetString();

        CBaseEntity@ pTitle = null;

        while( ( @pTitle = g_EntityFuncs.FindEntityByClassname( pTitle, "env_message" ) ) !is null )
        {
            if( pTitle !is null )
            {
                File@ pFile = g_FileSystem.OpenFile( strFile, OpenFile::READ );

                if( pFile is null or !pFile.IsOpen() )
                {
                    g_Util.Debug( "Failed to open '" + strFile + "' no custom titles loaded." );
                    return;
                }

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
                string latestmessage;

                bool capsule = false;
                bool ReadingTitle = false;
                bool read = false;
                bool finishread = false;

                while( !pFile.EOFReached() )
                {
                    pFile.ReadLine( line );
                        
                    if( line.Find("//") != String::INVALID_INDEX ) 
                        continue;

                    if( pTitle.pev.message == line )
                    {
                        ReadingTitle = true;
                    }

                    if( line.Find("$position") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestx = SubLines[1];
                        latesty = SubLines[2];
                    }
                    else if( line.Find("$effect") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latesteffect = SubLines[1];
                    }
                    else if( line.Find("$color") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestcolor = SubLines[1] + " " + SubLines[2] + " " + SubLines[3];
                    }
                    else if( line.Find("$color2") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestcolor2 = SubLines[1] + " " + SubLines[2] + " " + SubLines[3];
                    }
                    else if( line.Find("$fadein") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestfadein = SubLines[1];
                    }
                    else if( line.Find("$fadeout") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestfadeout = SubLines[1];
                    }
                    else if( line.Find("$fxtime") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestfxtime = SubLines[1];
                    }
                    else if( line.Find("$holdtime") != String::INVALID_INDEX )
                    {
                        array<string> SubLines = line.Split(" ");
                        latestholdtime = SubLines[1];
                    }
                    else if( line.Find("{") != String::INVALID_INDEX )
                    {
                        capsule = true;
                    }
                    else if( line.Find("}") != String::INVALID_INDEX )
                    {
                        capsule = false;
                        finishread = true;
                    }
                    else if( capsule && !read )
                    {
                        read = true;
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
                        } 
                    }
                    else
                    {
                        latestmessage = "";
                    }

                    if( finishread )
                    {
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

                        if( ReadingTitle )
                        {
                            if( string( pTitle.pev.target ).IsEmpty() )
                            {
                                Saved ["targetname"] = 'title_' + pTitle.entindex();
                                pTitle.pev.target = 'title_' + pTitle.entindex();
                            }
                            else
                            {
                                Saved ["targetname"] = pTitle.pev.target;
                            }
                            if( pTitle.pev.SpawnFlagBitSet( 2 ) )
                            {
                                Saved ["spawnflags"] = '1';
                            }
                            pTitle.pev.message = String::INVALID_INDEX;
                            g_EntityFuncs.CreateEntity( 'game_text', Saved, true );
                            ReadingTitle = false;
                        }
                        finishread = false;
                        read = false;
                    }
                }
                pFile.Close();
            }
        }
    }
}