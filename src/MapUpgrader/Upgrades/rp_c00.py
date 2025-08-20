def main( mapname: str, entities ) -> str:
    print( f"[Python] Updating classname of entities for map {mapname}" );
    for entity in entities:
        if entity.classname == "info_player_start":
            entity.classname = "info_player_deathmatch";
            print( f"[Python] updated player spawnpoints" );
    return 0;
