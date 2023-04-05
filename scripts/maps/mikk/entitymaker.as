#include "utils"
namespace entitymaker
{
    class entitymaker : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        dictionary g_KeyValues;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            g_KeyValues[ szKey ] = szValue;
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }

            CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( g_KeyValues[ "child_classname" ] ), g_KeyValues, true );
            
            if( pEntity !is null )
            {
                pEntity.pev.targetname = string( g_KeyValues[ "child_targetname" ] );
                g_EntityFuncs.SetOrigin( pEntity, self.pev.origin );
            }
        }
    }
	bool Register = g_Util.CustomEntity( 'entitymaker::entitymaker','entitymaker' );
}