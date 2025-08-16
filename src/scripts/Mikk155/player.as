/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

namespace player
{
    enum FindFilter
    {
        None = 0,
        Alive = ( 1 << 0 ),
        Dead = ( 1 << 1 )
    };

    /**
    <summary>
        <return>array<CBasePlayer@></return>
        <body>player::NumberOfPlayers( const player::FindFilter filter = player::FindFilter::None )</body>
        <prefix>player::NumberOfPlayers, NumberOfPlayers</prefix>
        <description>Gets the number of connected players matching the filters (see player::player::FindFilter enum)</description>
    </summary>
    **/
    array<CBasePlayer@> NumberOfPlayers( const player::FindFilter filter = player::FindFilter::None )
    {
        if( g_PlayerFuncs.GetNumPlayers() == 0 )
            return {};

        array<CBasePlayer@> list;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            auto player = g_PlayerFuncs.FindPlayerByIndex(i);

            if( player is null )
                continue;

            if( filter != player::FindFilter::None )
            {
                if( ( filter & player::FindFilter::Alive ) != 0 && player.IsAlive() )
                    continue;
                if( ( filter & player::FindFilter::Dead ) != 0 && !player.IsAlive() )
                    continue;
            }

            list.insertLast( @player );
        }

        return list;
    }
}
