'''Fix trigger_changelevel'''

from netapi.NET import *

def FixAmbientGeneric( context: Map ) -> None:

    '''Fix trigger_changelevel'''

    for entity in context.entities:

        if entity.GetString( "classname" ) == "trigger_changelevel":

            entity.SetInteger( "keep_inventory", 1 );
