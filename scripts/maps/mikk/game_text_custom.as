/*
INSTALL:

#include "mikk/game_text_custom"

void MapInit()
{
    RegisterGameTextCustom();
}
*/

#include "utils"

void RegisterGameTextCustom()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseGameTextCustom", "game_text_custom" );
}

class CBaseGameTextCustom : ScriptBaseEntity, UTILS::MoreKeyValues
{
    HUDTextParams TextParams;
    private string killtarget, key_from_entity, focus_entity;
    private string messagesound, messagesentence;
    private float messagevolume = 10;
    private float messageattenuation = 0;
    private float flDelay = 0.0f;

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
        else if(szKey == "delay")
        {
            flDelay = atof(szValue);
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

        // Wait a second so everything is initialised and then replace the old things
        if( self.pev.classname == "multi_language" )
        {
            g_Scheduler.SetTimeout( "DelayedRemoval", 1.0f );
        }

        BaseClass.Spawn();
    }

    void DelayedRemoval()
    {
        if( string( self.pev.model ).StartsWith( "*" ) )
        {
            for( int i = 0; i < g_Engine.maxEntities; ++i ) 
            {
                CBaseEntity@ Triggers = g_EntityFuncs.Instance( i );

                if( Triggers is null or string( Triggers.pev.classname ) != "trigger_multiple" or string( Triggers.pev.classname ) != "trigger_once" )  
                    continue;

                if( string( Triggers.pev.model ) == string( self.pev.model ) )
                {
                    // when the trigger_once/multiple doesn't have a "target" set. you must set a "targetname" to your multi_language
                    if( string( Triggers.pev.target ).IsEmpty() )
                        Triggers.pev.targetname = self.pev.target;
                    else
                        self.pev.targetname = Triggers.pev.target;

                    Triggers.pev.message = "";
                }
            }
        }
        else
        {
            CBaseEntity@ pGameText = null;
            while( ( @pGameText = g_EntityFuncs.FindEntityByTargetname( pGameText, self.pev.targetname ) ) !is null )
            {
                if( pGameText.pev.classname == "game_text" || pGameText.pev.classname == "env_message" || pGameText.pev.classname == "game_text_custom" )
                {
                    g_EntityFuncs.Remove( pGameText );
                }
            }
        }
    }

    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( multisource() )
        {
            return;
        }

        string strMonster = string( pActivator.pev.classname ).Replace( "monster_", "" );

        self.pev.netname = ( pActivator.IsMonster() ) ? string( strMonster ).Replace( "_", " " ) : ( pActivator.IsPlayer() ) ? string( pActivator.pev.netname ) : "Worldspawn" ;

        if ( self.pev.SpawnFlagBitSet( 1 ) )
        {
            for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null )
                {
                    if( pActivator !is null && pActivator.IsPlayer() ) self.pev.netname = pActivator.pev.netname;

                    ShowText( pPlayer );
                }
            }
        }
        else if( pActivator !is null && pActivator.IsPlayer() )
        {
            ShowText( cast<CBasePlayer@>(pActivator) );
        }
    }

    void ShowText( CBasePlayer@ pPlayer )
    {
        string ReadLanguage = UTILS::Replace( ReadLanguages( UTILS::GetCKV( pPlayer, "$f_lenguage" ) ),
        {
            { "!frags", string( self.pev.frags ) },
            { "!activator", string( self.pev.netname ) },
            { "!value", string( UTILS::GetCKV( ( string( focus_entity ).IsEmpty() ) ? pPlayer : cast<CBasePlayer@>( g_EntityFuncs.FindEntityByTargetname( null, focus_entity ) ) , string( key_from_entity ) ) ) }
        } );

        if( TextParams.effect == 3 )
            g_PlayerFuncs.ShowMessage( pPlayer, string( ReadLanguage ) + "\n" );
        else if( TextParams.effect == 4 )
            UTILS::ShowMOTD( pPlayer, string( "motd" ), string( ReadLanguage ) + "\n" );
        else if( TextParams.effect == 5 )
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, string( ReadLanguage ) + "\n" );
        else if( TextParams.effect == 6 )
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, string( ReadLanguage ) + "\n" );
        else if( TextParams.effect == 7 )
            g_PlayerFuncs.PrintKeyBindingString( pPlayer, string( ReadLanguage ) + "\n"  );
        else if( TextParams.effect == 8 )
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string( ReadLanguage ) + "\n" );
        else if( TextParams.effect == 9 )
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, string( ReadLanguage ) + "\n" );
        else
            g_PlayerFuncs.HudMessage( pPlayer, TextParams, string( ReadLanguage ) + "\n" );

        if( !self.pev.SpawnFlagBitSet( 2 ) )
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string( ReadLanguage ) + "\n" );

        if( !string( messagesound ).IsEmpty() )
            g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_AUTO, messagesound, messagevolume/10, ATTN_NORM, 0, PITCH_NORM, pPlayer.entindex(), true, pPlayer.GetOrigin() );

        if( !string( messagesentence ).IsEmpty() )
            g_SoundSystem.EmitSoundSuit( pPlayer.edict(), string( messagesentence ) );

        if( !string( killtarget ).IsEmpty() )
            UTILS::TriggerMode( killtarget + "#2", self, flDelay );

        UTILS::TriggerMode( self.pev.target, pPlayer, flDelay );
    }
}