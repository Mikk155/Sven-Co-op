/*
g_SoundSystem.PrecacheSound( 'null.wav' );
g_SoundSystem.PrecacheSound( 'bts_rc/player/pl_drown1.wav' );
g_Game.PrecacheGeneric( 'sound/bts_rc/player/pl_drown1.wav' );

// Scientist class
array<string> szScientistVoiceModels = {
    "bts_scientist",
    "bts_scientist2",
    "bts_scientist3",
    "bts_scientist4"
};

for( uint model = 0; model < szScientistVoiceModels.length(); model++ )
{
    CPlayerVoiceResponse pVoiceModels;

    // Set something else specific per class? otherwise just modify the default value in the class.
    // pVoiceModels.cooldown = 2.0f;
    // pVoiceModels.minimun_damage = 1;

    pVoiceModels.model = szScientistVoiceModels[ model ];

    for( int i = 1; i < 10; i++ )
        pVoiceModels.push_back( "scientist/sci_pain" + string(i) + ".wav" );

    for( int i = 1; i < 4; i++ )
        pVoiceModels.push_back( "scientist/sci_die" + string(i) + ".wav", true );

    gpVoiceResponses.push_back( @pVoiceModels );
}

// Barney class
array<string> szBarneyVoiceModels = {
    "bts_otis",
    "bts_barney"
};

for( uint model = 0; model < szBarneyVoiceModels.length(); model++ )
{
    CPlayerVoiceResponse pVoiceModels;

    pVoiceModels.model = szBarneyVoiceModels[ model ];

    for( int i = 1; i < 3; i++ )
        pVoiceModels.push_back( "barney/ba_pain" + string(i) + ".wav" );

    for( int i = 1; i < 3; i++ )
        pVoiceModels.push_back( "barney/ba_die" + string(i) + ".wav", true );

    gpVoiceResponses.push_back( @pVoiceModels );
}

// Default class
CPlayerVoiceResponse pDefaultVoice;

for( int i = 1; i < 4; i++ )
    pDefaultVoice.push_back( "bts_rc/player/pl_pain" + string(i) + ".wav" );

for( int i = 1; i < 4; i++ )
    pDefaultVoice.push_back( "bts_rc/player/pl_death" + string(i) + ".wav", true );

gpVoiceResponses.push_back( @pDefaultVoice );
in PlayerTakeDamageHook
if( pDamageInfo.pVictim !is null )
{
    gpVoiceResponses.PlayerHurt(
        cast<CBasePlayer@>( pDamageInfo.pVictim ),
        pDamageInfo.pInflictor,
        pDamageInfo.pAttacker,
        pDamageInfo.flDamage,
        pDamageInfo.bitsDamageType
    );
}
*/
class CPlayerVoiceResponse
{
    string model;

    float cooldown = 5.0f;
    float minimun_damage = 5;

    array<string> Killed;
    array<string> Hurt;

    void push_back( const string &in sSound, bool IsKilled = false )
    {
        g_SoundSystem.PrecacheSound( sSound );
        g_Game.PrecacheGeneric( 'sound/' + sSound );

        if( IsKilled )
            Killed.insertLast( sSound );
        else
            Hurt.insertLast( sSound );
    }

    string opIndex( array<string> asList )
    {
        return ( asList.length() > 0 ? asList[ Math.RandomLong( 0, asList.length() - 1 ) ] : "null.wav" );
    }
}

final class CPlayerVoiceResponses
{
    private dictionary gData;

    void push_back( CPlayerVoiceResponse@ VoiceData )
    {
        gData[ ( VoiceData.model.IsEmpty() ? "*" : VoiceData.model ) ] = VoiceData;
    }

    private CPlayerVoiceResponse@ GetVoiceData( CBasePlayer@ pPlayer )
    {
        const string sModel = g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() ).GetValue( "model" ).ToLowercase();

        if( gData.exists( sModel ) )
        {
            return CPlayerVoiceResponse( gData[ sModel ] );
        }
        return CPlayerVoiceResponse( gData[ "*" ] );
    }

    void PlayerHurt( CBasePlayer@ pPlayer, CBaseEntity@ pInflictor, CBaseEntity@ pAttacker, float flDamage, int bitsDamageType )
    {
        if( pPlayer is null )
        {
            return;
        }

        CPlayerVoiceResponse@ pVoice = GetVoiceData( pPlayer );

        if( flDamage < pVoice.minimun_damage )
        {
            return;
        }

        float flCooldown = g_Engine.time + pVoice.cooldown;

        bool blKilled = ( flDamage >= pPlayer.pev.health );

        if( flCooldown > pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_player_voices_last_sound' ).GetFloat() )
        {
            pPlayer.GetCustomKeyvalues().SetKeyvalue( '$f_player_voices_last_sound', flCooldown );
        }
        else if( !blKilled )
        {
            return;
        }

        switch( pPlayer.pev.waterlevel )
        {
            case WATERLEVEL_HEAD:
            {
    			g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_VOICE, "bts_rc/player/pl_drown1.wav", 1, ATTN_NORM );
                break;
            }

            default:
            {
                string sSound = pVoice[ ( blKilled ? pVoice.Killed : pVoice.Hurt ) ];
                g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_VOICE, sSound, 1, ATTN_NORM );
                break;
            }
		}
    }
}

CPlayerVoiceResponses gpVoiceResponses;
