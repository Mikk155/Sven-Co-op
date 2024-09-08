namespace levi
{
    funcdef HookReturnCode PlayerSpawn( CBasePlayer@ );

    void MapInit()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'levi::player_equipment', 'player_equipment' );
        g_CustomEntityFuncs.RegisterCustomEntity( "levi::trigger_votemenu", "trigger_votemenu" );
    }

    enum PLAYER_EQUIPMENT_FLAGS
    {
        ITEM_REMOVE = -2,
        ITEM_IGNORE = -1,
        ITEM_GIVE = 0
    }

    class player_equipment : ScriptBaseEntity
    {
        private dictionary m_iszKeyValues;

        private const array<string> m_iszKeys
        {
            get const { return m_iszKeyValues.getKeys(); }
        }

        private void ModifyInventoryAll()
        {
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                ModifyInventory( g_PlayerFuncs.FindPlayerByIndex( iPlayer ) );
            }
        }

        private void ModifyInventory( CBasePlayer@ pPlayer )
        {
            if( pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsAlive() )
            {
                if( self.pev.frags > 0 )
                    pPlayer.RemoveAllItems( false/*, false*/ ); // Remove the commentary on sven 5.26 -Mikk

                for( uint ui = 0; ui < m_iszKeys.length(); ui++ )
                {
                    string Key = m_iszKeys[ui];

                    int Value = atoi( string( m_iszKeyValues[ m_iszKeys[ui] ] ) );

                    if( Value == ITEM_REMOVE )
                    {
                        CBasePlayerItem@ pWeapon = pPlayer.HasNamedPlayerItem( Key );

                        if( pWeapon !is null )
                        {
                            pPlayer.RemovePlayerItem( pWeapon );
                        }
                    }
                    else if( Value >= ITEM_IGNORE )
                    {
                        pPlayer.GiveNamedItem( Key, 0, 0 );

                        if( Value > ITEM_GIVE )
                        {
                            g_Scheduler.SetTimeout
                            (
                                @this,
                                'DelaySetAmmo',
                                0.0f,
                                EHandle( pPlayer ),
                                m_iszKeys[ui],
                                atoi( string( m_iszKeyValues[ m_iszKeys[ui] ] ) )
                            );
                        }
                    }
                }

                // Don't let it "Kills" players
                if( self.pev.health > 0 )
                    pPlayer.pev.health = self.pev.health;

                if( self.pev.max_health > 0 )
                    pPlayer.pev.max_health = self.pev.max_health;

                if( self.pev.armorvalue > 0 )
                    pPlayer.pev.armorvalue = self.pev.armorvalue;

                if( self.pev.armortype > 0 )
                    pPlayer.pev.armortype = self.pev.armortype;
            }
        }

        private void DelaySetAmmo( EHandle hPlayer, const string & in m_iszWeapon, const int & in m_iAmmo )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
            CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.HasNamedPlayerItem( m_iszWeapon ) );

            if( pWeapon !is null && pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsAlive() )
            {
                g_Game.AlertMessage( at_console, 'Added "' + string( m_iAmmo ) + '" of ammunition to ' + pPlayer.pev.netname + '\'s ' + m_iszWeapon + '\n' );
                pPlayer.m_rgAmmo( pWeapon.m_iPrimaryAmmoType, m_iAmmo );
            }
        }

        // No idea why this is not working, so here is a workaround in the hook
        void UpdateOnRemove()
        {
            g_Hooks.RemoveHook( Hooks::Player::PlayerSpawn, @PlayerSpawnHook( this.OnPlayerSpawn ) );
            BaseClass.UpdateOnRemove();
        }

        HookReturnCode OnPlayerSpawn( CBasePlayer@ pPlayer ) 
        {
            if( g_EntityFuncs.IsValidEntity( self.edict() ) )
                ModifyInventory( pPlayer );

            return HOOK_CONTINUE;
        }

        void Spawn()
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn( this.OnPlayerSpawn ) );
        }

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            m_iszKeyValues[ szKey ] = szValue;
            return BaseClass.KeyValue( szKey, szValue );
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float delay )
        {
            ModifyInventoryAll();
        }
    }

    class trigger_votemenu : ScriptBaseEntity
    {
        dictionary dictKeyValues;
        dictionary dictFinalResults;

        array<CTextMenu@> g_VoteMenu = 
        {
            null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null,
            null
        };

        const array<string> strKeyValues
        {
            get const { return dictKeyValues.getKeys(); }
        }

        void Spawn()
        {
            if(self.pev.health <= 0) self.pev.health = 15;
            if(string(self.pev.netname).IsEmpty()) self.pev.netname = "Vote Menu";

            BaseClass.Spawn();
        }

        bool KeyValue(const string& in szKey, const string& in szValue)
        {
            dictKeyValues[szKey] = szValue;
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            dictFinalResults.deleteAll();

            if( self.pev.SpawnFlagBitSet( 1 ) && pActivator !is null && pActivator.IsPlayer() )
            {
                CTextMenu@ g_SingleVoteMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );
                g_SingleVoteMenu.SetTitle( string( self.pev.netname ) );
                
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    g_SingleVoteMenu.AddItem(strKeyValues[ui]);
                }

                g_SingleVoteMenu.Register();
                g_SingleVoteMenu.Open( int(self.pev.health), 0, cast<CBasePlayer@>(pActivator) );
            }
            else
            {
                for(int i = 1; i <= g_Engine.maxClients; i++) 
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

                    if(pPlayer !is null && pPlayer.IsConnected()) 
                    {
                        int eidx = pPlayer.entindex();
        
                        if( g_VoteMenu[eidx] is null )
                        {
                            @g_VoteMenu[eidx] = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );
                            g_VoteMenu[eidx].SetTitle( string( self.pev.netname ) );

                            for(uint ui = 0; ui < strKeyValues.length(); ui++)
                            {
                                g_VoteMenu[eidx].AddItem(strKeyValues[ui]);
                            }

                            g_VoteMenu[eidx].Register();
                        }
                        g_VoteMenu[eidx].Open( int(self.pev.health), 0, pPlayer );
                    }
                }
            }
            g_Scheduler.SetTimeout( @this, "Results", float(self.pev.health) + 3.0f );
        }

        void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
        {
            if( pItem !is null && strKeyValues.find(pItem.m_szName) >= 0 )
            {
                int value;

                if( dictFinalResults.exists(pItem.m_szName) )
                {
                    dictFinalResults.get(pItem.m_szName, value);
                    dictFinalResults.set(pItem.m_szName, value+1);
                }
                else
                {
                    dictFinalResults.set(pItem.m_szName, 1);
                }
            }
        }

        void Results()
        {
            array<string> Names = dictFinalResults.getKeys();
            array<array<string>> AllValuesInOne;
            array<string> SameValue;

            int LatestHigherNumber = 0; 

            for(uint i = 0; i < Names.length(); ++i)
            {   
                int value;
                dictFinalResults.get(Names[i], value);
                AllValuesInOne.insertLast({Names[i], value});
            }

            for(uint i = 0; i < AllValuesInOne.length(); ++i)
            {   
                if( atoi(AllValuesInOne[i][1]) > LatestHigherNumber )
                {
                    SameValue.resize(0);

                    LatestHigherNumber = atoi(AllValuesInOne[i][1]);
                    SameValue.insertLast(AllValuesInOne[i][0]);
                }
                else if( atoi(AllValuesInOne[i][1]) == LatestHigherNumber )
                {
                    SameValue.insertLast(AllValuesInOne[i][0]);
                }
            }

            if( SameValue.length() <= 0 )
            {
                g_EntityFuncs.FireTargets( self.pev.message, self, self, USE_TOGGLE, 0.0f );
            }
            else
            {
                string FindName = SameValue[Math.RandomLong(0, SameValue.length()-1)];
                if(dictKeyValues.exists(FindName))
                {
                    string value;
                    dictKeyValues.get(FindName, value); 
                    g_EntityFuncs.FireTargets( value, self, self, USE_TOGGLE, 0.0f );
                }
            }

            g_EntityFuncs.FireTargets( self.pev.target, self, self, USE_TOGGLE, 0.0f );
        }
    }
}