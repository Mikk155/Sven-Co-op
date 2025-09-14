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

namespace MapUpgrader.BSP;

/// <summary>
/// 3D Vector representing x/y/z
/// </summary>
public class Vector
{
    /// <summary>X position [0]</summary>
    public float x { get; set; }

    /// <summary>Y position [1]</summary>
    public float y { get; set; }

    /// <summary>Z position [2]</summary>
    public float z { get; set; }

    public static readonly Vector g_VecZero = new Vector( 0, 0, 0 );

    /// <summary>
    /// Get a Vector whose all values are zero
    /// </summary>
    public Vector vecZero => g_VecZero;

    public Vector( string vec )
    {
        string[] veclist = vec.Split( " " );

        if( veclist.Length > 0 )
        {
            x = int.TryParse( veclist[0], out int xp ) ? xp : 0;

            if( veclist.Length > 1 )
            {
                x = int.TryParse( veclist[1], out int yp ) ? yp : 0;

                if( veclist.Length > 2 )
                {
                    x = int.TryParse( veclist[2], out int zp ) ? zp : 0;
                }
            }
        }
    }

    public Vector()
    {
        x = 0;
        y = 0;
        z = 0;
    }

    public Vector( Vector vec )
    {
        x = vec.x;
        y = vec.y;
        z = vec.z;
    }

    public Vector( int vx, int vy, int vz )
    {
        x = vx;
        y = vy;
        z = vz;
    }

    /// <summary>Return a string representing the x y z separated by a single space</summary>
    public override string ToString() => $"{x} {y} {z}";

    public float this[ int index ]
    {
        get
        {
            return index switch
            {
                0 => x,
                1 => y,
                2 => z,
                _ => throw new NotImplementedException()
            };
        }
        set
        {
            switch( index )
            {
                case 0:
                    x = value;
                break;
                case 1:
                    y = value;
                break;
                case 2:
                    z = value;
                break;
                default:
                    throw new NotImplementedException();
            }
        }
    }

    public static bool operator ==( Vector left, Vector right )
    {
        if( ReferenceEquals( left, right ) )
            return true;
        if( left is null || right is null )
            return false;
        return left.x == right.x && left.y == right.y && left.z == right.z;
    }

    public static bool operator !=(Vector left, Vector right)
    {
        return !(left == right);
    }

    public override bool Equals( object? obj )
    {
        if( obj is Vector other )
            return this == other;
        return false;
    }

    public override int GetHashCode()
    {
        return HashCode.Combine( x, y, z );
    }
}
