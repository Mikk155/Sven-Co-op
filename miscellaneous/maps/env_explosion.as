/*
Modify your env_explosion to prevent it using hardcoded sound

"classname" value-> "trigger_script"
"spawnflags" key -> "iuser1"
"m_iszScriptFunctionName" value -> "env_explosion::Use"
"m_flThinkDelta" value -> "0.3"
"m_iMode" value -> "2"
"m_iMagnitude" key -> "message"
*/

/*
final class CEnvExplosionCustom
{
    CScheduledFunction@ pFindSchedulers = g_Scheduler.SetTimeout( @this, "Find", g_Engine.time + 0.0f );

    void Find()
    {
        CBaseEntity@ pExplosion = null;

        while( ( @pExplosion = g_EntityFuncs.FindEntityByClassname( pExplosion, "env_explosion" ) ) !is null and pExplosion.pev.message != '' )
        {
            dictionary gpKeyValues =
            {
                { "iuser1", string( pExplosion.pev.spawnflags ) },
                { "m_iszScriptFunctionName", "env_explosion::Use" },
                { "m_flThinkDelta", "0.3" }, // Smoke delay
                { "m_iMode", "2" },
                { "message", string( pExplosion.pev.message ) },
                { "targetname", string( pExplosion.pev.targetname ) }
            };

            CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( 'trigger_script', gpKeyValues, true );

            if( pTriggerScript !is null )
            {
                g_EntityFuncs.Remove( pExplosion );
            }
        }
    }
}

CEnvExplosionCustom g_EnvExplosionCustom;
*/

namespace env_explosion
{
    void Use( CBaseEntity@ self )
    {
        int spawnflags = atoi( self.pev.iuser1 );
        int m_iMagnitude = atoi( self.pev.message );

    	float flSpriteScale;
	    flSpriteScale = ( m_iMagnitude - 50) * 0.6;

        if ( flSpriteScale < 10 )
        {
            flSpriteScale = 10;
        }

        int m_spriteScale = int(flSpriteScale);

        switch( self.pev.iuser2 )
        {
            case 1: // Smoke 2nd think
            {
                // don't draw the smoke
                if( ( spawnflags & 8 ) == 0 )
                {
                    NetworkMessage msg( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.vuser1 );
                        msg.WriteByte( TE_SMOKE );
                        msg.WriteCoord( self.pev.vuser1.x );
                        msg.WriteCoord( self.pev.vuser1.y );
                        msg.WriteCoord( self.pev.vuser1.z );
                        msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/steam1.spr" ) );
                        msg.WriteByte( m_spriteScale ); // scale * 10
                        msg.WriteByte( 12 ); // framerate
                    msg.End();
                }

                self.pev.iuser2 = 0;

                // can this entity be refired?
                if( ( spawnflags & 2 ) == 0 )
                {
                    g_EntityFuncs.Remove( self );
                }

                self.Use( null, null, USE_OFF, 0 );
                break;
            }
            default:
            {
                TraceResult tr;

                Vector vecSpot = self.pev.origin + Vector( 0,0,8 );

                g_Utility.TraceLine( vecSpot, vecSpot + Vector( 0,0,-40 ), ignore_monsters, self.edict(), tr );

                // Pull out of the wall a bit
                if( tr.flFraction != 1.0 )
                {
                    self.pev.vuser1 = tr.vecEndPos + ( tr.vecPlaneNormal * ( m_iMagnitude - 24 ) * 0.6 );
                }
                else
                {
                    self.pev.vuser1 = self.pev.origin;
                }

                // don't make a scorch mark
                if( ( spawnflags & 16 ) == 0 )
                {
                    if( Math.RandomFloat( 0, 1 ) < 0.5 )
                    {
                        g_Utility.DecalTrace( tr, DECAL_SCORCH1 );
                    }
                    else
                    {
                        g_Utility.DecalTrace( tr, DECAL_SCORCH2 );
                    }
                }

                // don't draw the fireball
                if( ( spawnflags & 4 ) == 0 )
                {
                    NetworkMessage msg( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.vuser1 );
                        msg.WriteByte( TE_EXPLOSION );
                        msg.WriteCoord( self.pev.vuser1.x );
                        msg.WriteCoord( self.pev.vuser1.y );
                        msg.WriteCoord( self.pev.vuser1.z );
                        msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/zerogxplode.spr" ) );
                        msg.WriteByte( m_spriteScale ); // scale * 10
                        msg.WriteByte( 15 ); // framerate
                        msg.WriteByte( TE_EXPLFLAG_NOSOUND );
                    msg.End();
                }
                else
                {
                    NetworkMessage msg( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.vuser1 );
                        msg.WriteByte( TE_EXPLOSION );
                        msg.WriteCoord( self.pev.vuser1.x );
                        msg.WriteCoord( self.pev.vuser1.y );
                        msg.WriteCoord( self.pev.vuser1.z );
                        msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/zerogxplode.spr" ) );
                        msg.WriteByte( 0 ); // no sprite
                        msg.WriteByte( 15 ); // framerate
                        msg.WriteByte( TE_EXPLFLAG_NOSOUND );
                    msg.End();
                }

                // when set, ENV_EXPLOSION will not actually inflict damage
                if( ( spawnflags & 1 ) == 0 )
                {
                    g_WeaponFuncs.RadiusDamage( self.pev.vuser1, self.pev, self.pev, m_iMagnitude * 2.5, m_iMagnitude, CLASS_NONE, DMG_BLAST );
                }

                // don't make a scorch mark
                if( ( spawnflags & 32 ) == 0 )
                {
                    int sparkCount = Math.RandomLong( 0, 3 );

                    for( int i = 0; i < sparkCount; i++ )
                    {
                        g_EntityFuncs.Create( "spark_shower", self.pev.vuser1, tr.vecPlaneNormal, false, null );
                    }
                }

                self.pev.iuser2 = 1;
                g_EntityFuncs.FireTargets( string( self.pev.target ), null, self, USE_TOGGLE, 0.0f );
            }
            break;
        }
    }
}
