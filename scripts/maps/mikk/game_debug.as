#include "utils"
namespace game_debug
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_debug::entity", "game_debug" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_debug\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Show Debug messages if it is active.\n"
        );
    }

    class entity : ScriptBaseEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            string Message = g_Util.StringReplace( string_t( self.pev.message ),
            {
                { "!frags", string( self.pev.frags ) },
                { "!iuser1", string( self.pev.iuser1 ) },
                { "!activator", string( pActivator.pev.classname ) + " " + ( pActivator.IsPlayer() ? string( pActivator.pev.netname ) : string( pActivator.pev.targetname ) ) },
                { "!caller", string( pCaller.pev.classname ) + " " + ( pCaller.IsPlayer() ? string( pCaller.pev.netname ) : string( pCaller.pev.targetname ) ) },
                { "!netname", string( self.pev.netname ) }
            } );

            g_Util.DebugMessage( "[DEBUG] " + Message );
        }
    }
}
// End of namespace