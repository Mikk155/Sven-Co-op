namespace DDD_SETCVARS
{
    void SETCVARS( int flDifficulty )
    {
        if( flDifficulty > 0 )
        {
            int int_weaponfadedelay = 100 / flDifficulty;
            float int_respawndelay = 0.1 * flDifficulty;

            g_EngineFuncs.CVarSetFloat( "mp_weaponfadedelay", int_weaponfadedelay );
            g_EngineFuncs.CVarSetFloat( "mp_respawndelay", int( int_respawndelay ) );

            if( flDifficulty >= 50 )
            {
                g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
                g_EngineFuncs.CVarSetFloat( "mp_ammo_respawndelay", -1 );
                g_EngineFuncs.CVarSetFloat( "mp_item_respawndelay", -1 );

                if( flDifficulty >= 60 )
                {
                    g_EngineFuncs.CVarSetFloat( "npc_dropweapons", 0 );
                    g_EngineFuncs.CVarSetFloat( "mp_disable_player_rappel", 1 );

                    if( flDifficulty >= 65 )
                    {
                        g_EngineFuncs.CVarSetFloat( "mp_allowmonsterinfo", 0 );

                        if( flDifficulty >= 95 )
                        {
                            g_EngineFuncs.CVarSetFloat( "mp_ammo_droprules", 1 );

                            if( flDifficulty >= 96 )
                            {
                                g_EngineFuncs.CVarSetFloat( "mp_weapon_droprules", 1 );
                            }
                        }
                    }
                }
            }
        }
    }
}