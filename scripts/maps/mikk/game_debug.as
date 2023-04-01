#include "utils"
namespace game_debug
{
	bool Register = g_Util.CustomEntity( 'game_debug::game_debug','game_debug' );

    class game_debug : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            string Message = g_Util.StringReplace( string_t( self.pev.message ),
            {
                { "!frags", string( self.pev.frags ) },
                { "!iuser1", string( self.pev.iuser1 ) },
                { "!activator", ( pActivator is null ) ? 'null' : string( pActivator.pev.classname ) + " " + ( pActivator.IsPlayer() ? string( pActivator.pev.netname ) : string( pActivator.pev.targetname ) ) },
                { "!caller", ( pCaller is null ) ? 'null' : string( pCaller.pev.classname ) + " name " + ( pCaller.IsPlayer() ? string( pCaller.pev.netname ) : string( pCaller.pev.targetname ) ) },
                { "!netname", string( self.pev.netname ) },
                { "!usetype", string( useType ) }
            } );

            g_Util.Debug( "[DEBUG] " + Message );
        }
    }
}
// End of namespace