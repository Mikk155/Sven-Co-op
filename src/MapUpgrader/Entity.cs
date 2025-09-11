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

public static class Entity
{
    /// <summary>Get a key's value in string form</summary>
    public static string GetString( this Sledge.Formats.Bsp.Objects.Entity entity, string key )
    {
        return entity.KeyValues.TryGetValue( key, out string? value ) ? value.ToString() : "";
    }

    /// <summary>Set a key's value in string form</summary>
    public static void SetString( this Sledge.Formats.Bsp.Objects.Entity entity, string key, string value )
    {
        entity.KeyValues[ key ] = value;
    }

    /// <summary>Get a key's value in integer form</summary>
    public static int GetInteger( this Sledge.Formats.Bsp.Objects.Entity entity, string key )
    {
        return entity.KeyValues.TryGetValue( key, out string? value ) ? int.TryParse( value.ToString(), out int ivalue ) ? ivalue : 0 : 0;
    }

    /// <summary>Set a key's value in integer form</summary>
    public static void SetInteger( this Sledge.Formats.Bsp.Objects.Entity entity, string key, int value )
    {
        entity.KeyValues[ key ] = value.ToString();
    }

    /// <summary>Get a key's value in float form</summary>
    public static float GetFloat( this Sledge.Formats.Bsp.Objects.Entity entity, string key )
    {
        return entity.KeyValues.TryGetValue( key, out string? value ) ? float.TryParse( value.ToString(), out float ivalue ) ? ivalue : 0.0f : 0.0f;
    }

    /// <summary>Set a key's value in float form</summary>
    public static void SetFloat( this Sledge.Formats.Bsp.Objects.Entity entity, string key, float value )
    {
        entity.KeyValues[ key ] = value.ToString();
    }

    /// <summary>Get a key's value in bool form (0/1)</summary>
    public static bool GetBool( this Sledge.Formats.Bsp.Objects.Entity entity, string key )
    {
        return entity.KeyValues.TryGetValue( key, out string? value ) ? int.TryParse( value.ToString(), out int ivalue ) ? ivalue != 0 : false : false;
    }

    /// <summary>Set a key's value in bool form (0/1)</summary>
    public static void SetBool( this Sledge.Formats.Bsp.Objects.Entity entity, string key, bool value )
    {
        entity.KeyValues[ key ] = value.ToString();
    }

    /// <summary>Get a key's value in Vector form (0/1)</summary>
    public static Vector GetVector( this Sledge.Formats.Bsp.Objects.Entity entity, string key )
    {
        return entity.KeyValues.TryGetValue( key, out string? value ) ? new Vector( value ) : Vector.g_VecZero;
    }

    /// <summary>Set a key's value in Vector form (0/1)</summary>
    public static void SetVector( this Sledge.Formats.Bsp.Objects.Entity entity, string key, Vector value )
    {
        entity.KeyValues[ key ] = value.ToString();
    }

    /// <summary>Return the entity in the .ent format</summary>
    public static string ToString( this Sledge.Formats.Bsp.Objects.Entity entity )
    {
        System.Text.StringBuilder s = new System.Text.StringBuilder();

        s.AppendLine( "{" );

        foreach( KeyValuePair<string, string> keyvalue in entity.KeyValues )
        {
            s.AppendLine( $"\"{keyvalue.Key}\" \"{keyvalue.Value}\"" );
        }

        s.AppendLine( "}" );

        return s.ToString();
    }
}
