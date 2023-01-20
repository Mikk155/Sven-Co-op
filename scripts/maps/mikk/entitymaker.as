namespace entitymaker
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "entitymaker::entitymaker", "entitymaker" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: entitymaker\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Create a entity when fire.\n"
        );
    }

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
}
// end namespace