#include "utils"
namespace game_trigger_iterator
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_trigger_iterator::entity", "game_trigger_iterator" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_trigger_iterator\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Entity that will fire its target with the activator and caller that it specifies.\n"
        );
    }

    class entity : ScriptBaseEntity
    {
        EHandle activator = null;
        EHandle caller = null;

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( string( self.pev.netname ) == "!activator" && pActivator !is null )
            {
                activator = pActivator;
            }
            else if( string( self.pev.netname ) == "!caller" && pCaller !is null )
            {
                activator = pCaller;
            }
            else
            {
                CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, string( self.pev.netname ) );

                if( pEnt !is null )
                {
                    activator = pEnt;
                }
                else
                {
                    activator = self;
                }
            }
            
            if( string( self.pev.message ) == "!activator" && pActivator !is null )
            {
                caller = pActivator;
            }
            else if( string( self.pev.message ) == "!caller" && pCaller !is null )
            {
                caller = pCaller;
            }
            else
            {
                CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, string( self.pev.message ) );

                if( pEnt !is null )
                {
                    caller = pEnt;
                }
                else
                {
                    caller = self;
                }
            }

            g_Util.Trigger
			(
				self.pev.target,
				( activator.GetEntity() is null ) ? self : activator.GetEntity(),
				( caller.GetEntity() is null ) ? self : caller.GetEntity(),
				( self.pev.frags == 1 ) ? USE_OFF :
				( self.pev.frags == 2 ) ? USE_ON :
                ( self.pev.frags == 3 ) ? USE_TOGGLE :
                useType, self.pev.health
            );
        }
    }
}
// End of namespace