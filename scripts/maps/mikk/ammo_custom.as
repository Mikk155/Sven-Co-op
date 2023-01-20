namespace ammo_custom
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "ammo_custom::ammo_custom", "ammo_custom" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: ammo_custom\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: ammo item customizable that gives to the mapper the hability to give to players a specified ammout of bullets.\n"
        );
    }

    class ammo_custom : ScriptBasePlayerAmmoEntity
    {
        private string w_model = "models/w_shotbox.mdl";
        private string p_sound = "items/9mmclip1.wav";
        private string am_name = "buckshot";
        private int am_give = 8;

        void Spawn()
        { 
            Precache();
            g_EntityFuncs.SetModel( self, w_model );
            BaseClass.Spawn();
        }
        
        void Precache()
        {
            BaseClass.Precache();

            g_Game.PrecacheModel( w_model );
            g_SoundSystem.PrecacheSound( p_sound );
        }
        
        bool AddAmmo( CBaseEntity@ pOther ) 
        {
            if( g_Util.GetCKV( pOther, "$i_custom_ammo_" + self.entindex() ) != 1 )
            {
                if( pOther.GiveAmmo( am_give, am_name, 9999 ) != -1 )
                {
                    if( self.pev.SpawnFlagBitSet( 1 ) )
                        g_Util.SetCKV( pOther, "$i_custom_ammo_" + self.entindex(), 1 );

                    g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, p_sound, 1, ATTN_NORM);
                    return true;
                }
            }
            return false;
        }
    }
}
// end namespace