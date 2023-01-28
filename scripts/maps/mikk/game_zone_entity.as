#include "utils"
namespace game_zone_entity
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_zone_entity::entity", "game_zone_entity" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_zone_entity\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: game_zone_entity is a entity similar to game_zone_player but now supports any entity in its volume not only players.\n"
        );
    }

    enum spawnflags
    {
        SF_TZ_IGNORE_DEAD = 1 << 0
    }

    class entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle hincount = null;
        EHandle houtcount = null;

        private string intarget, outtarget, incount, outcount;
        private int USE_IN = 2, USE_OUT = 2;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "minhullsize" ) 
            {
                g_Utility.StringToVector( minhullsize, szValue );
            }
            else if( szKey == "intarget" ) 
            {
                intarget = szValue;
            }
            else if( szKey == "USE_IN" ) 
            {
                USE_IN = atoi( szValue );
            }
            else if( szKey == "USE_OUT" ) 
            {
                USE_OUT = atoi( szValue );
            }
            else if( szKey == "outtarget" ) 
            {
                outtarget = szValue;
            }
            else if( szKey == "incount" ) 
            {
                incount = szValue;
            }
            else if( szKey == "outcount" ) 
            {
                outcount = szValue;
            }
            else if( szKey == "maxhullsize" ) 
            {
                g_Utility.StringToVector( maxhullsize, szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }

            return true;
        }

        void Spawn() 
        {
            self.pev.movetype   = MOVETYPE_NONE;
            self.pev.solid      = SOLID_TRIGGER;
            self.pev.effects   |= EF_NODRAW;

            SetBoundaries();

            if( string( self.pev.model ).IsEmpty() && minhullsize == g_vecZero )
            {
                g_Util.DebugMessage( "WARNING! game_zone_entity doesn't have BBOX!\n Only OUT Target is going to work." );
            }

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
                return;

            if( !incount.IsEmpty() )
            {
                CBaseEntity@ pInCount = g_EntityFuncs.FindEntityByTargetname( pInCount, incount );
                
                if( pInCount !is null )
                {
                    hincount = pInCount;
                }
            }

            if( !outcount.IsEmpty() )
            {
                CBaseEntity@ pOutCount = g_EntityFuncs.FindEntityByTargetname( pOutCount, incount );
                
                if( pOutCount !is null )
                {
                    houtcount = pOutCount;
                }
            }

            if( hincount.GetEntity() !is null )
            {
                g_EntityFuncs.DispatchKeyValue( hincount.GetEntity().edict(), "frags", "0" );
            }

            if( houtcount.GetEntity() !is null )
            {
                g_EntityFuncs.DispatchKeyValue( houtcount.GetEntity().edict(), "frags", "0" );
            }

            string strClassName = ( string( self.pev.netname ).IsEmpty() ) ? "player" : string( self.pev.netname );

            CBaseEntity@ pEntity = null;

            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, strClassName ) ) !is null )
            {
                CheckInVolume( pEntity );
            }
        }

        void CheckInVolume( CBaseEntity@ pActivator )
        {
            if ( self.pev.SpawnFlagBitSet( SF_TZ_IGNORE_DEAD ) && !pActivator.IsAlive() )
                return;

            if( !intarget.IsEmpty() and self.Intersects( pActivator ) )
            {
                g_EntityFuncs.FireTargets( intarget, pActivator, self, USE_TOGGLE, delay );

                if( hincount.GetEntity() !is null )
                {
                    g_EntityFuncs.FireTargets( incount, pActivator, self, ( USE_IN == 0 ? USE_OFF : USE_IN == 1 ? USE_ON : USE_TOGGLE ), 0.0f );

                    g_Util.DebugMessage( "Fired incount '" + incount );
                }

                g_Util.DebugMessage( "Fired intarget '" + intarget + "' for '" + ( pActivator.IsPlayer() ? pActivator.pev.netname : pActivator.pev.classname ) );
            }

            if( !outtarget.IsEmpty() and !self.Intersects( pActivator ) )
            {
                g_EntityFuncs.FireTargets( outtarget, pActivator, self, ( USE_OUT == 0 ? USE_OFF : USE_OUT == 1 ? USE_ON : USE_TOGGLE ), delay );

                if( houtcount.GetEntity() !is null )
                {
                    g_EntityFuncs.FireTargets( outcount, pActivator, self, USE_TOGGLE, 0.0f );

                    g_Util.DebugMessage( "Fired outcount '" + outcount );
                }

                g_Util.DebugMessage( "Fired outtarget '" + outtarget + "' for '" + ( pActivator.IsPlayer() ? pActivator.pev.netname : pActivator.pev.classname ) );
            }
        }
    }
}
// End of namespace