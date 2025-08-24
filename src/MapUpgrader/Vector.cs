
/// <summary>
/// 3D Vector representing x/y/z
/// </summary>
public class Vector
{
    public float x { get; set; }
    public float y { get; set; }
    public float z { get; set; }

    public static Vector vecZero = new Vector( 0, 0, 0 );

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
