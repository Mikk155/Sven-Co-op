//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "json"
#include "Hooks"
#include "Language"
#include "Reflection"
#include "PlayerFuncs"
#include "EntityFuncs"

MKShared Mikk;

class MKShared
{
    /*
        @prefix Mikk.GetDiscord Discord
        @body Mikk
        Get discord server invite
    */
    string GetDiscord()
    {
        return 'discord.gg/THDKrgBEny';
    }

    /*
        @prefix Mikk.GetContactInfo Contact
        @body Mikk
        Get contact info
    */
    string GetContactInfo()
    {
        return GetDiscord() + " | github.com/Mikk155";
    }

    MKHooks Hooks;
    MKLanguage Language;
    MKPlayerFuncs PlayerFuncs;
    MKEntityFuncs EntityFuncs;

    MKShared()
    {
        Hooks = MKHooks();
        Language = MKLanguage();
        PlayerFuncs = MKPlayerFuncs();
        EntityFuncs = MKEntityFuncs();
    }

    /*
        @prefix Mikk.UpdateTimer UpdateTimer
        @body Mikk
        Clears and sets a CScheduledFunction@ function with the given parameters
    */
    void UpdateTimer( CScheduledFunction@ &out pTimer, string &in szFunction, float flTime, int iRepeat = 0 )
    {
        if( pTimer !is null )
        {
            g_Scheduler.RemoveTimer( pTimer );
        }

        @pTimer = g_Scheduler.SetInterval( "Think", flTime, iRepeat );
    }

    /*
        @prefix Mikk.IsPluginInstalled IsPluginInstalled Plugin Installed IsInstalled
        @body Mikk
        Return whatever the given plugin name is installed on the server.
    */
    bool IsPluginInstalled( string m_iszPluginName, bool bCaseSensitive = false )
    {
        array<string> PluginsList = g_PluginManager.GetPluginList();

        if( bCaseSensitive )
        {
            return ( PluginsList.find( m_iszPluginName ) >= 0 );
        }

        for( uint ui = 0; ui < PluginsList.length(); ui++ )
        {
            if( PluginsList[ui].ToLowercase() == m_iszPluginName.ToLowercase() )
            {
                return true;
            }
        }
        return false;
    }
}

/*
    @prefix atorgba
    Return the given string as a 4D RGBA
*/
RGBA atorgba( const string m_iszFrom )
{
    array<string> aSplit = m_iszFrom.Split( " " );

    while( aSplit.length() < 4 )
        aSplit.insertLast( '0' );

    return RGBA( atoui( aSplit[0] ), atoui( aSplit[1] ), atoui( aSplit[2] ), atoui( aSplit[3] ) );
}

/*
    @prefix atov StringToVector
    Return the given string_t as a 3D Vector
*/
Vector atov( const string m_iszFrom )
{
    Vector m_vTo;
    g_Utility.StringToVector( m_vTo, m_iszFrom );
    return m_vTo;
}

/*
    @prefix atov2 StringToVector
    Return the given string_t as a 2D Vector
*/
Vector2D atov2( const string m_iszFrom )
{
    Vector m_vTo = atov( m_iszFrom );
    return Vector2D( m_vTo.y, m_vTo.x );
}

/*
    @prefix CKV CustomKeyValue
    Return the value of the given CustomKeyValue,
    if m_iszValue is given it will update the value,
    return String::INVALID_INDEX if the given entity is null,
    return String::EMPTY_STRING if the given entity doesn't have the custom key value
*/
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

/*
    @prefix Hue HUEtoRGB
    Return a RGB color from a Hue color
*/
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

/*
    @prefix Hue RGBtoHUE
    Return a Hue color from a RGB color
*/
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