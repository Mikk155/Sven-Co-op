class func_prop : ScriptBaseMonsterEntity
{
	private string kv_Velocity		= "100";
	private string Kv_gibmodels		= "models/error.mdl";
	private string Kv_damage		= "100";
	
	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
        if( szKey == "friction" )
        {
            kv_Velocity = szValue;
            return true;
        }
        if( szKey == "gibmodel" )
        {
            Kv_gibmodels = szValue;
            return true;
        }
        if( szKey == "damage" )
        {
            Kv_damage = szValue;
            return true;
        }
		else if( szKey == "minhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		} 
		else if( szKey == "maxhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
        else 
            return BaseClass.KeyValue( szKey, szValue );
    }
	
	void Spawn()
	{
		Precache();

		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;
		
        if( self.GetClassname() == "func_prop" && string( self.pev.model )[0] == "*" && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, self.pev.model );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
        }
		else if( string( self.pev.model != "" )
		{
			g_EntityFuncs.SetModel( self, self.pev.model );

			if( self.pev.vuser2 != g_vecZero && self.pev.vuser1 != g_vecZero )
			{
				g_EntityFuncs.SetSize( self.pev, Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) );
			}
		}
		else
		{
			g_EntityFuncs.SetModel( self, "models/error.mdl" );
			self.pev.solid = SOLID_NOT;
		}

		self.pev.velocity = kv_Velocity;
	}

    void Precache()
    {
		else if( string( self.pev.model != "" )
		{
			g_Game.PrecacheModel( self.pev.model );
		}
		else
		{
			g_Game.PrecacheModel( "models/error.spr" );
		}
		
		// Precachar Kv_gibmodels

        BaseClass.Precache();
    }
	
	void Touch( CBaseEntity@ pOther )
	{
		if( !pOther.IsPlayerAlly() && self.pev.velocity.Length() > 20 )
		{
			pOther.TakeDamage( self.pev, self.pev, self.pev.velocity.Length() * 0.33, DMG_CRUSH );

			self.pev.velocity = self.pev.velocity * 0.45f;
		}

		if( (self.pev.flags & FL_ONGROUND) != 0 )
		{
			self.pev.velocity = self.pev.velocity * 0.8f;
		}
		
		if( self.pev.SpawnFlagBitSet( 1 ) )
		{
			// Explotar + lanzar gibs de modelo especificado en Kv_gibmodels + hacer daño especificado en Kv_damage
			g_EntityFuncs.Remove( self );
		}
	}
}

void RegisterFuncProp()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "func_prop", "func_prop" );
}