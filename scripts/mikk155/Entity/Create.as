namespace Entity
{
    CBaseEntity@ Create( dictionary&in keyvalues, edict_t@ owner = null, bool spawnNow = true )
    {
        if( !keyvalues.exists( "classname" ) )
            return null;

        CBaseEntity@ entity = g_EntityFuncs.CreateEntity( string( keyvalues[ "classname" ] ), keyvalues, spawnNow );

        if( entity is null )
            return null;

        @entity.pev.owner = owner;

        if( keyvalues.exists( "origin" ) )
        {
            Vector VecPos;
            g_Utility.StringToVector( VecPos, string( keyvalues[ "origin" ] ) );
            g_EntityFuncs.SetOrigin( entity, VecPos );
        }

        if( spawnNow )
        {
            g_EntityFuncs.DispatchSpawn( entity.edict() );
        }

        return entity;
    }

    CBaseEntity@ Create( dictionary&in keyvalues, CBaseEntity@ owner, bool spawnNow = true )
    {
        return Create( keyvalues, ( owner !is null ? owner.edict() : null ) , spawnNow);
    }

    CBaseEntity@ Create( const string&in classname, dictionary&in keyvalues, edict_t@ owner = null, bool spawnNow = true )
    {
        keyvalues[ "classname" ] = classname;
        return Create( keyvalues, owner, spawnNow);
    }

    CBaseEntity@ Create( const string&in classname, dictionary&in keyvalues, CBaseEntity@ owner, bool spawnNow = true )
    {
        return Create( classname, keyvalues, ( owner !is null ? owner.edict() : null ), spawnNow );
    }
}
