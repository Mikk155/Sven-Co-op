CEffects g_Effect;
final class CEffects
{
    void fog
    (
        CBasePlayer@ pPlayer,
        int iflag = 1,
        uint8 R = 255,
        uint8 G = 255,
        uint8 B = 255,
        int startdist = 128,
        int enddist = 1024
    ){
        NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::Fog, pPlayer.edict() );
            msg.WriteShort(0);
            msg.WriteByte(iflag);
            msg.WriteCoord(0);
            msg.WriteCoord(0);
            msg.WriteCoord(0);
            msg.WriteShort(0);
            msg.WriteByte(R);
            msg.WriteByte(G);
            msg.WriteByte(B);
            msg.WriteShort(startdist);
            msg.WriteShort(enddist);
        msg.End();
    }

    void beamfollow(
    CBaseEntity@ pEntity,
    string iszModel,
    int ifadetime,
    int iscale,
    Vector VecColor,
    int irenderamt
    ){
        int iEntityIndex = g_EntityFuncs.EntIndex( pEntity.edict() );
        NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            message.WriteByte( TE_BEAMFOLLOW );
            message.WriteShort( iEntityIndex );
            message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            message.WriteByte( ifadetime );
            message.WriteByte( iscale );
            message.WriteByte( int( VecColor.x ) );
            message.WriteByte( int( VecColor.y ) );
            message.WriteByte( int( VecColor.z ) );
            message.WriteByte( irenderamt );
        message.End();
    }

    void spritefield(
    Vector VecStart,
    string iszModel,
    uint16 radius = 128,
    uint8 count = 128, 
    uint8 flags = 30,
    uint8 life = 5
    ){
        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            m.WriteByte( TE_FIREFIELD );
            m.WriteCoord( VecStart.x );
            m.WriteCoord( VecStart.y );
            m.WriteCoord( VecStart.z );
            m.WriteShort( radius );
            m.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            m.WriteByte( count );
            m.WriteByte( flags );
            m.WriteByte( life );
        m.End();
    }

    void dlight
    (
        Vector VecStart,
        Vector VecColor,
        uint8 i8radius = 32,
        uint8 i8life = 255, 
        uint8 i8noise = 255
    ){
        NetworkMessage dlight( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            dlight.WriteByte( TE_DLIGHT );

            dlight.WriteCoord( VecStart.x );
            dlight.WriteCoord( VecStart.y );
            dlight.WriteCoord( VecStart.z );

            dlight.WriteByte( i8radius );
            dlight.WriteByte( int( VecColor.x ) );
            dlight.WriteByte( int( VecColor.y ) );
            dlight.WriteByte( int( VecColor.z ) );
            dlight.WriteByte( i8life );
            dlight.WriteByte( i8noise );
        dlight.End();
    }

    void toxic
    (
        Vector VecStart
    ){
        NetworkMessage message( MSG_PVS, NetworkMessages::ToxicCloud );
        message.WriteCoord( VecStart.x );
        message.WriteCoord( VecStart.y );
        message.WriteCoord( VecStart.z );
        message.End();
    }

    void disk
    (
        Vector VecStart,
        string iszModel,
        uint8 iRadius,
        Vector VecColor,
        int renderamt,
        uint8 startFrame,
        uint8 HoldTime
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte(TE_BEAMDISK);
            Message.WriteCoord( VecStart.x);
            Message.WriteCoord( VecStart.y);
            Message.WriteCoord( VecStart.z);
            Message.WriteCoord( VecStart.x);
            Message.WriteCoord( VecStart.y);
            Message.WriteCoord( VecStart.z + iRadius );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( startFrame );
            Message.WriteByte( 16 );
            Message.WriteByte( HoldTime );
            Message.WriteByte(1);
            Message.WriteByte(0);
            Message.WriteByte( atoui( VecColor.x ) );
            Message.WriteByte( atoui( VecColor.y ) );
            Message.WriteByte( atoui( VecColor.z ) );
            Message.WriteByte( renderamt );
            Message.WriteByte( 0 );
        Message.End();
    }

    void splash
    (
        Vector VecStart,
        Vector VecVelocity,
        uint uiColor,
        uint uiSpeed,
        uint uiNoise,
        uint uiCount

    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_STREAK_SPLASH );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecVelocity.x );
            Message.WriteCoord( VecVelocity.y );
            Message.WriteCoord( VecVelocity.z );
            Message.WriteByte( uiColor );
            Message.WriteShort( uiCount );
            Message.WriteShort( uiSpeed );
            Message.WriteShort( uiNoise );
        Message.End();
    }

    void tracer
    (
        Vector VecStart,
        Vector VecVelocity,
        uint uiHoldtime,
        uint uiLength,
        uint uiColor

    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_USERTRACER );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecVelocity.x  );
            Message.WriteCoord( VecVelocity.y  );
            Message.WriteCoord( VecVelocity.z  );
            Message.WriteByte( uiHoldtime );
            Message.WriteByte( uiColor );
            Message.WriteByte( uiLength );
        Message.End();
    }

    void spriteshooter
    (
        Vector VecStart,
        string iszModel,
        int iCount,
        int iLife,
        int iScale,
        int iNoise
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_SPRITETRAIL );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( iCount );
            Message.WriteByte( iLife );
            Message.WriteByte( iScale );
            Message.WriteByte( iNoise );
            Message.WriteByte( 16 );
        Message.End();
    }

    void quake
    (
        Vector VecStart,
        int iFlags
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( ( iFlags == 0 ) ? TE_TAREXPLOSION : TE_TELEPORT  );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
        Message.End();
    }

    void implosion
    (
        Vector VecStart,
        uint8 i8Radius,
        uint8 i8Count,
        uint8 i8Life
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_IMPLOSION );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteByte( i8Radius );
            Message.WriteByte( i8Count );
            Message.WriteByte( i8Life );
        Message.End();
    }

    void cylinder
    (
        Vector VecStart,
        string iszModel,
        uint8 iRadius,
        int iFlags,
        Vector VecColor,
        int renderamt,
        uint8 scrollSpeed,
        uint8 startFrame,
        uint8 frameRate,
        uint8 life
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( ( iFlags == 0 ) ? TE_BEAMCYLINDER : TE_BEAMTORUS );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z + iRadius );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( startFrame );
            Message.WriteByte( frameRate );
            Message.WriteByte( life );
            Message.WriteByte( 8 );
            Message.WriteByte( 0 );
            Message.WriteByte( atoui( VecColor.x ) );
            Message.WriteByte( atoui( VecColor.y ) );
            Message.WriteByte( atoui( VecColor.z ) );
            Message.WriteByte( renderamt );
            Message.WriteByte( scrollSpeed );
        Message.End();
    }

    void smoke
    (
        Vector VecStart,
        string iszModel,
        int iscale,
        int iframerate
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_SMOKE );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( iscale );
            Message.WriteByte( iframerate );
        Message.End();
    }
}