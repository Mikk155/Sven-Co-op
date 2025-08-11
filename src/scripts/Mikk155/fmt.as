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

namespace fmt
{
    /**
    <summary>
        <return>array<string></return>
        <body>fmt::SplitBuffer</body>
        <prefix>fmt::SplitBuffer, SplitBuffer</prefix>
        <description>Split the given string into an array by the given size deliiter for each element</description>
    </summary>
    **/
    array<string> SplitBuffer( string buffer, uint size )
    {
        array<string> list;

        uint length = buffer.Length();

        while( length > 0 )
        {
            length = buffer.Length();

            if( length > size )
            {
                list.insertLast( buffer.SubString( 0, size - 1 ) );
                buffer = buffer.SubString( size - 1 );
            }
            else
            {
                list.insertLast( buffer );
                break;
            }
        }

        return list;
    }
}
