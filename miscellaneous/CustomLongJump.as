#include "../../../mikk/datashared"
#include "../../../mikk/EntityFuncs"

const int PLAYER_LONGJUMP_SPEED = 400;

namespace CustomLongJump
{
    int Instance = 0;

    bool Register()
    {
        datashared::SetData( { { "initialised", true } }, "CustomLongJump" );
        return true;
    }
    bool bRegister = Register();

    void MapInit()
    {
        Instance = Instance + ( bool( datashared::GetData( "CustomLongJump" )[ "initialised" ] ) ? 1 : 0 );

        // There are a map_script running
        if( Instance > 1 )
            return;

        g_Game.PrecacheGeneric( "sound/player/pl_long_jump.wav" );
        g_SoundSystem.PrecacheSound( "player/pl_long_jump.wav" );

        g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @CustomLongJump::PlayerTakeDamage );
        g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @CustomLongJump::PlayerPostThink );
    }

    void DoEffect( CBasePlayer@ pPlayer )
    {
        TraceResult tr;
        g_Utility.TraceLine( pPlayer.pev.origin, Vector( 0, 0, -90 ) * 100, ignore_monsters, pPlayer.edict(), tr );

        NetworkMessage msg( MSG_PAS, NetworkMessages::SVC_TEMPENTITY );
            msg.WriteByte(TE_BEAMTORUS);
            msg.WriteCoord( tr.vecEndPos.x );
            msg.WriteCoord( tr.vecEndPos.y );
            msg.WriteCoord( tr.vecEndPos.z);
            msg.WriteCoord( tr.vecEndPos.x );
            msg.WriteCoord( tr.vecEndPos.y );
            msg.WriteCoord( tr.vecEndPos.z + 128 );
            msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/laserbeam.spr" ) );
            msg.WriteByte( 0 ); // frame
            msg.WriteByte( 0 ); // framerate
            msg.WriteByte( 5 ); // life
            msg.WriteByte( 16 ); // width
            msg.WriteByte( 0 ); // noise
            msg.WriteByte( 255 ); // R
            msg.WriteByte( 255 ); // G
            msg.WriteByte( 255 ); // B
            msg.WriteByte( 60 ); // A
            msg.WriteByte( 0 ); // scrollspeed
        msg.End();
    }

    HookReturnCode PlayerTakeDamage( DamageInfo@ pDamageInfo )
    {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>( pDamageInfo.pVictim );

        if( pPlayer is null )
            return HOOK_CONTINUE;

        if( ( pDamageInfo.bitsDamageType & DMG_FALL ) != 0 && pPlayer.m_fLongJump )
        {
            DoEffect( pPlayer );
            pDamageInfo.flDamage = 0;
            pPlayer.pev.velocity.z = 0;
        }

        return HOOK_CONTINUE;
    }

    HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null || !pPlayer.m_fLongJump || !pPlayer.IsAlive() )
            return HOOK_CONTINUE;

        if( pPlayer.pev.sequence != 9 && ( pPlayer.pev.button & IN_DUCK ) != 0 && pPlayer.pev.velocity.z > 50
        && pPlayer.pev.velocity.Length() > ( pPlayer.pev.maxspeed * 1.4 ) )
        {
            pPlayer.SetAnimation( PLAYER_SUPERJUMP, 1 );
        }

        if( pPlayer.pev.sequence == 9 && atoi( CustomKeyValue( pPlayer, "$s_CustomLongJump" ) ) != 1 )
        {
            Vector VecVelocity =
                ( pPlayer.pev.button & IN_FORWARD ) != 0 ? g_Engine.v_forward :
                    ( pPlayer.pev.button & IN_BACK ) != 0 ? -g_Engine.v_forward :
                        ( pPlayer.pev.button & IN_MOVERIGHT ) != 0 ? g_Engine.v_right :
                            ( pPlayer.pev.button & IN_MOVELEFT ) != 0 ? -g_Engine.v_right :
            g_vecZero;

            if( VecVelocity != g_vecZero )
            {
                pPlayer.pev.velocity.y = VecVelocity.y * PLAYER_LONGJUMP_SPEED * 1.6;
                pPlayer.pev.velocity.x = VecVelocity.x * PLAYER_LONGJUMP_SPEED * 1.6;

                DoEffect( pPlayer );

                CustomKeyValue( pPlayer, "$s_CustomLongJump", 1 );
                g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_STATIC, "player/pl_long_jump.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
            }
        }
        else if( pPlayer.pev.sequence != 9 )
        {
            CustomKeyValue( pPlayer, "$s_CustomLongJump", 0 );
        }

        return HOOK_CONTINUE;
    }
}
