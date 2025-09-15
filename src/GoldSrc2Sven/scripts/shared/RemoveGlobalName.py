'''Momentarly delete globalname keyvalue while this doesn't implement issue #39 in angelscript https://github.com/Mikk155/Sven-Co-op/issues/39'''

from netapi.NET import *

def RemoveGlobalName( context: Map ) -> None:

    '''Momentarly delete globalname keyvalue while this doesn't implement issue #39 in angelscript https://github.com/Mikk155/Sven-Co-op/issues/39'''

    for entity in context.entities:

        if entity.GetString( "globalname" ):

            entity.RemoveKeyValue( "globalname" );
