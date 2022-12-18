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

    class CBaseGameTextCustom : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        EHandle EhActivator = self;

        HUDTextParams TextParams;
        private string killtarget, key_from_entity, focus_entity, messagesound, messagesentence;
        private float messagevolume = 10;
        private float messageattenuation = 0;
        int key_integer, motd_title;
        float key_float;
        string key_string;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues(szKey, szValue);

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
            else if ( szKey == "motd_title" )
            {
                motd_title = atoi( szValue );
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
                    Triggers.pev.message = "";
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
            {
                return;
            }

            // Store activator or else this entity
            if( pActivator !is null )
            {
                EhActivator = pActivator;
            }
            else
            {
                EhActivator = self;
            }

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
                UTILS::Trigger( killtarget + "#2", self, pCaller, USE_KILL, delay );
            }

            if( self.pev.SpawnFlagBitSet( SF_GTC_FIRE_T_ONCE ) )
            {
                UTILS::Trigger( self.pev.target, ( pActivator is null ) ? self : pActivator, self, useType, delay );
            }
        }

        void ShowText( CBasePlayer@ pPlayer )
        {
            // Shows the proper language
            int ilanguage = pPlayer.GetCustomKeyvalues().GetKeyvalue( "$i_lenguage" ).GetInteger();

            // Find entity to get its value as string for !value
            string strvalue;
            if( focus_entity == "!activator" )
            {
                strvalue = EhActivator.GetEntity().GetCustomKeyvalues().GetKeyvalue( key_from_entity ).GetString();
            }
            else if( !focus_entity.IsEmpty() )
            {
                CBaseEntity@ pTarget = g_EntityFuncs.FindEntityByTargetname( pTarget, focus_entity );
                
                if( pTarget !is null )
                {
                    strvalue = pTarget.GetCustomKeyvalues().GetKeyvalue( key_from_entity ).GetString();
                }
            }

            // Gets entity classname or netname for !activator
            string strnetname;
            if( EhActivator.GetEntity() is null )
            {
                strnetname = "Worldspawn";
            }
            else if( EhActivator.GetEntity().IsPlayer() )
            {
                strnetname = EhActivator.GetEntity().pev.netname;
            }
            else if( EhActivator.GetEntity().IsMonster() )
            {
                string cncomplete = string( EhActivator.GetEntity().pev.classname ).Replace( '_', ' ');
                int cnLength = cncomplete.Length();
                
                strnetname = cncomplete.SubString( 8, cnLength );
            }
            else
            {
                strnetname = EhActivator.GetEntity().pev.classname;
            }

            string ReadLanguage = UTILS::Replace( ReadLanguages( ilanguage ),
            {
                { "!integer", string( key_integer ) },
                { "!float", string( key_float ) },
                { "!string", key_string },
                { "!activator", strnetname },
                { "!value", strvalue }
            } );

            if( TextParams.effect == 3 )
            {
                g_PlayerFuncs.ShowMessage( pPlayer, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 4 )
            {
                string title = string( g_Engine.mapname ) + " motd";
                string message = string( ReadLanguage );

                if( motd_title > 0 )
                {
                    title = string( ReadLanguage ).SubString( 0, motd_title );
                    message = string( ReadLanguage ).SubString( motd_title + 1, string( ReadLanguage ).Length() );
                }

                ShowMOTD( pPlayer, title, message + "\n" );
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
                g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_AUTO, messagesound, messagevolume/10, ATTN_NORM, 0, PITCH_NORM, pPlayer.entindex(), true, ( messageattenuation == 4 ) ? pPlayer.GetOrigin() : self.GetOrigin() );
            }

            if( !string( messagesentence ).IsEmpty() )
            {
                g_SoundSystem.EmitSoundSuit( pPlayer.edict(), string( messagesentence ) );
            }

            if( !self.pev.SpawnFlagBitSet( SF_GTC_FIRE_T_ONCE ) )
            {
                UTILS::Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
            }
        }
    }

    /*
        Shows a custom MOTD to the given target. code by Geigue
    */
    void ShowMOTD( EHandle hPlayer, const string& in szTitle, const string& in szMessage )
    {
        if(!hPlayer){return;}
        CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
        if(pPlayer is null){return;}
        NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        title.WriteString( szTitle );
        title.End();
        uint iChars = 0;
        string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        for( uint uChars = 0; uChars < szMessage.Length(); uChars++ )
        {
            szSplitMsg.SetCharAt( iChars, char( szMessage[ uChars ] ) );
            iChars++;
            if( iChars == 32 )
            {
                NetworkMessage message( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                message.WriteByte( 0 );
                message.WriteString( szSplitMsg );
                message.End();
                
                iChars = 0;
            }
        }
        // If we reached the end, send the last letters of the message
        if( iChars > 0 )
        {
            szSplitMsg.Truncate( iChars );
            NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
            fix.WriteByte( 0 );
            fix.WriteString( szSplitMsg );
            fix.End();
        }
        NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
        endMOTD.WriteByte( 1 );
        endMOTD.WriteString( "\n" );
        endMOTD.End();
        NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
        restore.End();
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom::CBaseGameTextCustom", "game_text_custom" );
    }

    void RegisterPlugin()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom::CBaseGameTextCustom", "multi_language" );
        g_Scheduler.SetTimeout( "SchedulerUnregister", 1.0f );
    }
    
    void SchedulerUnregister()
    {
        if( g_CustomEntityFuncs.IsCustomEntity( "multi_language" ) )
            g_CustomEntityFuncs.UnRegisterCustomEntity( "game_text_custom" );
    }
}// end namespace