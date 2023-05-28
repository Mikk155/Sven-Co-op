#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_geiger
{
    void Register()
    {
        g_Util.CustomEntity( 'env_geiger' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_geiger' ) +
            g_ScriptInfo.Description( 'Simulates HEV Geiger alert in a small radius' ) +
            g_ScriptInfo.Wiki( 'env_geiger' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class env_geiger : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private bool State = true;
        private array<string> Sounds;
        dictionary g_Values;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            g_Values[ szKey ] = szValue;
            return true;
        }

        const array<string> g_Keys
        {
            get const { return g_Values.getKeys(); }
        }

        void Spawn()
        {
            Precache();
            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.5f;
            BaseClass.Spawn();
        }

        void Precache() 
        {
            bool HasSounds = false;
            for(uint ui = 0; ui < g_Keys.length(); ui++)
            {
                string Key = string( g_Keys[ui] );
                string Value = string( g_Values[ Key ] );
                
                if( Key.StartsWith( 'sound' ) )
                {
                    g_SoundSystem.PrecacheSound( Value );
                    g_Game.PrecacheGeneric( "sound/" + Value );
                    Sounds.insertLast( Value );
                    HasSounds = true;
                }
            }
            if( !HasSounds )
            {
                int i = 0;
                for(uint ui = 0; ui < 6; ui++)
                {
                    g_SoundSystem.PrecacheSound( 'player/geiger' + i + '.wav' );
                    g_Game.PrecacheGeneric( "sound/" + 'player/geiger' + i + '.wav' );
                    Sounds.insertLast( 'player/geiger' + i + '.wav' );
                    ++i;
                }
            }
            if( self.pev.max_health == 0.0 )
            {
                self.pev.max_health = 0.5;
            }
            BaseClass.Precache();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( useType == USE_ON )
            {
                State = true;
            }
            else if( useType == USE_OFF )
            {
                State = false;
            }
            else
            {
                State = !State;
            }
        }

        void Think()
        {
            if( !State || IsLockedByMaster() )
            {
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
            }

            g_SoundSystem.EmitAmbientSound( self.edict(), self.pev.origin, Sounds[ Math.RandomLong( 0, Sounds.length() -1 ) ], 1,  ATTN_IDLE, 0, PITCH_NORM );

            self.pev.nextthink = g_Engine.time + Math.RandomFloat( self.pev.health, self.pev.max_health );
        }
    }
}
