/**
 *	Copyright (c) 2026 Mikk155
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of the files covered by this license, to use, copy, modify, merge, publish,
 *	distribute, sublicense, and/or sell copies of the files, subject to the
 *	following condition:
 *
 *	The original repository must be credited by including a link to:
 *
 *	https://github.com/Mikk155/Sven-Co-op
 *
 *	This notice and the attribution requirement shall be included in all
 *	substantial copies or distributions of the files.
 *
 *	THE FILES ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE FILES OR THE USE OR OTHER DEALINGS IN THE
 *	FILES.
**/

// Trigger script think mode. netname is gonarch's targetname
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
