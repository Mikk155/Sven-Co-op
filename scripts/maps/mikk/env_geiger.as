namespace env_geiger
{
    void Register()
    {
        g_Util.ScriptAuthor.insertLast
        (
            "Script: env_geiger\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Entity that simulates radiation sound.\n"
        );

        g_CustomEntityFuncs.RegisterCustomEntity( "env_geiger::env_geiger", "env_geiger" );
    }

    class env_geiger : ScriptBaseEntity
    {
        private bool State = true;

        void Spawn()
        {
            Precache();
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;
            BaseClass.Spawn();
        }

        void Precache() 
        {
            for( int number = 1; number < 7; number++ )
            {
                g_Game.PrecacheGeneric( "sound/player/geiger" + string( number ) + ".wav" );
                g_SoundSystem.PrecacheSound( "sound/player/geiger" + string( number ) + ".wav" );
            }
            BaseClass.Precache();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( useType == USE_ON ) State = true;
            else if( useType == USE_OFF ) State = false;
            else State = !State;
        }

        void Think()
        {
            float fRandom = Math.RandomFloat( 0, 0.6 );

            if( State )
            {
                string geiger = "player/geiger" + string( Math.RandomLong( 1, 6 ) ) + ".wav";

                g_SoundSystem.EmitAmbientSound( self.edict(), self.pev.origin, geiger, 1,  ATTN_IDLE, 0, PITCH_NORM );
            }

            self.pev.nextthink = g_Engine.time + fRandom;
        }
    }
}
// End of namespace