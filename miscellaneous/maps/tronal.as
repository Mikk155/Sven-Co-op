string[][] Remplazar = 
{
    {"ammo_9mmclip", "ammo_cof9mmclip"},

    {"ammo_357", "ammo_cof357"}
};

void MapInit()
{
	g_Scheduler.SetInterval( "Think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void Think()
{
	CBaseEntity@ pOldItem = null;

    for(uint i = 0; i < strMaps.length(); i++)
    {
		while( ( @pOldItem = g_EntityFuncs.FindEntityByClassname( pOldItem, Remplazar[i][0] ) ) !is null )
		{
			CBaseEntity@ pNewItem = g_EntityFuncs.CreateEntity( Remplazar[i][1], null, true);

			if( pNewItem !is null )
			{
				pNewItem.pev.targetname = pOldItem.pev.target;
				pNewItem.pev.target = pOldItem.pev.target;
				pNewItem.pev.angles = pOldItem.pev.angles;
				g_EntityFuncs.SetOrigin( pNewItem, pOldItem.pev.origin );
                g_EntityFuncs.Remove( pOldItem );
			}
		}
	}
	
}