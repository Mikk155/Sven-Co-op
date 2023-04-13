#include "utils"

bool entitymaker_register = g_Util.CustomEntity( 'entitymaker::entitymaker','entitymaker' );

namespace entitymaker
{
    class entitymaker : ScriptBaseEntity
    {
        dictionary g_KeyValues;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            g_KeyValues[ szKey ] = szValue;
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( g_KeyValues[ "child_classname" ] ), g_KeyValues, true );
            
            if( pEntity !is null )
            {
                pEntity.pev.targetname = string( g_KeyValues[ "child_targetname" ] );
                g_EntityFuncs.SetOrigin( pEntity, self.pev.origin );
            }
        }

        void Precache()
        {
            if( !string( self.pev.model ).IsEmpty() && !string( self.pev.model ).StartsWith( '*' ) )
            {
                g_Game.PrecacheModel( string( self.pev.model ) );
                g_Game.PrecacheGeneric( string( self.pev.model ) );
            }
        }
    }
}