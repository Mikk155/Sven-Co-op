'''Remap some entities to match Sven Co-op and MP'''

from netapi.NET import *

def RemapEntities( context: Map ) -> None:

    '''Remap some entities to match Sven Co-op and MP'''

    RemapList: dict[str, str] = {
        "info_player_start": "info_player_deathmatch",
        "trigger_endsection": "game_end",
    }

    for entity in context.entities:

        classname: str = entity.GetString( "classname" );

        if classname in RemapList:

            entity.SetString( "classname", RemapList[ classname ] );
