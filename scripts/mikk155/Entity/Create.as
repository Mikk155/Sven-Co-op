namespace Entity
{
    CBaseEntity@ Create( dictionary@ keyvalues, bool spawn_now = true )
    {
        if( !keyvalues.exists( "classname" ) )
            return null;

        CBaseEntity@ entity = g_EntityFuncs.CreateEntity( string( keyvalues[ "classname" ] ), keyvalues, spawn_now );

        if( entity is null )
            return null;

        if( keyvalues.exists( "origin" ) )
        {
            Vector VecPos;
            g_Utility.StringToVector( VecPos, string( keyvalues[ "origin" ] ) );
            g_EntityFuncs.SetOrigin( entity, VecPos );
        }

        if( spawn_now )
        {
            g_EntityFuncs.DispatchSpawn( entity.edict() );
        }

        return entity;
    }

    CBaseEntity@ Create( string classname, dictionary@ keyvalues, bool spawn_now = true )
    {
        keyvalues[ "classname" ] = classname;
        return Create( keyvalues, spawn_now );
    }
}
