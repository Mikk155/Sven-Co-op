'''Fix Half-Life "loop" type ambient_generic not looping in Sven Co-op.'''

from netapi.NET import *

def FixAmbientGeneric( context: Map ) -> None:

    '''Fix Half-Life "loop" type ambient_generic not looping in Sven Co-op.'''

    for entity in context.entities:

        if entity.GetString( "classname" ) == "" and not entity.HasFlag( "spawnflags", 16 ):

            entity.SetInteger( "playmode", 2 );
