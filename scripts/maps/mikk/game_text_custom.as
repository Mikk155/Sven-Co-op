#include "utils"
namespace game_text_custom
{
    void Register( const string& in szClassname = 'game_text_custom' )
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom::entity", szClassname );

        g_Util.ScriptAuthor.insertLast
		(
			"Script: game_text_custom"
			"\nAuthor: Mikk"
			"\nGithub: github.com/Mikk155"
			"\nAuthor: Gaftherman"
			"\nGithub: github.com/Gaftherman"
			"\nAuthor: Kmkz"
			"\nGithub: github.com/kmkz27"
			"\nDescription: New entity replacemet for game_text and env_message with lot of new additions.\n"
		);
    }

    enum spawnflags
    {
        SF_GTC_ALL_PLAYERS = 1,
		SF_GTC_NO_ECHO_CON = 2,
		SF_GTC_FIRE_PER_PLAYER = 4,
		SF_GTC_PLAY_ONCE = 8
    };

    class entity : ScriptBaseEntity,
    game_text_custom::ScriptBaseGameText,
    ScriptBaseLanguages, ScriptBaseCustomEntity
    {
        // Call current activator at any time
        EHandle EhActivator = self;

        private string
        key_string,
        focus_entity,
        messagesound,
        key_from_entity;

        private float
        messagevolume = 10,
        messageattenuation = 0,
        key_float;

        int key_integer,
		radius = 0;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            Languages( szKey, szValue ); // Get language keyvalues from ScriptBaseLanguages
            ExtraKeyValues( szKey, szValue ); // Get extra keyvalues from ScriptBaseCustomEntity
            GameTextKeyvalues( szKey, szValue ); // Get extra keyvalues from ScriptBaseGameText
            if( szKey == "messagesound" )
                messagesound = szValue;
            else if( szKey == "messagevolume" )
                messagevolume = atof( szValue );
            else if( szKey == "messageattenuation" )
                messageattenuation = atof( szValue );
            else if ( szKey == "focus_entity" )
                focus_entity = szValue;
            else if ( szKey == "key_from_entity" )
                key_from_entity = szValue;
            else if ( szKey == "key_integer" )
                key_integer = atoi( szValue );
            else if ( szKey == "key_float" )
                key_float = atof( szValue );
            else if ( szKey == "key_string" )
                key_string = szValue;
            else if ( szKey == "radius" )
                radius = atoi( szValue );
            else
                return BaseClass.KeyValue( szKey, szValue );
            return true;
        }

        void Precache()
        {
            if( !string( messagesound ).IsEmpty() )
            {
                g_SoundSystem.PrecacheSound( messagesound );
                g_Game.PrecacheGeneric( "sound/" + messagesound );
            }
            BaseClass.Precache();
        }

        void Spawn()
        {
            Precache();
			PluginEntInit( self );
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
                return;

            if( pActivator !is null ) EhActivator = pActivator; else EhActivator = null;

            if ( self.pev.SpawnFlagBitSet( SF_GTC_ALL_PLAYERS ) || radius > 0 )
            {
                for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        ShowText( pPlayer );
                    }
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                ShowText( cast<CBasePlayer@>(pActivator) );
            }

            g_Util.Trigger( killtarget, self, pCaller, USE_KILL, delay );

            if( !self.pev.SpawnFlagBitSet( SF_GTC_FIRE_PER_PLAYER ) )
            {
                g_Util.Trigger( self.pev.target, ( pActivator is null ) ? self : pActivator, self, useType, delay );
            }
        }

        void ShowText( CBasePlayer@ pPlayer )
        {
			if( radius > 0 && ( self.pev.origin - pPlayer.pev.origin ).Length() > radius )
				return;

            string ReadLanguage = g_Util.StringReplace( ReadLanguages( pPlayer ),
            {
                { "!integer", string( key_integer ) },
                { "!float", string( key_float ) },
                { "!string", key_string },
                { "!activator", StrActivator() },
                { "!value", StrValue() }
            } );

            if( TextParams.effect == 3 )
            {
                g_PlayerFuncs.ShowMessage( pPlayer, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 4 )
            {
                string title = string( ReadLanguage ).SubString( 0., string( ReadLanguage ).Find( '#' ) );

                g_Util.ShowMOTD( pPlayer, title.Replace( '#', '' ), string( ReadLanguage ).SubString( string( ReadLanguage ).Find( '#' ) + 1, string( ReadLanguage ).Length() ) + "\n" );
            }
            else if( TextParams.effect == 5 )
            {
				string FullString = string( ReadLanguage );

				// If we reached the limit replace and send again
				while( FullString != '' )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, FullString.SubString( 0, 95 ) + ( FullString.Length() <= 95 ? '\n' : '-' ) );

					if( FullString.Length() <= 95 ) FullString = '';
					else FullString = FullString.SubString( 95, FullString.Length() );
				}
            }
            else if( TextParams.effect == 6 )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 7 )
            {
                g_PlayerFuncs.PrintKeyBindingString( pPlayer, string( ReadLanguage ) + "\n"  );
            }
            else if( TextParams.effect == 8 )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 9 )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 10 )
            {
                NetworkMessage message( MSG_ONE, NetworkMessages::ServerName, pPlayer.edict() );
                    message.WriteString( string( ReadLanguage ) );
                message.End();
            }
            else
            {
                g_PlayerFuncs.HudMessage( pPlayer, TextParams, string( ReadLanguage ) + "\n" );
            }

            if( !self.pev.SpawnFlagBitSet( SF_GTC_NO_ECHO_CON ) )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string( ReadLanguage ) + "\n" );
            }

            if( !string( messagesound ).IsEmpty() )
            {
                g_SoundSystem.PlaySound
                (
                    /* edict_t@ entity */
                    self.edict(),

                    /* SOUND_CHANNEL channel */
                    CHAN_AUTO,

                    /* const string& in sample */
                    messagesound,

                    /* float volume */
                    messagevolume/10,

                    /* float attenuation */
                    ( messageattenuation == 0 )
                    ? ATTN_IDLE :
                    ( messageattenuation == 1 )
                    ? ATTN_STATIC :
                    ( messageattenuation == 2 )
                    ? ATTN_NORM :
                    ( messageattenuation == 3 )
                    ? ATTN_NONE
                    : ATTN_STATIC,

                    /* int flags */
                    0,

                    /* int pitch = PITCH_NORM */
                    PITCH_NORM,

                    /* int target_ent_unreliable = 0 */
                    pPlayer.entindex(),

                    /* bool setOrigin = false */
                    true,

                    /* const Vector& in vecOrigin = g_vecZero */
                    ( messageattenuation == 4 ) ? pPlayer.GetOrigin() : self.GetOrigin()
                );
            }

            if( self.pev.SpawnFlagBitSet( SF_GTC_FIRE_PER_PLAYER ) )
            {
                g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
            }

            if( self.pev.SpawnFlagBitSet( SF_GTC_PLAY_ONCE ) )
            {
                g_EntityFuncs.Remove( self );
            }
        }

        string StrValue()
        {
            if( focus_entity.IsEmpty() || focus_entity == "!activator" && EhActivator.GetEntity() is null )
            {
                return "¡NULL!";
            }

            if( focus_entity == "!activator" )
            {
                return g_Util.GetCKV( EhActivator.GetEntity(), key_from_entity );
            }
            else
            {
                CBaseEntity@ pTarget = g_EntityFuncs.FindEntityByTargetname( pTarget, focus_entity );
                
                if( pTarget !is null )
                {
                    return g_Util.GetCKV( pTarget, key_from_entity );
                }
            }
            return "¡NULL!";
        }

        string StrActivator()
        {
            if( EhActivator.GetEntity() is null )
            {
                return "¡NULL!";
            }
            else if( EhActivator.GetEntity().IsPlayer() )
            {
                return string( EhActivator.GetEntity().pev.netname );
            }
            else if( EhActivator.GetEntity().IsMonster() )
            {
                string cncomplete = string( EhActivator.GetEntity().pev.classname ).Replace( '_', ' ');
                int cnLength = cncomplete.Length();
                return cncomplete.SubString( 8, cnLength );
            }
            return string( EhActivator.GetEntity().pev.classname );
        }
    }
    // End of class

	// game_text legacy for "effect" 0,1,2
	mixin class ScriptBaseGameText
	{
		private string killtarget;
		HUDTextParams TextParams;
		
		private Vector color, color2;

		bool GameTextKeyvalues( const string& in szKey, const string& in szValue )
		{
			if(szKey == "channel")
			{
				TextParams.channel = atoi( szValue );
			}
			else if(szKey == "x")
			{
				TextParams.x = atof( szValue );
			}
			else if(szKey == "y")
			{
				TextParams.y = atof( szValue );
			}
			else if(szKey == "effect")
			{
				TextParams.effect = atoi( szValue );
			}
			else if(szKey == "color")
			{
				string delimiter = " ";
				array<string> splitColor = {"","",""};
				splitColor = szValue.Split(delimiter);
				array<uint8>result = {0,0,0};
				result[0] = atoi(splitColor[0]);
				result[1] = atoi(splitColor[1]);
				result[2] = atoi(splitColor[2]);
				if (result[0] > 255) result[0] = 255;
				if (result[1] > 255) result[1] = 255;
				if (result[2] > 255) result[2] = 255;
				RGBA vcolor = RGBA(result[0],result[1],result[2]);
				TextParams.r1 = vcolor.r;
				TextParams.g1 = vcolor.g;
				TextParams.b1 = vcolor.b;
			}
			else if(szKey == "color2")
			{
				string delimiter2 = " ";
				array<string> splitColor2 = {"","",""};
				splitColor2 = szValue.Split(delimiter2);
				array<uint8>result2 = {0,0,0};
				result2[0] = atoi(splitColor2[0]);
				result2[1] = atoi(splitColor2[1]);
				result2[2] = atoi(splitColor2[2]);
				if (result2[0] > 255) result2[0] = 255;
				if (result2[1] > 255) result2[1] = 255;
				if (result2[2] > 255) result2[2] = 255;
				RGBA vcolor2 = RGBA(result2[0],result2[1],result2[2]);
				TextParams.r2 = vcolor2.r;
				TextParams.g2 = vcolor2.g;
				TextParams.b2 = vcolor2.b;
			}
			else if(szKey == "fadein")
			{
				TextParams.fadeinTime = atof( szValue );
			}
			else if(szKey == "fadeout")
			{
				TextParams.fadeoutTime = atof( szValue );
			}
			else if(szKey == "holdtime")
			{
				TextParams.holdTime = atof( szValue );
			}
			else if(szKey == "fxtime")
			{
				TextParams.fxTime = atof( szValue );
			}
			else if( szKey == "killtarget" )
			{
				killtarget = szValue;
			}
			else
			{
				return BaseClass.KeyValue( szKey, szValue );
			}
			return true;
		}
	}
	// End of mixin class
	
	// Plugin feature.
	void PluginEntInit( CBaseEntity@ self )
	{
		if( self.pev.ClassNameIs( 'multi_language' ) )
		{
			if( string( self.pev.model ).StartsWith( "*" ) )
			{
				CBaseEntity@ Triggers = g_EntityFuncs.FindEntityByString( Triggers, "model", self.pev.model );

				if( Triggers !is null )
				{
					if( Triggers.pev.ClassNameIs( "trigger_multiple" ) || Triggers.pev.ClassNameIs( "trigger_once" ) )
					{
						if( string( Triggers.pev.target ).IsEmpty() )
						{
							Triggers.pev.target = 'mlang_' + self.entindex();
							self.pev.targetname = 'mlang_' + self.entindex();
						}
						else
						{
							self.pev.targetname = Triggers.pev.target;
						}
						Triggers.pev.message = String::INVALID_INDEX;
					}
				}
			}
			else
			{
				CBaseEntity@ pGameText = null;

				while( ( @pGameText = g_EntityFuncs.FindEntityByTargetname( pGameText, self.pev.targetname ) ) !is null )
				{
					if(pGameText.pev.ClassNameIs( "env_message" )
					or pGameText.pev.ClassNameIs( "game_text" )
					or pGameText.pev.ClassNameIs( "game_text_custom" ) )
					{
						g_EntityFuncs.Remove( pGameText );
					}
				}
			}
		}
	}
}
// End of namespace