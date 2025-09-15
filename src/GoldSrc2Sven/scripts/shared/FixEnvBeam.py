'''Fix env_beam with bad striketime on a negative value causing massive cpu usage in Sven Co-op.'''

from netapi.NET import *

def FixAmbientGeneric( context: Map ) -> None:

    '''Fix env_beam with bad striketime on a negative value causing massive cpu usage in Sven Co-op.'''

    for entity in context.entities:

        if entity.GetString( "classname" ) == "env_beam" and entity.GetFloat( "striketime" ) < 0:

            entity.SetInteger( "striketime", 0 );
