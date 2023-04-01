/*
Github page: https://github.com/Mikk155/Sven-Co-op/

Require:
- utils.as

Usage: https://github.com/Mikk155/Sven-Co-op/blob/main/develop/information/entities/config_english.md#config_survival_mode
*/
#include "utils"
namespace config_survival_mode
{
	bool Register = g_Util.CustomEntity( 'config_survival_mode::config_survival_mode','config_survival_mode' );

    class config_survival_mode : ScriptBaseEntity, ScriptBaseCustomEntity, ScriptBaseLanguages
    {
        bool SurvivalEnabled = false;
        private string target_toggle, target_failed;

        private int
        mp_respawndelay = int( g_EngineFuncs.CVarGetFloat( "mp_respawndelay" ) ),
        mp_survival_startdelay = int( g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" ) );

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues( szKey, szValue );
            Languages( szKey, szValue );

            if( szKey == "mp_respawndelay" )
            {
                mp_respawndelay = atoi( szValue );
            }
            else if( szKey == "mp_survival_startdelay" )
            {
                mp_survival_startdelay = atoi( szValue );
            }
            else if( szKey == "target_toggle" )
            {
                target_toggle = szValue;
            }
            else if( szKey == "target_failed" )
            {
                target_failed = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Spawn()
        {
			g_ClassicMode.EnableMapSupport();

            if( g_Util.GetNumberOfEntities( self.GetClassname() ) > 1 )
            {
                g_Util.Debug( self.GetClassname() + ': Can not use more than one entity per level. Removing...' );
                g_EntityFuncs.Remove( self );
            }

            //We want survival mode to be enabled here
            g_SurvivalMode.EnableMapSupport();

            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 1.0f;
            g_SurvivalMode.Enable( true );
            g_SurvivalMode.Activate( true );
            g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }

            if( useType == USE_ON )
            {
                if( SurvivalEnabled )
                {
                    g_Game.AlertMessage( at_console, "enabled\n" );
                    g_Util.Trigger( target_failed, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
                }
                else
                {
                    SetLanguages( null, 'enabled' );
                    SurvivalEnabled = true;
                }
            }
            else if( useType == USE_OFF )
            {
                if( !SurvivalEnabled )
                {
                    g_Util.Trigger( target_failed, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
                }
                else
                {
                    SetLanguages( null, 'disabled' );
                    SurvivalEnabled = false;
                }
            }
            else
            {
                if( SurvivalEnabled )
                {
                    SetLanguages( null, 'disabled' );
                    SurvivalEnabled = false;
                }
                else
                {
                    SetLanguages( null, 'enabled' );
                    SurvivalEnabled = true;
                }

                g_Util.Trigger( target_toggle, ( pActivator !is null ) ? pActivator : self, self, useType, delay );
            }
            mp_survival_startdelay = 0;
        }

        void Think()
        {
            if( !SurvivalEnabled  )
            {
                if( mp_survival_startdelay >= 0 && !master() )
                {
                    if( mp_survival_startdelay > 0 )
                    {
                        SetLanguages( null, 'countdown', HUD_PRINTCENTER );
                    }

                    mp_survival_startdelay -= 1;

                    if( mp_survival_startdelay == 0 )
                    {
                        SetLanguages( null, 'enabled' );
                        SurvivalEnabled = true;
                    }
                }

                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        int ReSpawnTime = atoi( g_Util.GetCKV( pPlayer, "$i_csm_respawn_time" ) );

                        if( ReSpawnTime > 0 )
                        {
                            if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() )
                            {
                                g_Util.SetCKV( pPlayer, "$i_csm_respawn_time", string( ReSpawnTime - 1 ) );
                                SetLanguages( pPlayer, 'respawnin', HUD_PRINTNOTIFY );
                            }
                        }
                        else
                        {
                            g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );
                            g_Util.SetCKV( pPlayer, "$i_csm_respawn_time", string( mp_respawndelay ) );
                        }
                    }
                }
            }

            self.pev.nextthink = g_Engine.time + 1.0f;
        }

        void SetLanguages( CBasePlayer@ pActivator, const string& in szMode = "respawnin", HUD szHUD = HUD_PRINTTALK )
        {
            if( szMode == 'respawnin' )
            {
                self.pev.message = 'You will resurrect in !time seconds';
                message_spanish = 'Resucitaras en !time segundos';
                message_spanish2 = 'Resucitaras en !time segundos';
                message_portuguese = 'Você ressuscitará em !time segundos';
                message_german = 'Du wirst in !time Sekunden wiederbelebt';
                message_french = 'Vous ressusciterez dans !time secondes';
                message_italian = 'Risusciterai in !time secondi';
                message_esperanto = 'Vi reviviĝos post !time sekundoj';
                message_czech = 'Budete vzkříšeni za !time sekund';
                message_dutch = 'Je zal herrijzen in !time seconden';
                message_indonesian = 'Anda akan dibangkitkan dalam !time detik';
                message_romanian = 'Veți reînvia în !time secunde';
                message_turkish = '!mp_respawdelay saniye içinde dirileceksiniz';
                message_albanian = 'Ju do të ringjalleni në sekonda !time';
            }
            else if( szMode == 'enabled' )
            {
                self.pev.message = 'Survival mode has been enabled';
                message_spanish = 'Se ha habilitado el modo de supervivencia';
                message_spanish2 = 'Se ha habilitado el modo de supervivencia';
                message_portuguese = 'O modo de sobrevivência foi ativado';
                message_german = 'Der Überlebensmodus wurde aktiviert';
                message_french = 'Le mode survie a été activé';
                message_italian = 'La modalità di sopravvivenza è stata abilitata';
                message_esperanto = 'Superviva reĝimo estis ebligita';
                message_czech = 'Režim přežití byl aktivován';
                message_dutch = 'De overlevingsmodus is ingeschakeld';
                message_indonesian = 'Mode bertahan hidup telah diaktifkan';
                message_romanian = 'Modul de supraviețuire a fost activat';
                message_turkish = 'Hayatta kalma modu etkinleştirildi';
                message_albanian = 'Modaliteti i mbijetesës është aktivizuar';
            }
            else if( szMode == 'disabled' )
            {
                self.pev.message = 'Survival mode has been disabled';
                message_spanish = 'El modo de supervivencia ha sido deshabilitado';
                message_spanish2 = 'El modo de supervivencia ha sido deshabilitado';
                message_portuguese = 'O modo de sobrevivência foi desativado';
                message_german = 'Der Überlebensmodus wurde deaktiviert';
                message_french = 'Le mode survie a été désactivé';
                message_italian = 'La modalità Sopravvivenza è stata disattivata';
                message_esperanto = 'Superviva reĝimo estas malŝaltita';
                message_czech = 'Režim přežití byl deaktivován';
                message_dutch = 'De overlevingsmodus is uitgeschakeld';
                message_indonesian = 'Mode bertahan hidup telah dinonaktifkan';
                message_romanian = 'Modul de supraviețuire a fost dezactivat';
                message_turkish = 'Hayatta kalma modu devre dışı bırakıldı';
                message_albanian = 'Modaliteti i mbijetesës është çaktivizuar';
            }
            else if( szMode == 'countdown' )
            {
                self.pev.message = 'Survival will start in !time seconds';
                message_spanish = 'La supervivencia comenzará en !time segundos';
                message_spanish2 = 'La supervivencia comenzará en !time segundos';
                message_portuguese = 'A sobrevivência começará em !time segundos';
                message_german = 'Das Überleben beginnt in !time Sekunden';
                message_french = 'La survie commencera dans !time secondes';
                message_italian = 'La sopravvivenza inizierà tra !time secondi';
                message_esperanto = 'Supervivo komenciĝos post !time sekundoj';
                message_czech = 'Přežití začne za !time sekund';
                message_dutch = 'Het overleven begint over !time seconden';
                message_indonesian = 'Kelangsungan hidup akan dimulai dalam !time detik';
                message_romanian = 'Supraviețuirea va începe în !time secunde';
                message_turkish = 'Hayatta kalma !time saniye içinde başlayacak';
                message_albanian = 'Mbijetesa do të fillojë në !time sekonda';
            }

            if( pActivator !is null )
            {
                g_PlayerFuncs.ClientPrint( pActivator, szHUD,
                g_Util.StringReplace
                (
                    ReadLanguages( pActivator ),
                    {
                        { "!time", g_Util.GetCKV( pActivator, "$i_csm_respawn_time" ) }
                    }
                ) + "\n" );
            }
            else{
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null )
                {
                    g_PlayerFuncs.ClientPrint( pPlayer, szHUD,
                    g_Util.StringReplace
                    (
                        ReadLanguages( pPlayer ),
                        {
                            { "!time", string( mp_survival_startdelay ) }
                        }
                    ) + "\n" );
                }
              }
            }
        }
    }

}
// End of namespace