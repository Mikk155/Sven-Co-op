/*
DOWNLOAD:

scripts/maps/mikk/player_talk.as
scripts/maps/mikk/utils.as


INSTALL:


#include "mikk/player_talk"

void MapInit()
{
    player_talk::Register();
}
*/

#include "utils"

namespace player_talk
{
    enum player_clientsay_flags
    {
        SF_CTH_START_OFF  = 1 << 0
    }

    funcdef HookReturnCode ClientSay( SayParameters@ );

    class CTalkHook : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        private bool IsEnabled = true;
        private int hook_mode = 0, fire_when = 0, should_hide = 0;
        private string sendstring_target, sendstring_keyvalue, text_contain, text_contain1, text_contain2, censure_argument;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues(szKey, szValue);
            if( szKey == "hook_mode" ) hook_mode = atoi( szValue );
            else if( szKey == "fire_when" ) fire_when = atoi( szValue );
            else if( szKey == "should_hide" ) should_hide = atoi( szValue );
            else if( szKey == "sendstring_target" ) sendstring_target = szValue;
            else if( szKey == "sendstring_keyvalue" ) sendstring_keyvalue = szValue;
            else if( szKey == "text_contain" ) text_contain = szValue;
            else if( szKey == "text_contain1" ) text_contain1 = szValue;
            else if( szKey == "text_contain2" ) text_contain2 = szValue;
            else if( szKey == "censure_argument" ) censure_argument = szValue;
            else return BaseClass.KeyValue( szKey, szValue );
            return true;
        }

        void Spawn()
        {
            g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay( this.OnClientSay ) );

            if( self.pev.SpawnFlagBitSet( SF_CTH_START_OFF ) )
            {
                IsEnabled = false;
            }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
                return;

            if( useType == USE_ON )
            {
                IsEnabled = true;
            }
            else if( useType == USE_OFF )
            {
                IsEnabled = false;
            }
            else if( useType == USE_KILL )
            {
                UpdateOnRemove();
                IsEnabled = false;
            }
            else
            {
                IsEnabled = !IsEnabled;
            }
        }

        HookReturnCode OnClientSay( SayParameters@ pParams ) 
        {
            if( master() )
                return HOOK_CONTINUE;

            if( IsEnabled )
            {
                if( should_hide == 1 )
                {
                    pParams.ShouldHide = true;
                }

                CBasePlayer@ pPlayer = pParams.GetPlayer();
                const CCommand@ args = pParams.GetArguments();
                string FullSentence = pParams.GetCommand();

                if( args.ArgC() < 1 )
                {
                    return HOOK_CONTINUE;
                }
                
                if( !string( censure_argument ).IsEmpty() )
                {
                    pParams.ShouldHide = true;
                    g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, string( pPlayer.pev.netname ) + ": " + string( FullSentence ).Replace( censure_argument, '*censured*' ) + "\n" );
                }

                if( !string( sendstring_target ).IsEmpty() )
                {
                    CBaseEntity@ pEntityTarget = null;

                    while( ( @pEntityTarget = g_EntityFuncs.FindEntityByTargetname( pEntityTarget, sendstring_target ) ) !is null )
                    {
                        g_EntityFuncs.DispatchKeyValue( pEntityTarget.edict(), sendstring_keyvalue, FullSentence );
                    }
                }

                if( fire_when == 0 && FullSentence.Find( text_contain ) < String::INVALID_INDEX )
                {
                    Target( pPlayer );
                }
                else if( fire_when == 1 && args.Arg(0) == text_contain )
                {
                    Target( pPlayer );
                }
                else if( fire_when == 2 && FullSentence == text_contain )
                {
                    Target( pPlayer );
                }
                else if( fire_when == 3 && args.Arg(0) == text_contain && args.Arg(1) == text_contain1 )
                {
                    Target( pPlayer );
                }
                else if( fire_when == 4 && args.Arg(0) == text_contain && args.Arg(1) == text_contain1 && args.Arg(2) == text_contain2 )
                {
                    Target( pPlayer );
                }
            }
            return HOOK_CONTINUE;
        }

        void UpdateOnRemove()
        {
            g_Hooks.RemoveHook( Hooks::Player::ClientSay, @ClientSay( this.OnClientSay ) );
            IsEnabled = false;

            BaseClass.UpdateOnRemove();
        }

        void Target( CBaseEntity@ pPlayer )
        {
            UTILS::Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_talk::CTalkHook", "player_talk" );
    }
}// end namespace