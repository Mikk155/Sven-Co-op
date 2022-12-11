/*
DOWNLOAD:

scripts/maps/mikk/env_spritetrail.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/env_spritetrail"

void MapInit()
{
    env_spritetrail::Register();
}
*/

#include "utils"

namespace env_spritetrail
{
    class CBaseTrail : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        EHandle hTargetEnt = null;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues(szKey, szValue);
            return true;
        }

        void Precache()
        {
            g_Game.PrecacheModel( string( self.pev.model ) );
            g_Game.PrecacheGeneric( string( self.pev.model ) );
            BaseClass.Precache();
        }

        void Spawn()
        {
            self.Precache();
            self.pev.movetype   = MOVETYPE_NONE;
            self.pev.solid      = SOLID_NOT;

            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        // Entity to use origin at. if null = @This, if "!activator" = activator
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( string( self.pev.target ) == "!activator" && pActivator !is null )
            {
                hTargetEnt = pActivator;
            }
            else if( !string( self.pev.target ).IsEmpty() )
            {
                CBaseEntity@ pMonsters = g_EntityFuncs.FindEntityByTargetname( pMonsters, string( self.pev.target ) );
                
                hTargetEnt = pMonsters;
            }
            else
            {
                hTargetEnt = self;
            }
        }

        void TriggerThink()
        {
            if( master() )
            {
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
            }

            if( hTargetEnt.GetEntity() is null )
            {
                UTILS::Debug("WARNING! NULL entity in env_spritetrail.\n");
                hTargetEnt = self;
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
            }

            int iEntityIndex = g_EntityFuncs.EntIndex(hTargetEnt.GetEntity().edict());
            NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
                message.WriteByte( TE_BEAMFOLLOW );
                message.WriteShort( iEntityIndex );
                message.WriteShort( int( g_Game.PrecacheModel( self.pev.model ) ) );
                message.WriteByte( int( self.pev.health ) );
                message.WriteByte( int( self.pev.scale ) );
                message.WriteByte( int( self.pev.rendercolor.x ) );
                message.WriteByte( int( self.pev.rendercolor.y ) );
                message.WriteByte( int( self.pev.rendercolor.z ) );
                message.WriteByte( int( self.pev.renderamt ) );
            message.End();

            self.pev.nextthink = ( delay > 0.0 ) ? g_Engine.time + delay : g_Engine.time + 0.1f;
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "env_spritetrail::CBaseTrail", "env_spritetrail" );
    }
}// end namespace