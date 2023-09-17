#include 'as_register'

namespace antirush
{
    void MapInit()
    {
        m_EntityFuncs.CustomEntity( 'antirush' );

        string m_szPath = 'scripts/maps/mikk/MSG/antirush/';

        m_FileSystem.GetKeyAndValue( m_szPath + 'msg_skull.txt', msg_skull, true );
        m_FileSystem.GetKeyAndValue( m_szPath + 'msg_percent.txt', msg_percent, true );
        m_FileSystem.GetKeyAndValue( m_szPath + 'msg_countdown.txt', msg_countdown, true );
    }

    dictionary lang, msg_skull, msg_percent, msg_countdown;

    enum ANTIRUSH
    {
        AR_DISABLED = 1,
        AR_HIDE_MESSAGE = 2
    }

    class antirush : ScriptBaseEntity, ScriptBaseCustomEntity, LANGUAGE::ScriptBaseLanguages
    {
        private bool HasCustomMSG = false;
        private dictionary m_dCount;
        private string m_iszCustomCountMessage;
        private float m_fCurrentPercent;
        private float CurrentPercentage;
        private string m_iszCustomSound;
        private int milisecs;
        private int m_fCountdown;
        private int m_iNeedPercent = 66;
        private int iAlivePlayers;

        private const int m_iCounter()
        {
            return int( self.pev.health ) - int( self.pev.frags );
        }

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            LangKeyValues( szKey, szValue );

            if( szKey == "percent" )
            {
                m_iNeedPercent = atoi( szValue );
            }
            else if( szKey == "delay_countdown" )
            {
                m_fCountdown = atoi( szValue );
            }
            else if( szKey == "sound" )
            {
                m_iszCustomSound = szValue;
            }
            else if( szKey == "m_iszCustomCountMessage" )
            {
                m_iszCustomCountMessage = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Precache()
        {
            if( !m_iszCustomSound.IsEmpty() )
            {
                g_SoundSystem.PrecacheSound( m_iszCustomSound );
                g_Game.PrecacheGeneric( "sound/" + m_iszCustomSound );
            }
            BaseClass.Precache();
        }

        void Spawn()
        {
            Precache();

            if( !m_iszCustomCountMessage.IsEmpty() )
                HasCustomMSG = m_FileSystem.GetKeyAndValue( 'scripts/maps/' + m_iszCustomCountMessage, m_dCount, true );


            self.pev.movetype = MOVETYPE_NONE;
            self.pev.solid = SOLID_NOT;
            self.pev.effects |= EF_NODRAW;

            SetBBOX();

            SetThink( ThinkFunction( this.InternalThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float delay )
        {
            if( self.pev.frags < self.pev.health )
                self.pev.frags++;

        }

        void InternalThink()
        {
            if( IsLockedByMaster() )
            {
                self.pev.nextthink = g_Engine.time + 0.1f;
                return;
            }

            CurrentPercentage = float( double( m_fCurrentPercent / ( iAlivePlayers == 0 ? 2 : iAlivePlayers ) * 100 ) );

            if( CurrentPercentage < m_iNeedPercent || m_iCounter() > 0 )
            {
                m_fCurrentPercent = 0;
                iAlivePlayers = 0;

                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        int iAFKTime; m_CustomKeyValue.GetValue( pPlayer, '$i_afkmanager', iAFKTime );

                        if( pPlayer.IsAlive() && pPlayer.IsConnected() && iAFKTime < 120 )
                        {
                            ++iAlivePlayers;
                        }

                        if( pPlayer.Intersects( self ) )
                        {
                            if( spawnflag( AR_DISABLED ) )
                            {
                                ConditionsMet( true );
                                return;
                            }

                            if( m_iCounter() > 0 )
                            {
                                if( !spawnflag( AR_HIDE_MESSAGE ) )
                                {
                                    m_Language.PrintMessage( pPlayer, ( HasCustomMSG ? m_dCount : msg_skull ), ML_HUD, false, { { '$skull$', string( m_iCounter() ) } } );
                                }
                            }
                            else
                            {
                                if( pPlayer.IsAlive() && pPlayer.pev.flags & FL_NOTARGET == 0 )
                                {
                                    m_fCurrentPercent++;
                                }

                                if( !spawnflag( AR_HIDE_MESSAGE ) )
                                {
                                    m_Language.PrintMessage( pPlayer, msg_percent, ML_HUD, false, { { '$got$', string( int( CurrentPercentage ) ) }, { '$needed$', string( m_iNeedPercent ) } } );
                                }
                            }
                        }
                    }
                }
            }

            if( iAlivePlayers > 0 && CurrentPercentage >= m_iNeedPercent && m_iCounter() == 0 )
            {
                if( m_fCountdown > 0 || milisecs > 0 )
                {
                    if( !spawnflag( AR_HIDE_MESSAGE ) )
                    {
                        string iszTime = ( m_fCountdown < 10 ? '0' : '' ) + string( m_fCountdown ) + '.' + ( milisecs < 10 ? '0' : '' ) + string( milisecs );
                        m_Language.PrintMessage( null, msg_countdown, ML_HUD, true, { { '$count$', string( iszTime ) } } );
                    }

                    --milisecs;

                    if( milisecs <= 0 && m_fCountdown > 0 )
                    {
                        milisecs = 99;
                        --m_fCountdown;
                    }
                    self.pev.nextthink = 0.1f;
                    return;
                }

                ConditionsMet();
                return;
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        void ConditionsMet( const bool &in bDisabled = false )
        {
            m_EntityFuncs.Trigger( string( self.pev.target ), self, self, USE_TOGGLE, ( bDisabled ? 0.0f : m_fDelay ) );

            if( !m_iszCustomSound.IsEmpty() && !bDisabled )
                g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, m_iszCustomSound, 1.0f, ATTN_NORM );

            g_EntityFuncs.Remove( self );
        }
    }
}