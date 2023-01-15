/*
INFORMATION: game_zone_player with new features. see our FGD.

DOWNLOAD:
scripts/maps/mikk/game_zone_entity.as


INSTALL:
#include "mikk/game_zone_entity"

void MapInit()
{
    game_zone_entity::Register();
}
*/

// Set to true to see debugs.
bool blDebug = false;

namespace game_zone_entity
{
    enum game_zone_entity_flags
    {
        SF_TZ_IGNORE_DEAD = 1 << 0
    }

    class game_zone_entity : ScriptBaseEntity
    {
        EHandle hincount = null;
        EHandle houtcount = null;

        private Vector minhullsize();
        private Vector maxhullsize();
        private string intarget, outtarget, incount, outcount;
		private int USE_IN = 2, USE_OUT = 2;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
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
            if( !blDebug )
                self.pev.effects   |= EF_NODRAW;

            if( string( self.pev.model ).StartsWith( "*" ) && self.IsBSPModel() )
            {
                g_EntityFuncs.SetModel( self, self.pev.model );
                g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
                g_EntityFuncs.SetOrigin( self, self.pev.origin );
            }
            else if( minhullsize == g_vecZero or maxhullsize == g_vecZero )
            {
                g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
            }
            else
            {
                g_EntityFuncs.Remove( self );
                g_Debug.Print( "WARNING! game_zone_entity doesn't have BBOX!\n" );
            }

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
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
                g_EntityFuncs.FireTargets( intarget, pActivator, self, USE_TOGGLE, 0.0f );

                if( hincount.GetEntity() !is null )
                {
                    g_EntityFuncs.FireTargets( incount, pActivator, self, ( USE_IN == 0 ? USE_OFF : USE_IN == 1 ? USE_ON : USE_TOGGLE ), 0.0f );

                    g_Debug.Print( "Fired incount '" + incount );
                }

                g_Debug.Print( "Fired intarget '" + intarget + "' for '" + ( pActivator.IsPlayer() ? pActivator.pev.netname : pActivator.pev.classname ) );
            }

            if( !outtarget.IsEmpty() and !self.Intersects( pActivator ) )
            {
                g_EntityFuncs.FireTargets( outtarget, pActivator, self, ( USE_OUT == 0 ? USE_OFF : USE_OUT == 1 ? USE_ON : USE_TOGGLE ), 0.0f );

                if( houtcount.GetEntity() !is null )
                {
                    g_EntityFuncs.FireTargets( outcount, pActivator, self, USE_TOGGLE, 0.0f );

                    g_Debug.Print( "Fired outcount '" + outcount );
                }

                g_Debug.Print( "Fired outtarget '" + outtarget + "' for '" + ( pActivator.IsPlayer() ? pActivator.pev.netname : pActivator.pev.classname ) );
            }
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_zone_entity::game_zone_entity", "game_zone_entity" );
    }
}
// End of namespace.

CDebug g_Debug;

final class CDebug
{
    void Print( string Str )
    {
        if( blDebug )
        {
            g_Game.AlertMessage( at_console, Str + "\n" );
        }
    }
}
// End of final class.