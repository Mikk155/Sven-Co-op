namespace CustomEntity
{
    namespace env_decal
    {
        bool IsRegistered = Register();

        bool Register()
        {
            g_CustomEntityFuncs.RegisterCustomEntity( "CustomEntity::env_decal::env_decal", "env_decal" );
            return g_CustomEntityFuncs.IsCustomEntity( "env_decal" );
        }

        void UnRegister()
        {
            CBaseEntity@ entity = null;

            while( ( @entity = g_EntityFuncs.FindEntityByClassname( entity, "env_decal" ) ) !is null )
            {
                entity.UpdateOnRemove();
            }

            g_CustomEntityFuncs.UnRegisterCustomEntity( "env_decal" );

            IsRegistered = false;
        }

        class env_decal : ScriptBaseEntity
        {
            protected bool m_IsActive = false;

            bool IsActive()
            {
                return this.m_IsActive;
            }

            void SendDecal( CBasePlayer@ player )
            {
                if( this.IsActive() && player !is null && player.IsConnected() )
                {
                    TraceResult tr;
                    Vector vecOffset( 5, 5, 5 );

                    g_Utility.TraceLine( self.pev.origin - vecOffset, self.pev.origin + vecOffset, ignore_monsters, self.edict(), tr );

                    int entityIndex = g_EngineFuncs.IndexOfEdict( tr.pHit );

                    NetworkMessage message( NetworkMessageDest::MSG_ONE, NetworkMessages::SVC_TEMPENTITY, player.edict() );
                        message.WriteByte( TempEntityType::TE_BSPDECAL );
                        message.WriteVector( self.pev.origin );
                        message.WriteShort( int(self.pev.skin) );
                        message.WriteShort( entityIndex );
                        if( entityIndex > 0 )
                            message.WriteShort( tr.pHit.vars.modelindex );
                    message.End();
                }
            }

            void SendDecalAll()
            {
                if( this.IsActive() && g_PlayerFuncs.GetNumPlayers() > 0 )
                {
                    for( int i = 1; i <= g_Engine.maxClients; i++ )
                    {
                        this.SendDecal( g_PlayerFuncs.FindPlayerByIndex(i) );
                    }
                }
            }

            protected ClientPutInServerHook@ fnHook = ClientPutInServerHook( @ClientPutInServer );

            HookReturnCode ClientPutInServer( CBasePlayer@ player )
            {
                SendDecal( player );
                return HOOK_CONTINUE;
            }

            void UpdateOnRemove()
            {
                self.pev.targetname = 0;
                self.UpdateOnRemove();
                self.pev.flags |= FL_KILLME;
            }

            void Spawn()
            {
                if( self.pev.skin < 0 )
                    return;

                g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @fnHook );

                g_EntityFuncs.SetOrigin( self, self.pev.origin );

                this.m_IsActive = ( string( self.pev.targetname ).IsEmpty() );
            }

            bool KeyValue( const string& in key, const string& in value )
            {
                if( key == "texture" )
                {
                    self.pev.skin = g_EngineFuncs.DecalIndex( value );

                    if( self.pev.skin < 0 )
                    {
                        g_Game.AlertMessage( at_console, "[env_decal] Invalid decal name \"%1\"\n", value );
                        self.UpdateOnRemove();
                    }
                }

                return false;
            }

            void Use( CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE use_type, float value )
            {
                if( !this.IsActive() )
                {
                    this.m_IsActive = true;
                    SendDecalAll();
                }
            }
        }
    }
}
