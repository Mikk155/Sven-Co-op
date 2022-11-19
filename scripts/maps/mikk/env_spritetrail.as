/*
INSTALL:

#include "mikk/env_spritetrail"

void MapInit()
{
    RegisterCBaseTrail();
}
*/

#include "utils"

void RegisterCBaseTrail()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseTrail", "env_spritetrail" );
}

class CBaseTrail : ScriptBaseEntity, UTILS::MoreKeyValues
{
    EHandle hTargetEnt = null;
    private bool Toggle = false;

    void Precache()
    {
        g_Game.PrecacheModel( string( self.pev.model ) );
        g_Game.PrecacheGeneric( string( self.pev.model ) );
        BaseClass.Precache();
    }

    void Spawn()
    {
        self.Precache();
        SetTarget( self );
        self.pev.movetype   = MOVETYPE_NONE;
        self.pev.solid      = SOLID_NOT;
        if( self.pev.frags == "" ) string(self.pev.frags) = "0.1f";
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;

        BaseClass.Spawn();
    }

    // Entity to use origin at. if null = @This, if "!activator" = activator
    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        switch(useType)
        {
            case USE_ON:
            {
                Toggle = true;
            }
            break;

            case USE_OFF:
            {
                Toggle = false;
            }
            break;

            default:
            {
                Toggle = !Toggle;
            }
            break;
        }

        SetTarget( pActivator );
    }
    
    void SetTarget( CBaseEntity@ pEntity )
    {
        if( string( self.pev.target ).IsEmpty() )
        {
            hTargetEnt = self;
        }
        else if( string( self.pev.target ) == "!activator" )
        {
            hTargetEnt = pEntity;
        }
        else
        {
            if( self.pev.SpawnFlagBitSet( 1 ) )
            {
                CBaseEntity@ pMonsters = null;
                while( ( @pMonsters = g_EntityFuncs.FindEntityByClassname( pMonsters, string( self.pev.target ) ) ) !is null )
                {
                    hTargetEnt = pMonsters;
                }
            }
            else
            {
                hTargetEnt = g_EntityFuncs.FindEntityByTargetname( hTargetEnt, string( self.pev.target ) );
            }
        }
    }
    
    void TriggerThink()
    {
        if( !Toggle )
        {
            self.pev.nextthink = g_Engine.time + 0.5f;
            return;
        }

        if( hTargetEnt.GetEntity() is null )
        {
            UTILS::Debug("WARNING! NULL entity in env_spritetrail named '"+string(self.pev.target)+"' did you set flag 1?\n");
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

        self.pev.nextthink = g_Engine.time + atof( self.pev.frags );
    }
}