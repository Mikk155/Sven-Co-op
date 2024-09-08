namespace monster_mikk
{
    bool bRegister = Register();

    bool Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'monster_mikk::monster_mikk', 'monster_mikk' );
        return g_CustomEntityFuncs.IsCustomEntity( 'monster_mikk' );
    }

    array<dictionary> g_States =
    {
        {
            { 'classname', 'monster_human_grunt' },
            { 'is_player_ally', '1' },
            { 'weapons', '3' }
        },{
            { 'classname', 'monster_human_grunt' },
            { 'is_player_ally', '1' },
            { 'weapons', '5' }
        },{
            { 'classname', 'monster_human_grunt' },
            { 'is_player_ally', '1' },
            { 'weapons', '10' }
        },{
            { 'classname', 'monster_human_grunt' },
            { 'is_player_ally', '1' },
            { 'weapons', '66' }
        },{
            { 'classname', 'monster_human_grunt' },
            { 'is_player_ally', '1' },
            { 'weapons', '128' }
        },{
            { 'classname', 'monster_human_grunt_ally' },
            { 'weapons', '16' }
        },{
            { 'classname', 'monster_alien_grunt' },
            { 'is_player_ally', '1' },
            { 'weapons', '3' }
        },{
            { 'classname', 'monster_alien_tor' },
            { 'is_player_ally', '1' }
        },{
            { 'classname', 'monster_alien_voltigore' },
            { 'is_player_ally', '1' }
        },{
            { 'classname', 'monster_bullchicken' },
            { 'is_player_ally', '1' }
        },{
            { 'classname', 'monster_pitdrone' },
            { 'is_player_ally', '1' }
        },{
            { 'classname', 'monster_alien_controller' },
            { 'is_player_ally', '1' }
        },{
            { 'classname', 'monster_alien_slave' },
            { 'is_player_ally', '1' }
        },{
            { 'classname', 'monster_shocktrooper' },
            { 'is_player_ally', '1' }
        }
    };

    class monster_mikk : ScriptBaseEntity
    {
        private int iState = 0;
        private float latesthealth;
        private EHandle HandleMonster = null;

        void Spawn()
        {
            g_Game.PrecacheOther( 'monster_human_grunt' );
            g_Game.PrecacheOther( 'monster_human_grunt_ally' );
            g_Game.PrecacheOther( 'monster_alien_grunt' );
            g_Game.PrecacheOther( 'monster_alien_tor' );
            g_Game.PrecacheOther( 'monster_alien_voltigore' );
            g_Game.PrecacheOther( 'monster_bullchicken' );
            g_Game.PrecacheOther( 'monster_pitdrone' );
            g_Game.PrecacheOther( 'monster_alien_controller' );
            g_Game.PrecacheOther( 'monster_alien_slave' );
            g_Game.PrecacheOther( 'monster_bullchicken' );
            g_Game.PrecacheOther( 'monster_shocktrooper' );
            g_Game.PrecacheModel( string( self.pev.model ) );
            g_Game.PrecacheGeneric( string( self.pev.model ) );

            dictionary g_dict = g_States[ 0 ];

            g_dict[ 'health' ] = string( self.pev.health );
            g_dict[ 'netname' ] = string( self.pev.netname );
            g_dict[ 'rendermode' ] = string( self.pev.rendermode );
            g_dict[ 'renderamt' ] = string( self.pev.renderamt );
            g_dict[ 'renderfx' ] = string( self.pev.renderfx );
            g_dict[ 'rendercolor' ] = self.pev.rendercolor.ToString();
            g_dict[ 'spawnflags' ] = string( self.pev.spawnflags );
            g_dict[ 'model' ] = string( self.pev.model );
            g_dict[ 'angles' ] = self.pev.angles.ToString();

            CBaseEntity@ pMikk = g_EntityFuncs.CreateEntity( string( g_dict[ 'classname' ] ), g_dict, true );

            if( pMikk !is null )
            {
                HandleMonster = @pMikk;
                g_EntityFuncs.SetOrigin( pMikk, self.pev.origin );
                SetThink( ThinkFunction( this.Think ) );
                self.pev.nextthink = g_Engine.time + 1.5f;
            }

            BaseClass.Spawn();
        }

        void Think()
        {
            CBaseMonster@ pMikk = cast<CBaseMonster@>( HandleMonster.GetEntity() );

            if( pMikk is null )
            {
                g_Game.AlertMessage( at_console, '[monster_mikk] "monster_mikk" is dead n/or not found, Firing pev->target & removing schedules.' + '\n' );
                g_EntityFuncs.FireTargets( string( self.pev.target ), self, self, USE_TOGGLE, 0.0f );
                g_EntityFuncs.Remove( self );
                return;
            }

            int AlivePlayers = 0, DeadPlayers = 0;

            g_EntityFuncs.SetOrigin( self, pMikk.pev.origin );

            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer is null )
                    continue;

                if( pPlayer.IsAlive() )
                    AlivePlayers++;
                else
                    DeadPlayers++;
            }

            if( latesthealth != pMikk.pev.health )
            {
                iState++;

                if( iState == 14 )
                    iState = 0;

                dictionary g_dict = g_States[ iState ];

                g_dict[ 'health' ] = string( pMikk.pev.health );
                g_dict[ 'netname' ] = string( pMikk.pev.netname );
                g_dict[ 'rendermode' ] = string( pMikk.pev.rendermode );
                g_dict[ 'renderamt' ] = string( pMikk.pev.renderamt );
                g_dict[ 'renderfx' ] = string( pMikk.pev.renderfx );
                g_dict[ 'rendercolor' ] = pMikk.pev.rendercolor.ToString();
                g_dict[ 'spawnflags' ] = string( pMikk.pev.spawnflags );
                g_dict[ 'angles' ] = pMikk.pev.angles.ToString();
                g_dict[ 'model' ] = string( pMikk.pev.model );

                CBaseEntity@ pNewMikk = g_EntityFuncs.CreateEntity( string( g_dict[ 'classname' ] ), g_dict, true );

                if( pNewMikk !is null )
                {
                    HandleMonster = @pNewMikk;
                    g_EntityFuncs.SetOrigin( pNewMikk, self.pev.origin );

                    pNewMikk.pev.renderfx = kRenderFxGlowShell;
                    pNewMikk.pev.rendercolor = Vector( 255, 0, 0 );
                    pNewMikk.pev.takedamage = DAMAGE_NO;

                    NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
                        Message.WriteByte( TE_TELEPORT );
                        Message.WriteCoord( pNewMikk.pev.origin.x );
                        Message.WriteCoord( pNewMikk.pev.origin.y );
                        Message.WriteCoord( pNewMikk.pev.origin.z );
                    Message.End();

                    latesthealth = pNewMikk.pev.health;
                    g_Scheduler.SetTimeout( @this, 'ChangeWeapon', 1.5f, pNewMikk.edict() );
                    g_EntityFuncs.Remove( pMikk );
                }
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        void ChangeWeapon( edict_t@ eMikk )
        {
            CBaseEntity@ pMikk = g_EntityFuncs.Instance( eMikk );

            Math.RandomLong( 0, 4 );
            
            pMikk.pev.weapons = 9;
            pMikk.pev.renderfx = kRenderFxNone;
            pMikk.pev.takedamage = DAMAGE_YES;
        }
    }
}