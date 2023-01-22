/*
DOWNLOAD:

scripts/maps/mikk/game_text_custom.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/game_text_custom"

void MapInit()
{
    game_text_custom::Register();
}
*/

#include "utils"

namespace game_text_custom
{
    enum game_text_custom_flags
    {
        SF_GTC_ALL_PLAYERS = 1 << 0,
        SF_GTC_NO_ECHO_CON = 1 << 1,
        SF_GTC_FIRE_T_ONCE = 1 << 2
    }

    class CBaseGameTextCustom : ScriptBaseEntity, ScriptBaseLanguages, ScriptBaseCustomEntity
    {
        EHandle EhActivator = self;

        HUDTextParams TextParams;
        private string killtarget, key_from_entity, focus_entity, messagesound, messagesentence;
        private float messagevolume = 10;
        private float messageattenuation = 0;
        int key_integer;
        float key_float;
        string key_string;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            Languages( szKey, szValue );
            ExtraKeyValues( szKey, szValue );

            if(szKey == "channel")
            {
                TextParams.channel = atoi(szValue);
            }
            else if(szKey == "x")
            {
                TextParams.x = atof(szValue);
            }
            else if(szKey == "y")
            {
                TextParams.y = atof(szValue);
            }
            else if(szKey == "effect")
            {
                TextParams.effect = atoi(szValue);
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
                TextParams.fadeinTime = atof(szValue);
            }
            else if(szKey == "fadeout")
            {
                TextParams.fadeoutTime = atof(szValue);
            }
            else if(szKey == "holdtime")
            {
                TextParams.holdTime = atof(szValue);
            }
            else if(szKey == "fxtime")
            {
                TextParams.fxTime = atof(szValue);
            }
            else if( szKey == "killtarget" )
            {
                killtarget = szValue;
            }
            else if( szKey == "messagesound" )
            {
                messagesound = szValue;
            }
            else if( szKey == "messagevolume" )
            {
                messagevolume = atof(szValue);
            }
            else if( szKey == "messageattenuation" )
            {
                messageattenuation = atof(szValue);
            }
            else if( szKey == "messagesentence" )
            {
                messagesentence = szValue;
            }
            else if ( szKey == "focus_entity" )
            {
                focus_entity = szValue;
                return true;
            }
            else if ( szKey == "key_from_entity" )
            {
                key_from_entity = szValue;
                return true;
            }
            else if ( szKey == "key_integer" )
            {
                key_integer = atoi( szValue );
                return true;
            }
            else if ( szKey == "key_float" )
            {
                key_float = atof( szValue );
                return true;
            }
            else if ( szKey == "key_string" )
            {
                key_string = szValue;
                return true;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
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

            if( string( self.pev.model ).StartsWith( "*" ) )
            {
                CBaseEntity@ Triggers = g_EntityFuncs.FindEntityByString( Triggers, "model", self.pev.model );

                if( Triggers is null )
                {
                    return;
                }

                if( Triggers.pev.ClassNameIs( "trigger_multiple" ) || Triggers.pev.ClassNameIs( "trigger_once" ) )
                {
                    if( string( Triggers.pev.target ).IsEmpty() )
                    {
                        Triggers.pev.target = self.pev.targetname;
                    }
                    else
                    {
                        self.pev.targetname = Triggers.pev.target;
                    }
                    Triggers.pev.message = String::INVALID_INDEX;
                }
            }
            else
            {
                CBaseEntity@ pGameText = g_EntityFuncs.FindEntityByTargetname( pGameText, self.pev.targetname );

                if( pGameText is null )
                {
                    return;
                }

                if( pGameText.pev.ClassNameIs( "game_text" ) || pGameText.pev.ClassNameIs( "env_message" ) )
                {
                    g_EntityFuncs.Remove( pGameText );
                }
            }

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
                return;

            if( pActivator !is null ) EhActivator = pActivator; else EhActivator = null;

            if ( self.pev.SpawnFlagBitSet( SF_GTC_ALL_PLAYERS ) )
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

            // game_text legacy
            if( !string( killtarget ).IsEmpty() )
            {
                g_Util.Trigger( killtarget + "#2", self, pCaller, USE_KILL, delay );
            }

            if( !self.pev.SpawnFlagBitSet( SF_GTC_FIRE_T_ONCE ) )
            {
                g_Util.Trigger( self.pev.target, ( pActivator is null ) ? self : pActivator, self, useType, delay );
            }
        }

        void ShowText( CBasePlayer@ pPlayer )
        {
            string ReadLanguage = g_Util.StringReplace( ReadLanguages( pPlayer ),
            {
                { "!integer", string( key_integer ) },
                { "!float", string( key_float ) },
                { "!string", key_string },
                { "!frags", string( self.pev.frags ) },
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
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, string( ReadLanguage ) + "\n" );
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
            else if( TextParams.effect == 11 )
            {
                // Dummy
            }
            else if( TextParams.effect == 12 )
            {
                // Dummy
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

            if( !messagesentence.IsEmpty() )
            {
                g_SoundSystem.EmitSoundSuit( pPlayer.edict(), messagesentence );
            }

            if( self.pev.SpawnFlagBitSet( SF_GTC_FIRE_T_ONCE ) )
            {
                g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
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


    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom::CBaseGameTextCustom", "game_text_custom" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_text_custom\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Kmkz\n"
            "Github: github.com/kmkz27\n"
            "Description: New entity replacemet for game_text and env_message with lot of new additions\n"
        );
    }
}
// End of namespace
CGameTextCustom g_GameTextCustom;

final class CGameTextCustom
{
}