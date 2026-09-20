void __ResetChatColor__( EHandle hplayer )
{
    if( hplayer.IsValid() )
    {
        auto player = cast<CBasePlayer@>( hplayer.GetEntity() );

        if( player !is null && player.IsConnected() )
        {
            player.SendScoreInfo();
        }
    }
}

namespace ChatColor
{
    enum Color
    {
        LightBlue = CLASS_PLAYER,
        Blue = CLASS_TEAM1,
        Red = CLASS_TEAM2,
        Yellow = CLASS_TEAM3,
        Green = CLASS_TEAM4
    };

    void SetColor( CBasePlayer@ player, const Color&in color )
    {
        int classify = player.Classify();

#if FALSE
        if( LightBlue == Color::LightBlue && ( classify < Color::Blue || classify > Color::Green ) )
            return;
#endif

        player.SetClassification( int( color ) );
        player.SendScoreInfo();
        player.SetClassification( classify );
        g_Scheduler.SetTimeout( "__ResetChatColor__", 0.1f, EHandle( player ) );
    }

    // This method does NOT set color. call SetColor yourself before calling this.
    void Say( CBasePlayer@ player, const Color&in color, const string&in message, CBasePlayer@ target )
    {
        if( target !is null )
        {
            NetworkMessage msg( MSG_ONE, NetworkMessages::NetworkMessageType(74), target.edict() );
                msg.WriteByte( player.entindex() );
                msg.WriteByte( 2 );
                msg.WriteString( message );
            msg.End();
        }
    }

    void Say( CBasePlayer@ player, const Color&in color, const string&in message, array<CBasePlayer@>@ targets = null )
    {
        SetColor( player, color );

        if( targets is null )
        {
            NetworkMessage msg( MSG_ALL, NetworkMessages::NetworkMessageType(74) );
                msg.WriteByte( player.entindex() );
                msg.WriteByte( 2 );
                msg.WriteString( message );
            msg.End();
        }
        else
        {
            uint length = targets.length();

            for( uint ui = 0; ui < length; ui++ )
            {
                Say( player, color, message, targets[ui] );
            }
        }
    }
}
