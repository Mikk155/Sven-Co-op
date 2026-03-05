namespace Entity
{
    bool Precache( dictionary@ keyvalues )
    {
        CBaseEntity@ entity = g_EntityFuncs.CreateEntity( string( keyvalues[ "classname" ] ), keyvalues, false );

        if( entity is null )
            return false;

        entity.Precache();
        entity.pev.flags |= FL_KILLME;

        return true;
    }

    bool Precache( string classname, dictionary@ keyvalues )
    {
        keyvalues[ "classname" ] = classname;
        return Precache( keyvalues );
    }
}
