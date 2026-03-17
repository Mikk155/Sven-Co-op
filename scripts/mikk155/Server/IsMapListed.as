/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

namespace Server
{
    /**
    *   @brief Return whatever the current map is in the given list
    *   allowWildcarding: Allow "*" as wildcarding for suffix and prefix
    **/
    bool IsMapListed( array<string>@ list, bool allowWildcarding = true )
    {
        string mapname = string( g_Engine.mapname );

        if( list.find( mapname ) >= 0 )
            return true;

        if( allowWildcarding )
        {
            for( uint ui = 0; ui < list.length(); ui++ )
            {
                string key = list[ ui ];

                bool HasPrefix = ( key[0] == '*' );
                bool HasSuffix = key.EndsWith( '*' );

                if( HasPrefix && HasSuffix && mapname.Find( key.SubString( 1, key.Length() - 2 ) ) != String::INVALID_INDEX )
                    return true;

                if( HasPrefix && mapname.EndsWith( key.SubString( 1, String::INVALID_INDEX ) ) )
                    return true;

                if( HasSuffix && mapname.StartsWith( key.SubString( 0, key.Length() - 1 ) ) )
                    return true;
            }
        }
        return false;
    }
}
