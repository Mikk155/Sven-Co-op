/*
*   Passes repel's "message" to child's "targetname"
*   Fires repel's "target" after the entity is spawned, !activator is the child
*   TriggerTarget and TriggerCondition are passed onto the child
*/

namespace CRepelChilds
{
    // Call after all entities are initialised
    void MapActivate()
    {
        array<string> szRepel = CClassNames.getKeys();

        for( uint ui = 0; ui < szRepel.length(); ui++ )
        {
            CBaseEntity@ CRepels = null;

            while( ( @CRepels = g_EntityFuncs.FindEntityByClassname( CRepels, szRepel[ui] ) ) !is null )
            {
                dictionary gpData;
                gpData[ "targetname" ] = string( CRepels.pev.targetname );
                gpData[ "m_iMode" ] = "2";
                gpData[ "m_flThinkDelta" ] = "0.1";
                gpData[ "m_iszScriptFunctionName" ] = "CRepelChilds::RepelUse";

                CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( "trigger_script", gpData );
                if( pTriggerScript is null ) { continue; }

                pTriggerScript.SetOrigin( CRepels.GetOrigin() );
                @pTriggerScript.pev.owner = CRepels.edict();

                if( CRepels.pev.target != '' ) { g_EntityFuncs.DispatchKeyValue( pTriggerScript.edict(), "$s_FireTargets", CRepels.pev.target ); }
                if( CRepels.pev.message != '' ) { g_EntityFuncs.DispatchKeyValue( pTriggerScript.edict(), "$s_targetname", CRepels.pev.message ); }

                CBaseMonster@ pRepel = cast<CBaseMonster@>( CRepels );
                if( pRepel is null ) { continue; }

                if( pRepel.m_iszTriggerTarget != '' ) { g_EntityFuncs.DispatchKeyValue( pTriggerScript.edict(), "$s_TriggerTarget", pRepel.m_iszTriggerTarget ); }
                if( pRepel.m_iTriggerCondition != 0 ) { g_EntityFuncs.DispatchKeyValue( pTriggerScript.edict(), "$i_TriggerCondition", pRepel.m_iTriggerCondition ); }
            }
        }
    }

    dictionary CClassNames =
    {
        { "monster_grunt_repel", "monster_human_grunt" },
        { "monster_hwgrunt_repel", "monster_hwgrunt" },
        { "monster_assassin_repel", "monster_male_assassin" },
        { "monster_robogrunt_repel", "monster_robogrunt" },
        { "monster_torch_ally_repel", "monster_human_torch_ally" },
        { "monster_grunt_ally_repel", "monster_human_grunt_ally" },
        { "monster_medic_ally_repel", "monster_human_medic_ally" }
    };

    void RepelUse( CBaseEntity@ self )
    {
        TraceResult tr; // https://github.com/ValveSoftware/halflife/tree/master/dlls/hgrunt.cpp#L2408
        g_Utility.TraceLine( self.pev.origin, self.pev.origin + Vector( 0, 0, -4096.0), dont_ignore_monsters, ( self.pev.owner is null ? self.edict() : self.pev.owner ), tr );

        if( tr.pHit is null ) { return; }
        CBaseEntity@ EntChild = g_EntityFuncs.Instance( tr.pHit );
        if( EntChild is null || !EntChild.IsMonster() ) { return; }

        CBaseMonster@ pChild = cast<CBaseMonster@>( EntChild );
        if( pChild is null ) { return; }

        if( self.GetCustomKeyvalues().HasKeyvalue( "$s_targetname" ) ) { pChild.pev.targetname = self.GetCustomKeyvalues().GetKeyvalue( "$s_targetname" ).GetString(); }
        if( self.GetCustomKeyvalues().HasKeyvalue( "$s_TriggerTarget" ) ) { pChild.m_iszTriggerTarget = self.GetCustomKeyvalues().GetKeyvalue( "$s_TriggerTarget" ).GetString(); }
        if( self.GetCustomKeyvalues().HasKeyvalue( "$i_TriggerCondition" ) ) { pChild.m_iTriggerCondition = self.GetCustomKeyvalues().GetKeyvalue( "$i_TriggerCondition" ).GetInteger(); }
        if( self.GetCustomKeyvalues().HasKeyvalue( "$s_FireTargets" ) ) { g_EntityFuncs.FireTargets( self.GetCustomKeyvalues().GetKeyvalue( "$s_FireTargets" ).GetString(), pChild, ( self.pev.owner !is null ? g_EntityFuncs.Instance( self.pev.owner ) : null ), USE_TOGGLE, 0 ); }

        g_EntityFuncs.Remove( self );
    }
}
