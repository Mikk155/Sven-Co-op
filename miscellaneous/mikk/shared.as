#include "Json"
#include "Hooks"
#include "Utility"
#include "Language"
#include "PlayerFuncs"

MKShared Mikk;

class MKShared
{
    // prefix: "GetDiscord", "Discord"
    // description: Get discord server invite
    // body: Mikk
    string GetDiscord()
    {
        return 'https://discord.gg/THDKrgBEny';
    }

    // prefix: "GetContactInfo", "Contact"
    // description: Get contact info
    // body: Mikk
    string GetContactInfo()
    {
        return "\nDiscord Server: " + GetDiscord() + "Github: https://github.com/Mikk155";
    }

    MKJson Json;
    MKHooks Hooks;
    MKUtility Utility;
    MKLanguage Language;
    MKPlayerFuncs PlayerFuncs;

    MKShared()
    {
        Json = MKJson();
        Hooks = MKHooks();
        Utility = MKUtility();
        Language = MKLanguage();
        PlayerFuncs = MKPlayerFuncs();
    }
}


// prefix: "atorgba", "RGBA"
// description: Return the given string as a 4D RGBA
RGBA atorgba( const string m_iszFrom )
{
    array<string> aSplit = m_iszFrom.Split( " " );

    while( aSplit.length() < 4 )
        aSplit.insertLast( '0' );

    return RGBA( atoui( aSplit[0] ), atoui( aSplit[1] ), atoui( aSplit[2] ), atoui( aSplit[3] ) );
}

// prefix: "atov", "StringToVector"
// description: Return the given string_t as a 3D Vector
Vector atov( string_t m_iszFrom )
{
    return atov( string( m_iszFrom ) );
}

// prefix: "atov", "StringToVector"
// description: Return the given string as a 3D Vector
Vector atov( const string m_iszFrom )
{
    Vector m_vTo;
    g_Utility.StringToVector( m_vTo, m_iszFrom );
    return m_vTo;
}

// prefix: "CKV", "CustomKeyValue"
// description: Return the value of the given CustomKeyValue, if m_iszValue is given it will update the value, return String::INVALID_INDEX if the given entity is null, return String::EMPTY_STRING if the given entity doesn't have the custom key value
string CustomKeyValue( CBaseEntity@ pEntity, const string&in m_iszKey, const string&in m_iszValue = String::EMPTY_STRING )
{
    if( pEntity is null )
    {
        return String::INVALID_INDEX;
    }

    if( m_iszValue != String::EMPTY_STRING )
    {
        g_EntityFuncs.DispatchKeyValue( pEntity.edict(), m_iszKey, m_iszValue );
    }

    if( !pEntity.GetCustomKeyvalues().HasKeyvalue( m_iszKey ) )
    {
        return String::EMPTY_STRING;
    }

    return pEntity.GetCustomKeyvalues().GetKeyvalue( m_iszKey ).GetString();
}


// prefix: "Hue", "HUEtoRGB"
// description: Return a RGB color from a Hue color
RGBA HUEtoRGB( float H )
{
    float R, G, B;
    float S = 1.0f;
    float V = 1.0f;

    int H_i = int(H * 6.0f);
    float f = H * 6.0f - H_i;
    float p = V * (1.0f - S);
    float q = V * (1.0f - f * S);
    float t = V * (1.0f - (1.0f - f) * S);

    switch(H_i % 6)
    {
        case 0: R = V; G = t; B = p; break;
        case 1: R = q; G = V; B = p; break;
        case 2: R = p; G = V; B = t; break;
        case 3: R = p; G = q; B = V; break;
        case 4: R = t; G = p; B = V; break;
        case 5: R = V; G = p; B = q; break;
    }

    return RGBA( Math.clamp( 0, 255, int( R * 255.f ) ), Math.clamp( 0, 255.0f, int( G * 255.0f ) ), Math.clamp( 0, 255, int( B * 255.0f ) ), 255 );
}

// prefix: "Hue", "RGBtoHUE"
// description: Return a Hue color from a RGB color
float RGBtoHUE(Vector rgb)
{
    float R = rgb.x;
    float G = rgb.y;
    float B = rgb.z;

    float maxColor = Math.max(Math.max(R, G), B);
    float minColor = Math.min(Math.min(R, G), B);

    float H;

    if (maxColor == minColor)
    {
        H = 0.0f;
    }
    else if (maxColor == R)
    {
        H = (G - B) / (maxColor - minColor);
        if (G < B)
            H += 6.0f;
    }
    else if (maxColor == G)
    {
        H = 2.0f + (B - R) / (maxColor - minColor);
    }
    else
    {
        H = 4.0f + (R - G) / (maxColor - minColor);
    }

    H /= 6.0f;

    if (H < 0.0f)
        H += 1.0f;

    return H;
}