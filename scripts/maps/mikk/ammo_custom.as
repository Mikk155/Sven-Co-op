namespace ammo_custom
{
    void Register()
    {
        g_Util.ScriptAuthor.insertLast
        (
            "Script: ammo_custom\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: ammo item customizable that gives a specified ammout of bullets.\n"
        );

        g_CustomEntityFuncs.RegisterCustomEntity( "ammo_custom::ammo_custom", "ammo_custom" );
    }

    class ammo_custom : ScriptBasePlayerAmmoEntity
    {
        private string w_model = "models/w_shotbox.mdl";
        private string p_sound = "items/9mmclip1.wav";
        private string am_name = "buckshot";
        private int am_give = 8;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            if( szKey == "am_name" ) 
                am_name = szValue;
            else if( szKey == "p_sound" ) 
                p_sound = szValue;
            else if( szKey == "w_model" ) 
                w_model = szValue;
            else if( szKey == "am_give" ) 
                am_give = atoi( szValue );
            else
                return BaseClass.KeyValue( szKey, szValue );
            return true;
        }

        void Spawn()
        { 
            Precache();

            if( string( self.pev.targetname ).IsEmpty() ) self.pev.targetname = "ammocustom_" +self.entindex();

            dictionary g_keyvalues =
            {
                { "spawnflags", "64" },
                { "target", string( self.pev.targetname ) },
                { "renderamt", "0" },
                { "rendermode", "5" },
                { "targetname", string( self.pev.targetname ) + "_FX" }
            };

            g_EntityFuncs.CreateEntity( "env_render_individual", g_keyvalues );

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
            int iValue = atoi( g_Util.GetCKV( pOther, "$i_custom_ammo_" + self.entindex() ) );

            if( iValue < self.pev.frags || self.pev.frags == 0 )
            {
                if( pOther.GiveAmmo( am_give, am_name, 9999 ) != -1 )
                {
                    if( self.pev.frags > 0 )
                    {
                        g_Util.SetCKV( pOther, "$i_custom_ammo_" + self.entindex(), iValue + 1 );
                        
                        if( iValue == self.pev.frags - 1 )
                        {
                            g_Util.Trigger( string( self.pev.targetname ) + "_FX", pOther, pOther, USE_ON, 0.0f );
                        }
                    }

                    g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, p_sound, 1, ATTN_NORM);
                    return true;
                }
            }
            return false;
        }
    }
}
// end namespace