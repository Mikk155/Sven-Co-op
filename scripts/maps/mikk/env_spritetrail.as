// This script is subject to change in any moment. copy in your own folder if you really want to use this right now
#include "utils"
#include "utils/customentity"
#include "utils/effects"

namespace env_spritetrail
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "env_spritetrail::env_spritetrail", "env_spritetrail" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_spritetrail' ) +
            g_ScriptInfo.Description( 'Traces a trail sprite on the target entity' ) +
            g_ScriptInfo.Wiki( 'env_spritetrail' ) +
            g_ScriptInfo.Author( 'Gaftherman' ) +
            g_ScriptInfo.GetGithub( 'Gaftherman' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class env_spritetrail : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle hTargetEnt = null;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Precache()
        {
            CustomModelPrecache();
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

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( string( self.pev.target ) == "!activator" && pActivator !is null )
            {
                hTargetEnt = pActivator;
            }
            else if( !string( self.pev.target ).IsEmpty() )
            {
                CBaseEntity@ pMonsters = g_EntityFuncs.FindEntityByTargetname( pMonsters, string( self.pev.target ) );
                
                if( pMonsters !is null )
                {
                    hTargetEnt = pMonsters;
                }
            }
            else
            {
                hTargetEnt = self;
            }
        }

        void TriggerThink()
        {
            if( !IsLockedByMaster() )
            {
                if( hTargetEnt.GetEntity() is null )
                {
                    g_Util.Debug("[env_spritetrail] NULL entity in env_spritetrail. trail set on self entity. (" + self.GetTargetname() + ")" );
                    hTargetEnt = self;
                    self.pev.nextthink = g_Engine.time + 0.5f;
                }
                else
                {
                    g_Effect.beamfollow( hTargetEnt.GetEntity(), string( self.pev.model ), int( self.pev.health ), int( self.pev.scale ), self.pev.rendercolor, int( self.pev.renderamt ) );
                }
            }

            self.pev.nextthink = ( delay > 0.0 ) ? g_Engine.time + delay : g_Engine.time + 0.1f;
        }
    }
}