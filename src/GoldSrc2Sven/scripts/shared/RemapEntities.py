'''**deprecated** Remap some entities to match Sven Co-op and MP'''

from netapi.NET import *

@deprecated( "context.upgrade.RemapEntities", True, False )
def RemapEntities( context: Map ) -> None:

    '''**deprecated** Remap some entities to match Sven Co-op and MP'''

    RemapList: dict[str, str] = {
        "info_player_start": "info_player_deathmatch",
        "trigger_endsection": "game_end",
    }

    for entity in context.entities:

        classname: str = entity.GetString( "classname" );

        if classname in RemapList:

            entity.SetString( "classname", RemapList[ classname ] );
