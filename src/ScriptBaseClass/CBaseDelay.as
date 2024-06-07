//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

const string szclassname = "DelayedUse";

void MapInit()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "ScriptBaseDelay", szclassname );
}

class ScriptBaseDelay : ScriptBaseEntity
{
	float m_flDelay;
	string_t m_iszKillTarget;

	bool KeyValue( const string& in szKeyName, const string& in szValue )
	{
		if( szKeyName == "delay" )
		{
			m_flDelay = atof( szValue );
		}
		else if( szKeyName == "killtarget" )
		{
			m_iszKillTarget = string_t( szValue );
		}
		else
		{
			return BaseClass.KeyValue( szKeyName, szValue );
		}
		return true;
	}

	void SUB_UseTargets( CBaseEntity@ pActivator, USE_TYPE useType, float value )
	{
		if( pev.target != '' || m_iszKillTarget != '' )
		{
			if( m_flDelay != 0 )
			{
				try
				{
					// create a temp object to fire at a later time
					ScriptBaseDelay@ pTemp = cast<ScriptBaseDelay@>( CastToScriptClass( g_EntityFuncs.Create( szclassname, g_vecZero, g_vecZero, false ) ) );

					pTemp.pev.nextthink = g_Engine.time + m_flDelay;
					pTemp.SetThink( ThinkFunction( pTemp.DelayThink ) );
					// Save the useType
					pTemp.pev.button = int(useType);
					pTemp.m_iszKillTarget = m_iszKillTarget;
					pTemp.m_flDelay = 0; // prevent "recursion"
					pTemp.pev.target = pev.target;

					if( pActivator !is null && pActivator.IsPlayer() )
					{
						@pTemp.pev.owner = pActivator.edict();
					}
				}
				catch
				{
					g_Game.AlertMessage( at_console, "Failed to create ScriptBaseDelay instance" + "\n" );
				}
				return;
			}

			if( m_iszKillTarget != '' )
			{
				g_Game.AlertMessage( at_aiconsole, "KillTarget: %1\n", string( m_iszKillTarget ) );

				CBaseEntity@ pentKillTarget = null;

				while( ( @pentKillTarget = g_EntityFuncs.FindEntityByTargetname( pentKillTarget, string( m_iszKillTarget ) ) ) !is null )
				{
					g_Game.AlertMessage( at_aiconsole, "killing %1\n", string( pentKillTarget.pev.classname ) );
					g_EntityFuncs.Remove( pentKillTarget );
				}
			}

			if( pev.target != '' )
			{
				g_EntityFuncs.FireTargets( string( pev.target ), pActivator, self, useType, value );
			}
		}
	}

	void DelayThink()
	{
		CBaseEntity@ pActivator = null;

		if( pev.owner !is null ) // A player activated this on delay
		{
			@pActivator = g_EntityFuncs.Instance( pev.owner );
		}

		// The use type is cached (and stashed) in pev->button
		SUB_UseTargets( pActivator, USE_TYPE( pev.button ), 0 );
		g_EntityFuncs.Remove( self );
	}
}
