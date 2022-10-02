namespace DDD_HOSTNAME
{
    string s = "";

    void HOSTNAME( int d, string h)
    {
        if( h != "" )
        {
            if( d >= 0 && d < 10 ) s =       "Normal";
            else if( d >= 10 && d < 20 ) s = "Medium";
            else if( d >= 20 && d < 30 ) s = "Hard";
            else if( d >= 30 && d < 40 ) s = "Really hard";
            else if( d >= 40 && d < 50 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 50 && d < 60 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 60 && d < 70 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 70 && d < 80 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 80 && d < 85 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 85 && d < 89 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 89 && d < 91 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 91 && d < 93 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 93 && d < 95 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 95 && d < 97 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 97 && d < 98 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d >= 98 && d < 99 ) s = "INSERT_NAME_DEFINITION_FOR_THIS_DIFFICULTY";
            else if( d == 99 ) s =           "IMPOSSIBLE";
            else if( d > 100 ) s =           "LIMITLESS POTENTIAL";

            g_EngineFuncs.ServerCommand("hostname \""+h+"\" Difficulty "+d+"\" (\" "+s+"\" )\n");
            g_EngineFuncs.ServerExecute();
        }
    }
}