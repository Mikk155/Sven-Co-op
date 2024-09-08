#include '../../maps/mikk/as_utils'
#include 'mapblacklist'

string m_szPath = 'scripts/plugins/mikk/MSG/';

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
    m_FileSystem.GetKeyAndValue( m_szPath + 'flashlight_0.txt', flashlight_0, true );
    m_FileSystem.GetKeyAndValue( m_szPath + 'flashlight_1.txt', flashlight_1, true );
    bPrecached = false;
}

bool bPrecached = false;

dictionary flashlight_0;
dictionary flashlight_1;

string m_iszNoBattery  = "buttons/lightswitch2.wav";
string m_iszConsumeBattery  = "items/suitchargeok1.wav";
bool BlackListed;

void MapInit()
{
    g_SoundSystem.PrecacheSound( m_iszNoBattery );
    g_SoundSystem.PrecacheSound( m_iszConsumeBattery );
    bPrecached = true;
    mapblacklist( 'flashlight', BlackListed );
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
    if( !BlackListed && pPlayer !is null && pPlayer.IsConnected() )
    {
        int m_iCurrentBattery;

        if( pPlayer.pev.effects == EF_DIMLIGHT || !m_CustomKeyValue.HasKey( pPlayer, '$i_lp_flashlight' ) )
        {
            m_CustomKeyValue.SetValue( pPlayer, '$i_lp_flashlight' , pPlayer.m_iFlashBattery );
        }
        else
        {
            m_CustomKeyValue.GetValue( pPlayer, '$i_lp_flashlight', m_iCurrentBattery );

            if( pPlayer.m_iFlashBattery > m_iCurrentBattery )
            {
                pPlayer.m_iFlashBattery = m_iCurrentBattery;
            }
        }

        if( pPlayer.pev.impulse == 100 ) 
        {
            if( pPlayer.m_iFlashBattery <= 3 )
            {
                int ib = int( g_EngineFuncs.CVarGetFloat( 'sk_battery' ) );

                if( pPlayer.pev.armorvalue >= ib )
                {
                    m_Language.PrintMessage
                    (
                        pPlayer, flashlight_0, ML_HUD, false,
                        {
                            { '$battery$' , string( ib ) }
                        }
                    );

                    if( bPrecached )
                        g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, m_iszConsumeBattery, 0.8f, ATTN_NORM, 0, PITCH_NORM );

                    pPlayer.pev.armorvalue -= ib;
                    m_CustomKeyValue.SetValue( pPlayer, '$i_lp_flashlight' , 100 );
                    pPlayer.m_iFlashBattery = 100;
                }
                else
                {
                    m_Language.PrintMessage
                    (
                        pPlayer, flashlight_1, ML_HUD, false,
                        {
                            { '$battery$' , string( ib ) }
                        }
                    );

                    if( bPrecached )
                        g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, m_iszNoBattery, 0.8f, ATTN_NORM, 0, PITCH_NORM );

                    pPlayer.pev.impulse = 0;

                    return HOOK_CONTINUE;
                }
            }
        }
    }
    return HOOK_CONTINUE;
}