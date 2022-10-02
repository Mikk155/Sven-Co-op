namespace DDD_DEATHDROP
{
    dictionary keyvalues;

    string[][] srtDeathDrop = 
    {
        {"monster_human",         "monster_handgrenade"},
        {"monster_alien_grunt",   "monster_sqknest"},
        {"monster_alien_slave",   "monster_snark"},
        {"monster_controller",    "monster_stukabat"},
        {"monster_zombie",        "monster_headcrab"}
    };

    float flRandom = Math.RandomFloat( 0, 100 );

    void DEATHDROP( int flDifficulty )
    {
        if( flDifficulty >= 70 )
        {
            CBaseEntity@ pEntity = null;

            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
            {
                if( string(pEntity.pev.classname).EndsWith ("dead") )
                    continue;

                for(uint i = 0; i < srtDeathDrop.length(); i++)
                {
                    if( string(pEntity.pev.classname).StartsWith(srtDeathDrop[i][0]) and flRandom <= flDifficulty )
                    {
                        if( pEntity.IsAlive() == false or pEntity.pev.health < -1)
                        {
                            keyvalues ["origin"]	= "" + pEntity.GetOrigin().ToString();
                            g_EntityFuncs.CreateEntity( srtDeathDrop[i][1], keyvalues, true );
                        }
                    }
                }
            }
        }
    }
}