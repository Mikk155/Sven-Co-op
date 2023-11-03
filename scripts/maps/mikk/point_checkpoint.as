#include "as_register"

namespace point_checkpoint
{
    dictionary msg_activated, msg_triggered, msg_use, msg_spawned;

    void MapInit()
    {
        m_EntityFuncs.CustomEntity( 'point_checkpoint', true );
        global_messages( msg_use, 'point_checkpoint use', false, 'mikk/point_checkpoint.ini' );
        global_messages( msg_activated, 'point_checkpoint activated' false, 'mikk/point_checkpoint.ini' );
        global_messages( msg_triggered, 'point_checkpoint triggered' false, 'mikk/point_checkpoint.ini' );
        global_messages( msg_spawned, 'point_checkpoint spawned' false, 'mikk/point_checkpoint.ini' );
    }

    enum POINT_CHECKPOINT
    {
        PC_ONLY_TRIGGER = 1,
        PC_MONSTERS_CAN = 2,
        PC_START_OFF = 4,
        PC_ONLY_IOS = 8,
        PC_NO_CLIENTS = 16,
        PC_NO_MESSAGE = 32,
        PC_VALID_SPAWNPOINT = 64,
        PC_FORCE_ANGLES = 128,
        PC_SPAWN_PLAYER_ORIGIN = 256
    }

    class point_checkpoint : ScriptBaseAnimating, ScriptBaseCustomEntity
    {
        private string m_iszDefaultModel = 'models/limitlesspotential/mk_logo_purple.mdl';
        private string m_iszCustomMusic = '../media/valve.mp3';
        private string m_iszPlayersTarget;
        private string m_iszTriggerOnTouch;
        private string m_iszTriggerOnActivate;
        private string m_iszTriggerOnEnd;
        private string m_iszTriggerOnSpawn;
        private string m_iszSpawnSprite = 'sprites/glow01.spr';
        private string m_iszSpawnSoundIn = 'ambience/particle_suck2.wav';
        private string m_iszSpawnSoundOut = 'debris/beamstart7.wav';
        private string m_iszPlayerSpawnSound = 'debris/beamstart7.wav';

        private float m_fDelayBetweenPlayers = 0.5f;
        private float m_fDelayBeforeStart = 3.0f;
        private float m_fDelayBeforeReActivate = 0.0f;
        private int m_iSpawnType;

        // This is stupid.
        private bool bnodraw = false;
        private bool bsurvival = false;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "m_fDelayBetweenPlayers" )
            {
                m_fDelayBetweenPlayers = atof( szValue );
            }
            else if( szKey == "m_fDelayBeforeStart" )
            {
                m_fDelayBeforeStart = atof( szValue );
            }
            else if( szKey == "m_iszCustomMusic" )
            {
                m_iszCustomMusic = szValue;
            }
            else if( szKey == "m_iszPlayersTarget" )
            {
                m_iszPlayersTarget = szValue;
            }
            else if( szKey == "m_iszTriggerOnActivate" )
            {
                m_iszTriggerOnActivate = szValue;
            }
            else if( szKey == "m_iszTriggerOnTouch" )
            {
                m_iszTriggerOnTouch = szValue;
            }
            else if( szKey == "m_iszTriggerOnEnd" )
            {
                m_iszTriggerOnEnd = szValue;
            }
            else if( szKey == "m_iszTriggerOnSpawn" )
            {
                m_iszTriggerOnSpawn = szValue;
            }
            else if( szKey == "m_iszSpawnSprite" )
            {
                m_iszSpawnSprite = szValue;
            }
            else if( szKey == "m_iszSpawnSoundIn" )
            {
                m_iszSpawnSoundIn = szValue;
            }
            else if( szKey == "m_iszSpawnSoundOut" )
            {
                m_iszSpawnSoundOut = szValue;
            }
            else if( szKey == "m_iszPlayerSpawnSound" )
            {
                m_iszPlayerSpawnSound = szValue;
            }
            else if( szKey == "m_fDelayBeforeReActivate" )
            {
                m_fDelayBeforeReActivate = atof( szValue );
            }
            else if( szKey == "m_iSpawnType" )
            {
                m_iSpawnType = atoi( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Precache()
        {
            CustomModelPrecache( m_iszDefaultModel );
            g_Game.PrecacheModel( m_iszSpawnSprite );
            g_Game.PrecacheGeneric( m_iszSpawnSprite );

		    g_Game.PrecacheGeneric( "sound/" + m_iszCustomMusic );
            g_Game.PrecacheGeneric( "sound/" + m_iszSpawnSoundIn );
            g_Game.PrecacheGeneric( "sound/" + m_iszSpawnSoundOut );
            g_SoundSystem.PrecacheSound( m_iszSpawnSoundIn );
            g_SoundSystem.PrecacheSound( m_iszSpawnSoundOut );
		    g_SoundSystem.PrecacheSound( m_iszCustomMusic );

            BaseClass.Precache();
        }

        void Spawn()
        {
            Precache();

		    self.pev.movetype = MOVETYPE_NONE;
		    self.pev.solid = SOLID_TRIGGER;

            if( SetBBOX() == SetBounds_NONE )
            {
                g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -32 ), Vector( 32, 32, 32 ) );
            }

            CustomModelSet( m_iszDefaultModel );

            self.pev.framerate = ( self.pev.framerate <= 0.0 ? 1.0f : self.pev.framerate );
            self.pev.sequence = 0;
            self.pev.frame = 0;
            self.ResetSequenceInfo();

		    SetThink( ThinkFunction( this.Think ) );
		    self.pev.nextthink = g_Engine.time + 0.1f;

            if( spawnflag( PC_START_OFF ) )
            {
                self.pev.effects |= EF_NODRAW;
                bnodraw = true;
            }

            BaseClass.Spawn();
        }

        void Think()
        {
            if( bsurvival != g_SurvivalMode.IsActive() )
            {
                if( bnodraw == false )
                {
                    self.pev.effects &= ~EF_NODRAW;
                }
                bsurvival = g_SurvivalMode.IsActive();
            }

		    self.StudioFrameAdvance();
		    self.pev.nextthink = g_Engine.time + 0.1f;
        }

        void Touch( CBaseEntity@ pOther )
        {
            if( pOther is null
            or spawnflag( PC_START_OFF ) )
                return;

            m_EntityFuncs.Trigger( m_iszTriggerOnTouch, pOther, self, itout( m_iUseType, m_UTLatest ), m_fDelay );

            if( IsLockedByMaster()
            or spawnflag( PC_ONLY_TRIGGER )
            or spawnflag( PC_NO_CLIENTS ) && pOther.IsPlayer()
            or spawnflag( PC_ONLY_IOS ) && !self.FVisibleFromPos( self.pev.origin, pOther.Center() )
            ){ return; }

            if( pOther.IsPlayer() )
            {
                m_Language.PrintMessage( cast<CBasePlayer@>( pOther ), msg_use, ML_BIND, false, { { '$key$', '+use' } } );

                if( pOther.pev.button & IN_USE == 0 )
                    return;

                Activate( pOther, string( pOther.pev.netname ) );
            }
            else if( spawnflag( PC_MONSTERS_CAN ) && pOther.IsMonster() && pOther.Classify() == CLASS_PLAYER_ALLY )
            {
                Activate( pOther, string( cast<CBaseMonster@>( pOther ).m_FormattedName ) );
            }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
        {
            if( IsLockedByMaster() )
            {
                return;
            }

            m_UTLatest = UseType;

            if( spawnflag( PC_START_OFF ) )
            {
                g_Scheduler.SetTimeout( @this, "SFX", 1.6f, m_iszSpawnSoundIn );

                NetworkMessage largefunnel( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
                    largefunnel.WriteByte( TE_LARGEFUNNEL );

                    largefunnel.WriteCoord( self.pev.origin.x );
                    largefunnel.WriteCoord( self.pev.origin.y );
                    largefunnel.WriteCoord( self.pev.origin.z );

                    largefunnel.WriteShort( g_EngineFuncs.ModelIndex( m_iszSpawnSprite ) );
                    largefunnel.WriteShort( 0 );
                largefunnel.End();

                g_Scheduler.SetTimeout( @this, "SpawnFinished", 6.0f, EHandle( pActivator ) );
            }
            else
            {
                string m_iszActivator;

                if( pActivator.IsPlayer() )
                {
                    m_iszActivator = string( pActivator.pev.netname );
                }
                else if( spawnflag( PC_MONSTERS_CAN ) && pActivator.IsMonster() )
                {
                    m_iszActivator = string( cast<CBaseMonster@>( pActivator ).m_FormattedName );
                }

                Activate( pActivator, m_iszActivator );
            }
        }

        void Activate( CBaseEntity@ pActivator, string &in m_iszActivator )
        {
            self.pev.spawnflags |= PC_START_OFF;

            OldRender = self.pev.rendermode;
            OldAmt = self.pev.renderamt;

		    SetThink( ThinkFunction( this.FadeThink ) );
		    self.pev.nextthink = g_Engine.time + 0.1f;

            if( !spawnflag( PC_NO_MESSAGE ) )
            {
                m_Language.PrintMessage( null, ( m_iszActivator != '' ?  msg_activated : msg_triggered ), ML_CHAT, true, { { '$name$', m_iszActivator } } );
            }

			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, m_iszCustomMusic, 1.0f, ATTN_NONE );

            dictionary pPlayers;

            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null && !pPlayer.IsAlive() )
                {
                    pPlayers[ int( pPlayer.entindex() )] = float( pPlayer.pev.frags );
                }
            }

            g_Scheduler.SetTimeout( @this, 'StartSpawning', m_fDelayBeforeStart, @pPlayers );

            m_EntityFuncs.Trigger( m_iszTriggerOnActivate, pActivator, self, itout( m_iUseType, m_UTLatest ), m_fDelay );
        }

        int OldRender;
        float OldAmt;

        void FadeThink()
        {
            if( self.pev.rendermode == kRenderNormal )
            {
                self.pev.rendermode = kRenderTransAlpha;

                if( self.pev.renderamt == 0 )
                {
                    self.pev.renderamt = 255;
                }
            }

            if( self.pev.renderamt > 0 )
            {
                self.StudioFrameAdvance();

                self.pev.renderamt -= 30;

                if ( self.pev.renderamt < 0 )
                {
                    self.pev.renderamt = 0;
                }

                self.pev.nextthink = g_Engine.time + 0.1f;
            }
            else
            {
			    self.pev.effects |= EF_NODRAW;
                bnodraw = true;
                self.pev.rendermode = OldRender;
                self.pev.renderamt = OldAmt;
            }
        }

        void ReActivate()
        {
		    SetThink( ThinkFunction( this.Think ) );
		    self.pev.nextthink = g_Engine.time + 0.1f;
            self.pev.effects &= ~EF_NODRAW;
            bnodraw = false;
            self.pev.spawnflags &= ~PC_START_OFF;
        }

        void StartSpawning( dictionary@ pPlayers )
        {
            if( pPlayers is null )
                return;

            float GreaterScore = -9999;
            int GreaterIndex;

            const array<string> eidx = pPlayers.getKeys();

            if( eidx.length() > 0 )
            {
                for( uint i = 0; i < eidx.length(); i++ )
                {
                    if( float( pPlayers[ atoi( eidx[i] ) ] ) > GreaterScore )
                    {
                        GreaterIndex = atoi( eidx[i] );
                    }
                }
            }
            else
            {
                m_EntityFuncs.Trigger( m_iszTriggerOnEnd, self, self, itout( m_iUseType, m_UTLatest ), m_fDelay );

                if( m_fDelayBeforeReActivate > 0.0f )
                {
                    g_Scheduler.SetTimeout( @this, 'ReActivate', m_fDelayBeforeReActivate );
                }
                else
                {
                    g_EntityFuncs.Remove( self );
                }

                return;
            }

            pPlayers.delete( GreaterIndex );

            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( GreaterIndex );

            if( IsFilteredByName( pPlayer ) )
            {
                g_Scheduler.SetTimeout( @this, 'StartSpawning', 0.0f, @pPlayers );
            }
            else
            {
                Revive( pPlayer, self.pev.origin, self.pev.angles );
                g_Scheduler.SetTimeout( @this, 'StartSpawning', ( m_fDelayBetweenPlayers > 0.1f ? m_fDelayBetweenPlayers : 0.5f ), @pPlayers );
            }
        }

        void Revive( CBasePlayer@ pPlayer, Vector VecPos, Vector VecAng )
        {
            if( spawnflag( PC_VALID_SPAWNPOINT ) )
            {
                m_PlayerFuncs.RespawnPlayer( pPlayer );
            }
            else
            {
                if( spawnflag( PC_FORCE_ANGLES ) )
                {
                    pPlayer.pev.angles = VecAng;
                }

                if( !spawnflag( PC_SPAWN_PLAYER_ORIGIN ) )
                {
                    pPlayer.GetObserver().RemoveDeadBody();
                    g_EntityFuncs.SetOrigin( pPlayer, VecPos );
                }
                else if( spawnflag( PC_SPAWN_PLAYER_ORIGIN ) && !pPlayer.GetObserver().HasCorpse() )
                {
                    g_EntityFuncs.SetOrigin( pPlayer, VecPos );
                }

                pPlayer.Revive();
            }

            if( m_iszNewTargetName != '' )
            {
                pPlayer.pev.targetname = m_iszNewTargetName;
            }

            m_Effect.quake( pPlayer.pev.origin, 1 );
            g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, m_iszPlayerSpawnSound, 1.0f, ATTN_NORM );

            m_EntityFuncs.Trigger( m_iszPlayersTarget, pPlayer, self, itout( m_iUseType, m_UTLatest ), m_fDelay );
        }

        void SpawnFinished( EHandle hActivator )
        {
            SFX( m_iszSpawnSoundOut );
            self.pev.effects &= ~EF_NODRAW;
            bnodraw = false;
            self.pev.spawnflags &= ~PC_START_OFF;
            m_EntityFuncs.Trigger( m_iszTriggerOnSpawn, hActivator.GetEntity(), self, itout( m_iUseType, m_UTLatest ), m_fDelay );

            if( !spawnflag( PC_NO_MESSAGE ) )
            {
                m_Language.PrintMessage( null, msg_spawned, ML_CHAT, true );
            }
        }

        void SFX( string sfx )
        {
            g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, sfx, 1.0f, ATTN_NORM );
        }
    }
}