#include "utils"
namespace player_talk
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_talk::player_talk", "player_talk" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: player_talk\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow mapper to do use of ClientSayHook as a custom entity.\n"
        );
    }

    enum spawnflags
    {
        SF_CTH_START_OFF  = 1 << 0,
        SF_CTH_TEAM_ONLY  = 1 << 1
    }

    funcdef HookReturnCode ClientSay( SayParameters@ );

    class player_talk : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private bool IsEnabled = true;
        private int hook_mode = 0, fire_when = 0, should_hide = 0, player_target = 0;
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
            else if( szKey == "player_target" ) player_target = atoi( szValue );
            else return BaseClass.KeyValue( szKey, szValue );
            return true;
        }

        void Spawn()
        {
            if( self.pev.SpawnFlagBitSet( SF_CTH_START_OFF ) )
            {
                IsEnabled = false;
            }
            g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay( this.OnClientSay ) );
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
            else
			{
                IsEnabled = !IsEnabled;
            }
        }

        void Target( CBaseEntity@ pPlayer )
        {
            g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
        }

		void UpdateOnRemove()
		{
			g_Util.DebugMessage( 'RemovedEntity' );
            g_Hooks.RemoveHook( Hooks::Player::ClientSay, @ClientSay( this.OnClientSay ) );
			BaseClass.UpdateOnRemove();
		}

		HookReturnCode OnClientSay( SayParameters@ pParams ) 
		{
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            const CCommand@ args = pParams.GetArguments();
            string FullSentence = pParams.GetCommand();

            if( master() )
            {
                return HOOK_CONTINUE;
            }

            if( IsEnabled )
            {
                if( should_hide == 1 )
                {
                    pParams.ShouldHide = true;
                }


                if( args.ArgC() < 1 )
                {
                    return HOOK_CONTINUE;
                }

                if( self.pev.SpawnFlagBitSet( SF_CTH_TEAM_ONLY ) && pParams.GetSayType() != CLIENTSAY_SAYTEAM )
                {
                    pParams.ShouldHide = true;
                    Target( pPlayer );
                }
                
                if( player_target > 0 && pPlayer.GetCustomKeyvalues().GetKeyvalue( "$i_player_talk_level" ).GetInteger() != player_target )
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
    }
}
// End of namespace