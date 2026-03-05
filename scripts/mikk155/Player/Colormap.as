namespace Player
{
    /**
    *   @brief Utility methods related to player's colormap variable.
    **/
    namespace Colormap
    {
        /**
        *   @brief Value returned by Bottom and Top if the player is null.
        **/
        const float InvalidColor = -1;

        /**
        *   @brief Bottom color value. return InvalidColor if the player is null.
        **/
        float Bottom( CBasePlayer@ player )
        {
            if( player is null )
                return InvalidColor;

            return float( float( uint8( ( player.pev.colormap & 0xFF00 ) >> 8 ) ) / 255.0f );
        }

        /**
        *   @brief Top color value. return InvalidColor if the player is null.
        **/
        float Top( CBasePlayer@ player )
        {
            if( player is null )
                return InvalidColor;

            return float( float( uint8( player.pev.colormap & 0x00FF ) ) / 255.0f );
        }
    }
}