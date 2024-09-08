#incude "as_register"

namespace lp_mapvote
{
    void MapInit()
    {

    }

    class lp_mapvote : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Spawn() 
        {
            self.pev.solid = SOLID_NOT;
            SetBBOX();
            BaseClass.Spawn();
        }
    }

    void Think()
    {        
        if( g_PlayerFuncs.GetNumPlayers() == 0 )
            return;

        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null and pPlayer.IsAlive() )
            {
                CBaseEntity Platform = null;

                while( ( @Platform = g_EntityFuncs.FindEntityByClassname( Platform, 'lp_mapvote' ) ) !is null && Platform.Intersects( pPlayer ) )
                {
                    Platform.pev.frags
                }
            }
        }
    }
}