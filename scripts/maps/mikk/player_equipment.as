#include "utils"
namespace player_equipment
{
	enum AFFECTED_PLAYERS
	{
		ACTIVATOR_ONLY = 0,
		ALL_PLAYERS = 1,
		ALL_PLAYERS_BUT_ACTIVATOR = 2
	}

	enum EQUIPMENT_ACTIONS
	{
		STRIP_WEAPON_AMMO = 0,
		STRIP_WEAPON = 1,
		STRIP_AMMO = 2,
		GIVE_WEAPON_AMMO = 3,
		GIVE_WEAPON = 4,
		GIVE_AMMO = 5,
		NO_ACTION = 6
	}

    class player_equipment : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        dictionary g_Keyvalues;
        int m_iAffected;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            g_Keyvalues[ szKey ] = szValue;

            if( szKey == "m_iAffected" )
            {
                m_iAffected = atoi( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_Keyvalues.getKeys(); }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( !IsLockedByMaster() )
			{
				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
					
					if( pPlayer !is null && pPlayer.IsConnected() )
					{
						switch( m_iAffected )
						{
							case ACTIVATOR_ONLY:
							{
								if( pPlayer is pActivator && pActivator !is null && pActivator.IsPlayer() )
								{
									ModifyInventory( cast<CBasePlayer@>(pActivator) );
								}
								break;
							}

							case ALL_PLAYERS:
							{
								ModifyInventory( pPlayer );
								break;
							}

							case ALL_PLAYERS_BUT_ACTIVATOR:
							{
								if( pPlayer !is pActivator )
								{
									ModifyInventory( pPlayer );
								}
								break;
							}
						}
					}
                }
			}
        }
        
        void ModifyInventory( CBasePlayer@ pPlayer )
        {
            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string iszclassname = string( strKeyValues[ui] );
                int m_iAction = atoi( string( g_Keyvalues[ iszclassname ] ) );

				if( m_iAction == NO_ACTION )
				{
					return;
				}

				bool bf = false;

				bool blItemSet = ( m_iAction != STRIP_WEAPON );

                if( iszclassname == 'item_suit' )
				{
					if( pPlayer.HasSuit() && !blItemSet || !pPlayer.HasSuit() && blItemSet )
					{
						bf = true;
					}

                    pPlayer.SetHasSuit( blItemSet );
                }
				else
				{
					if( iszclassname == 'item_longjump' )
					{
						pPlayer.m_fLongJump = blItemSet;
					}

					CBasePlayerItem@ pItem = pPlayer.HasNamedPlayerItem( iszclassname );

					if( pItem is null )
					{
						if( m_iAction == GIVE_WEAPON
						or  m_iAction == GIVE_WEAPON_AMMO )
						{
							if( pPlayer.HasNamedPlayerItem( iszclassname ) is null )
							{
								pPlayer.GiveNamedItem( iszclassname );
								@pItem = pPlayer.HasNamedPlayerItem( iszclassname );
							}
							
							if( pItem !is null )
							{
								bf = true;
							}
						}
					}

					if( pItem !is null )
					{
						if( m_iAction == STRIP_WEAPON
						or  m_iAction == STRIP_WEAPON_AMMO )
						{
							pPlayer.RemovePlayerItem( pItem );
							bf = true;
						}

						CBasePlayerWeapon@ pWeaponItem = cast<CBasePlayerWeapon@>(pItem);
						
						if( pWeaponItem !is null )
						{
							if( m_iAction == GIVE_AMMO
							or  m_iAction == GIVE_WEAPON_AMMO )
							{
								string[][] Weapons = 
								{
									{"weapon_m16", "ARgrenades"},
									{"weapon_m16", "556"},
									{"weapon_m249", "556"},
									{"weapon_shotgun", "buckshot"},
									{"weapon_9mmhandgun", "9mm"},
									{"weapon_9mmAR", "9mm"},
									{"weapon_uzi", "9mm"},
									{"weapon_uziakimbo", "9mm"},
									{"weapon_sporelauncher", "sporeclip"},
									{"weapon_rpg", "rockets"},
									{"weapon_gauss", "uranium"}, 
									{"weapon_egon", "uranium"},
									{"weapon_displacer", "uranium"},
									{"weapon_crossbow", "bolts"},
									{"weapon_eagle", "357"},
									{"weapon_357", "357"},
									{"weapon_sniperrifle", "m40a1"},
									{"weapon_satchel", "Satchel Charge"},
									{"weapon_tripmine", "Trip Mine"},
									{"weapon_handgrenade", "Hand Grenade"},
									{"weapon_snark", "snarks"}
								};

								for(uint i = 0; i < Weapons.length(); i++)
								{
									if( Weapons[i][0] == iszclassname )
									{
										if( pPlayer.AmmoInventory( pWeaponItem.m_iPrimaryAmmoType ) < pPlayer.GetMaxAmmo( Weapons[i][1] )
										or pPlayer.AmmoInventory( pWeaponItem.m_iSecondaryAmmoType ) < pPlayer.GetMaxAmmo( 'ARgrenades' ) && iszclassname == 'weapon_m16' )
										{
											pPlayer.GiveAmmo( pPlayer.GetMaxAmmo( Weapons[i][1] )+1, Weapons[i][1], pPlayer.GetMaxAmmo( Weapons[i][1] )+1 );
											bf = true;
										}
									}
								}
							}

							if( m_iAction == STRIP_AMMO
							or  m_iAction == STRIP_WEAPON_AMMO )
							{
								if( pPlayer.AmmoInventory( pWeaponItem.m_iPrimaryAmmoType ) >= 1 || pPlayer.AmmoInventory( pWeaponItem.m_iSecondaryAmmoType ) >= 1 )
								{
									pPlayer.m_rgAmmo( pWeaponItem.m_iPrimaryAmmoType, -1 );
									pPlayer.m_rgAmmo( pWeaponItem.m_iSecondaryAmmoType, -1 );
									bf = true;
								}
							}
						}
					}
				}

				if( bf ) g_Util.Trigger( string( self.pev.target ), pPlayer, self, USE_TOGGLE, delay );
			}
		}
    }
	bool Register = g_Util.CustomEntity( 'player_equipment::player_equipment','player_equipment' );
}