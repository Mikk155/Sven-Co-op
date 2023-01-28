#include "utils"
namespace trigger_votemenu
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_votemenu::entity", "trigger_votemenu" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: trigger_votemenu\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Wootguy\n"
            "Github: github.com/wootguy\n"
            "Description: Allow mapper to create a buymenu-like vote for one or all players.\n"
        );
    }

    class entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        dictionary dictKeyValues;
        dictionary dictFinalResults;

        // Menus need to be defined globally when the plugin is loaded or else paging doesn't work.
        // Each player needs their own menu or else paging breaks when someone else opens the menu.
        // These also need to be modified directly (not via a local var reference). - Wootguy
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
            ExtraKeyValues(szKey, szValue);
            dictKeyValues[szKey] = szValue;
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }

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
            g_Scheduler.SetTimeout( @this, "Results", int(self.pev.health) + 3 );
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

            string FindName = SameValue[Math.RandomLong(0, SameValue.length()-1)];
            if(dictKeyValues.exists(FindName))
            {
                string value;
                dictKeyValues.get(FindName, value); 
                g_Util.Trigger( value, self, self, USE_TOGGLE, delay );
                g_Util.Trigger( self.pev.target, self, self, USE_TOGGLE, delay );
            }
        }
    }
}
// End of namespace