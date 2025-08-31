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

#pragma warning disable IDE1006 // Naming Styles
/// <summary>Represents a entity in the BSP</summary>
public class Entity( int index )
{
    /// <summary>Represents all the key-values in this entity</summary>
    public Dictionary<string, string> keyvalues = new Dictionary<string, string>();

    public readonly int index = index;

    /// <summary>Represents the current index of this entity in the BSP entity data</summary>
    public int EntIndex
    {
        get
        {
            return this.index;
        }
    }

    /// <summary>Classname of the entity. if this is not a valid entity in the FGD the program will only warn.</summary>
    public string classname
    {
        get
        {
            return keyvalues[ "classname" ];
        }
        set
        {
            keyvalues["classname"] = value;
        }
    }

    /// <summary>Get a key's value in string form</summary>
    public string GetString( string key )
    {
        return keyvalues.TryGetValue( key, out string? value ) ? value.ToString() : "";
    }

    /// <summary>Set a key's value in string form</summary>
    public void SetString( string key, string value )
    {
        keyvalues[ key ] = value;
    }

    /// <summary>Get a key's value in integer form</summary>
    public int GetInteger( string key )
    {
        return keyvalues.TryGetValue( key, out string? value ) ? int.TryParse( value.ToString(), out int ivalue ) ? ivalue : 0 : 0;
    }

    /// <summary>Set a key's value in integer form</summary>
    public void SetInteger( string key, int value )
    {
        keyvalues[ key ] = value.ToString();
    }

    /// <summary>Get a key's value in float form</summary>
    public float GetFloat( string key )
    {
        return keyvalues.TryGetValue( key, out string? value ) ? float.TryParse( value.ToString(), out float ivalue ) ? ivalue : 0.0f : 0.0f;
    }

    /// <summary>Set a key's value in float form</summary>
    public void SetFloat( string key, float value )
    {
        keyvalues[ key ] = value.ToString();
    }

    /// <summary>Get a key's value in bool form (0/1)</summary>
    public bool GetBool( string key )
    {
        return keyvalues.TryGetValue( key, out string? value ) ? int.TryParse( value.ToString(), out int ivalue ) ? ivalue != 0 : false : false;
    }

    /// <summary>Set a key's value in bool form (0/1)</summary>
    public void SetBool( string key, bool value )
    {
        keyvalues[ key ] = value.ToString();
    }

    /// <summary>Get a key's value in bool form (0/1)</summary>
    public Vector GetVector( string key )
    {
        return keyvalues.TryGetValue( key, out string? value ) ? new Vector( value ) : Vector.vecZero;
    }

    /// <summary>Set a key's value in bool form (0/1)</summary>
    public void SetVector( string key, Vector value )
    {
        keyvalues[ key ] = value.ToString();
    }

    /// <summary>Return the entity in the .ent format</summary>
    public override string ToString()
    {
        System.Text.StringBuilder s = new System.Text.StringBuilder();

        s.AppendLine( "{" );
        s.AppendLine( $"\"classname\" \"{classname}\"" );

        foreach( KeyValuePair<string, string> keyvalue in this.keyvalues )
        {
            if( keyvalue.Key == "classname" )
                continue;

            s.AppendLine( $"\"{keyvalue.Key}\" \"{keyvalue.Value}\"" );
        }

        s.AppendLine( "}" );

        return s.ToString();
    }
}
#pragma warning restore IDE1006 // Naming Styles
