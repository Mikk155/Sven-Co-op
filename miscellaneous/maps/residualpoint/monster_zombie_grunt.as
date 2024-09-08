#include 'utils/CGetInformation'
#include 'utils/CUtils'
#include 'utils/Reflection'
#include 'utils/ScriptBaseCustomEntity'

namespace monster_zombie_grunt
{
    void Register()
    {
        g_Util.CustomEntity( 'monster_zombie_grunt' );
    }

    class monster_zombie_grunt : ScriptBaseMonsterEntity
    {
        private dictionary m_dKeyvalues;
        private string iszModel = 'models/mikk/residualpoint/zgrunt.mdl';

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            m_dKeyvalues[ szKey ] = szValue;
            return true;
        }

		void Precache()
		{
			g_Game.PrecacheModel( iszModel );
			g_Game.PrecacheGeneric( iszModel );
			g_Game.PrecacheOther( "monster_human_grunt" );

			g_SoundSystem.PrecacheSound( "null.wav" ); // cache
			g_Game.PrecacheGeneric( "sound/" + "null.wav" ); // client has to download
		}

        void Spawn()
        {
            if( string( self.pev.targetname ).IsEmpty() )
            {
                m_Create();
            }
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            m_Create();
        }

        void m_Create()
        {
            m_dKeyvalues[ 'classname' ] = 'monster_human_grunt';
            m_dKeyvalues[ 'model' ] = iszModel;
            m_dKeyvalues[ 'displayname' ] = 'Zombified Human Grunt';
            m_dKeyvalues[ 'soundlist' ] = '../mikk/residualpoint/zgrunt.txt';
            m_dKeyvalues[ 'classify' ] = '7';
            m_dKeyvalues[ 'health' ] = string( g_EngineFuncs.CVarGetString( 'sk_hgrunt_health' ) * 2 );
            m_dKeyvalues[ 'bloodcolor' ] = string( Math.RandomLong( 1, 2 ) );
            m_dKeyvalues[ 'spawnflags' ] = string( self.pev.spawnflags );
            m_dKeyvalues[ 'targetname' ] = string( self.pev.targetname );
            m_dKeyvalues[ 'angles' ] = self.pev.angles.ToString();
            m_dKeyvalues[ 'origin' ] = self.pev.origin.ToString();
            m_dKeyvalues[ 'netname' ] = string( self.pev.netname );
            m_dKeyvalues[ 'weapons' ] = string( self.pev.weapons );
            m_dKeyvalues[ 'body' ] = string( self.pev.body );
            m_dKeyvalues[ 'skin' ] = string( self.pev.skin );

            CBaseEntity@ zgrunt = g_Util.CreateEntity( m_dKeyvalues );

            if( zgrunt !is null )
            {
                zgrunt.m_iTriggerCondition = self.m_iTriggerCondition;
                zgrunt.m_iszTriggerTarget = self.m_iszTriggerTarget;
                g_EntityFuncs.Remove( self );
            }
        }
    }
}
