#include "../../mikk/as_register"

namespace base
{
    void MapInit()
    {
        g_Game.PrecacheGeneric( 'sprites/limitlesspotential/crosshair.spr' );
        g_Game.PrecacheGeneric( 'sprites/limitlesspotential/weapon_lp_knife.spr' );
        g_Game.PrecacheGeneric( 'sprites/limitlesspotential/xhair_sniper.spr' );
        g_Game.PrecacheGeneric( 'sprites/limitlesspotential/xhair_xbow.spr' );
        g_ClassicMode.SetItemMappings( ItemMappingWeapons );
        g_ClassicMode.ForceItemRemap( true );
    }
}

string m_iszSpriteTextPath = 'limitlesspotential/v1';
string m_iszMessageTextPath = 'scripts/maps/LimitlessPotential/MSG/weapons/';

array<ItemMapping@> ItemMappingWeapons;

void InsertItemMapping( const string &in m_iszOldItem, const string &in m_iszNewItem )
{
    ItemMappingWeapons.insertLast( ItemMapping( m_iszOldItem, m_iszNewItem ) );
}

mixin class LimitlessPotentialWeapon
{
    private string c_shell		=	'models/shell.mdl';
    private int c_ishell;

    private string c_sfx_empty	=	'hlclassic/weapons/357_cock1.wav';

    void Spawn()
    {
        Precache();

        self.PrecacheCustomModels();

        g_EntityFuncs.SetModel( self, c_w_model );

        self.m_iDefaultAmmo = c_default_give;

        self.FallInit(); // get ready to fall down.

        BaseClass.Spawn();
    }

    void Precache()
    {
        for( uint i = 0; i < c_precache.length(); i++ )
        {
            if( c_precache[i].EndsWith( '.mdl' ) )
            {
                g_Game.PrecacheModel( c_precache[i] );
			    g_Game.PrecacheGeneric( c_precache[i] );
            }
            else if( c_precache[i].EndsWith( '.spr' ) )
            {
			    g_Game.PrecacheGeneric( c_precache[i] );
            }
            else if( !c_precache[i].IsEmpty() )
            {
                g_Game.PrecacheGeneric( 'sound/' + c_precache[i] );
                g_SoundSystem.PrecacheSound( c_precache[i] );
            }
        }

        c_ishell = g_Game.PrecacheModel( c_shell );

        g_Game.PrecacheGeneric( "sprites/" + m_iszSpriteTextPath + "/" + self.GetClassname() + ".txt" );

        BaseClass.Precache();
    }

    private CBasePlayer@ m_pPlayer = null;

    bool PlayEmptySound()
    {
        if( self.m_bPlayEmptySound )
        {
            self.m_bPlayEmptySound = false;
            
            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, c_sfx_empty, 0.8, ATTN_NORM, 0, PITCH_NORM );
        }
        return false;
    }

    bool CanFire( const int iWaterLevel )
    {
        if( m_pPlayer.pev.waterlevel == iWaterLevel || self.m_iClip <= 0 )
        {
            self.PlayEmptySound();
            self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
            return false;
        }
        return true;
    }

    void SuitUpdate()
    {
        if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
            m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
    }

    bool AddToPlayer( CBasePlayer@ pPlayer )
    {
        if( !BaseClass.AddToPlayer( pPlayer ) )
            return false;
        
        @m_pPlayer = pPlayer;
        
        NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
            message.WriteLong( self.m_iId );
        message.End();
        
        return true;
    }
}