/*

// INSTALLATION:

#include "mikk/game_zone_entity"

*/
#include "utils"
namespace game_zone_entity
{
    void ScriptInfo()
    {
        g_Information.SetInformation
        ( 
            'Script: game_debug\n' +
            'Description: Entity wich when fired, shows a debug message, also shows other entities being triggered..\n' +
            'Author: Mikk\n' +
            'Discord: ' + g_Information.GetDiscord( 'mikk' ) + '\n'
            'Server: ' + g_Information.GetDiscord() + '\n'
            'Github: ' + g_Information.GetGithub()
        );
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_zone_entity::game_zone_entity", "game_zone_entity" );
    }

    enum game_zone_entity_spawnflags
    {
        IGNORE_DEAD_ENTITIES = 1
    }

    class game_zone_entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle hincount = null;
        EHandle houtcount = null;

        private string intarget, outtarget, incount, outcount;
        private int USE_IN = 2, USE_OUT = 2;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "intarget" ) 
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

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
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
            if( spawnflag( IGNORE_DEAD_ENTITIES ) && !pActivator.IsAlive() )
                return;

            if( !intarget.IsEmpty() and self.Intersects( pActivator ) )
            {
                g_Util.Trigger( intarget, pActivator, self, USE_TOGGLE, delay );

                if( hincount.GetEntity() !is null )
                {
                    g_Util.Trigger( incount, pActivator, self, ( USE_IN == 0 ? USE_OFF : USE_IN == 1 ? USE_ON : USE_TOGGLE ), 0.0f );

                    g_Util.Debug( "Fired incount '" + incount );
                }

                g_Util.Debug( "Fired intarget '" + intarget + "' for '" + ( pActivator.IsPlayer() ? pActivator.pev.netname : pActivator.pev.classname ) );
            }

            if( !outtarget.IsEmpty() and !self.Intersects( pActivator ) )
            {
                g_Util.Trigger( outtarget, pActivator, self, ( USE_OUT == 0 ? USE_OFF : USE_OUT == 1 ? USE_ON : USE_TOGGLE ), delay );

                if( houtcount.GetEntity() !is null )
                {
                    g_Util.Trigger( outcount, pActivator, self, USE_TOGGLE, 0.0f );

                    g_Util.Debug( "Fired outcount '" + outcount );
                }

                g_Util.Debug( "Fired outtarget '" + outtarget + "' for '" + ( pActivator.IsPlayer() ? pActivator.pev.netname : pActivator.pev.classname ) );
            }
        }
    }
}