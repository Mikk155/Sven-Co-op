namespace DDD_LIGHTCONTROL
{
    void SETGLOBALLIGHT( int flDifficulty )
    {
        string strLightLevel = "";

        if( flDifficulty == 100 ) strLightLevel = "a";
        else if( flDifficulty == 99 ) strLightLevel = "b";
        else if( flDifficulty == 98 ) strLightLevel = "c";
        else if( flDifficulty == 97 ) strLightLevel = "d";
        else if( flDifficulty == 96 ) strLightLevel = "e";
        else if( flDifficulty == 95 ) strLightLevel = "f";
        else if( flDifficulty == 94 ) strLightLevel = "g";
        else if( flDifficulty == 93 ) strLightLevel = "h";
        else if( flDifficulty == 92 ) strLightLevel = "i";
        else if( flDifficulty == 91 ) strLightLevel = "j";
        else if( flDifficulty == 90 ) strLightLevel = "k";
        else if( flDifficulty == 89 ) strLightLevel = "l";
        else if( flDifficulty <= 88 ) strLightLevel = "m";

        g_EngineFuncs.LightStyle(0, strLightLevel);
    }
}