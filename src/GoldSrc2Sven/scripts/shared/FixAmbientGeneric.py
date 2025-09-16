'''**deprecated** Fix Half-Life "loop" type ambient_generic not looping in Sven Co-op.'''

from netapi.NET import *

@deprecated( "context.upgrade.FixAmbientGenericNonLooping", True, False )
def FixAmbientGeneric( context: Map ) -> None:

    '''**deprecated** Fix Half-Life "loop" type ambient_generic not looping in Sven Co-op.'''

    for entity in context.entities:

        if entity.GetString( "classname" ) == "ambient_generic" and not entity.HasFlag( "spawnflags", 16 ):

            entity.SetInteger( "playmode", 2 );
