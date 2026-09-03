// Think mode. netname is gonarch's targetname
void gonarch_cum( CBaseEntity@ self )
{
    CBaseMonster@ momma = null;

    if( self.pev.euser1 is null )
    {
        @momma = cast<CBaseMonster@>( g_EntityFuncs.FindEntityByTargetname( null, string( self.pev.netname ) ) );

        if( momma is null )
        {
            self.Use( null, null, USE_OFF, 0 );
            self.pev.flags |= FL_KILLME;
            return;
        }

        @self.pev.euser1 = momma.edict();
    }
    else
    {
        @momma = cast<CBaseMonster@>( g_EntityFuncs.Instance( self.pev.euser1 ) );
    }

    if( momma is null )
    {
        self.Use( null, null, USE_OFF, 0 );
        self.pev.flags |= FL_KILLME;
        return;
    }

    // cumming
    if( momma.pev.iuser1 == 1 )
    {
        CBaseEntity@ cum = null;

        while( ( @cum = g_EntityFuncs.FindEntityByClassname( cum, "bmortar" ) ) !is null )
        {
            if( cum.pev.movetype != MOVETYPE_FLYMISSILE )
            {
                CBaseEntity@ enemy = momma.m_hEnemy.GetEntity();
                @cum.pev.owner = momma.edict();

                Vector vecStart = momma.pev.origin;
                vecStart.z += 180;

                g_EntityFuncs.SetOrigin( cum, vecStart );
                cum.pev.movetype = MOVETYPE_FLYMISSILE;

                Vector vecDir = enemy.pev.origin - vecStart;
                vecDir = vecDir.Normalize();

                cum.pev.velocity = vecDir * 1300; // speed
                momma.pev.iuser1 = 0;
            }
        }
    }
    // She wants to cum?
    else if( momma.pev.sequence == 9 )
    {
        momma.pev.iuser1 = 1;
    }
    // Giving birth
    else if( momma.pev.sequence == 8 )
    {
        // 25% chance of cumming instead of birthing?
        if( Math.RandomLong( 0.0f, 1.0f ) <= 0.25 )
        {
            momma.m_IdealActivity = ACT_RANGE_ATTACK1;
            momma.pev.iuser1 = 1;
        }
        else
        {
            // give birth faster?
            momma.pev.framerate = 3.0f;
        }
    }
}
