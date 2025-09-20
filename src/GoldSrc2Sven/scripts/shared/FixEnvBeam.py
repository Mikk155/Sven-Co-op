'''**deprecated** Fix env_beam with bad striketime on a negative value causing massive cpu usage in Sven Co-op.'''

from netapi.NET import *

@deprecated( "context.upgrade.FixEnvBeamStrikeTime", True, False )
def FixEnvBeam( context: Map ) -> None:

    '''**deprecated** Fix env_beam with bad striketime on a negative value causing massive cpu usage in Sven Co-op.'''

    for entity in context.entities:

        if entity.GetString( "classname" ) == "env_beam" and entity.GetFloat( "striketime" ) < 0:

            entity.SetInteger( "striketime", 0 );
