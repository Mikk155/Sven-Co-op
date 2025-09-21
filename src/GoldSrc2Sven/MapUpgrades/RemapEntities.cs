/*
MIT License

Copyright (c) 2025 Mikk155

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

namespace GoldSrc2Sven.Upgrades;

using GoldSrc2Sven.Context;
using GoldSrc2Sven.BSP;

public class RemapEntities : IMapUpgrade
{
    public RemapEntities( MapUpgrades upgrader )
    {
        Dictionary<string, string> ent_mapping = new(){
            { "info_player_start", "info_player_deathmatch" },
            { "trigger_endsection", "game_end" }
        };

        foreach( KeyValuePair<string, string> remap in ent_mapping )
        {
            int fixes = 0;

            foreach( Entity entity in upgrader.entities.Where( e => e.GetString( "classname" ) == remap.Key ) )
            {
                fixes++;
                entity.SetString( "classname", remap.Value );
            }

            if( fixes > 0 )
            {
                upgrader.logger.trace
                    .Write( "Converted " )
                    .Write( fixes.ToString(), ConsoleColor.Green )
                    .Write( " " )
                    .Write( remap.Key, ConsoleColor.Cyan )
                    .Write( " entities to " )
                    .WriteLine( remap.Value, ConsoleColor.Green );
            }
        }
    }
}
