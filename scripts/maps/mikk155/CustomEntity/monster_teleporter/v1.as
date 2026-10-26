/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

class ASMonsterTeleporterTemplate : ScriptBaseEntity
{
    private dictionary data;

    private void SetPair( const string&in key, const string&in value ) final
    {
        if( !value.IsEmpty() )
            this.data[ key ] = value;
    }

    dictionary@ get_Data() property final
    {
        SetPair( "model", self.pev.model );
        SetPair( "origin", self.pev.origin.ToString() );
        SetPair( "angles", self.pev.angles.ToString() );
        SetPair( "health", self.pev.health );
        SetPair( "max_health", self.pev.max_health );
        SetPair( "target", self.pev.target );
        SetPair( "message", self.pev.message );
        SetPair( "spawnflags", self.pev.spawnflags );

        return @data;
    }

    bool KeyValue( const string&in key, const string&in value )
    {
        this.data[ key ] = value;
        return true;
    }

    void Spawn()
    {
        self.pev.solid = SOLID_NOT;
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.effects |= EF_NODRAW;
    }
}

class ASMonsterTeleporter : ScriptBaseEntity
{
    private array<EHandle> m_Childrens;
    private EHandle m_hOwner;
    private CBaseMonster@ m_pMonster;
    private bool m_Summoning = false;
    private int m_IndexAnimation;
    private string m_AnimationName;
    private string m_TemplateName;
    private EHandle m_hTemplate;
    private string m_XenmakerName;
    private EHandle m_hXenmaker;
    private EHandle m_hLastEnemy;
    private MONSTERSTATE m_PreviousMonsterState;

    float[] m_SummonCooldown = { 0.0f, 20.0f };
    float m_SummonHeight = 80.0f;
    float m_SummonDistance = 256.0f;
    float m_SummonDelay = 0.5f;
    int m_MaxLiving = 1;
    private array<string> m_Monsters;

    bool KeyValue( const string& in key, const string& in value )
    {
        if( key == "summon_monster" )
        {
            this.m_Monsters = value.Split( ';' );
        }
        if( key == "summon_animation" )
        {
            this.m_AnimationName = value;
        }
        else if( key == "summon_delay" )
        {
            this.m_SummonDelay = atof(value);
        }
        else if( key == "summon_max" )
        {
            this.m_MaxLiving = atoi(value);
        }
        else if( key == "summon_cooldown_1" )
        {
            this.m_SummonCooldown[0] = atof(value);
        }
        else if( key == "summon_cooldown_2" )
        {
            this.m_SummonCooldown[1] = atof(value);
        }
        else if( key == "summon_height" )
        {
            this.m_SummonHeight = atof(value);
        }
        else if( key == "summon_distance" )
        {
            this.m_SummonDistance = atof(value);
        }
        else if( key == "summon_template" )
        {
            this.m_XenmakerName = value;
            this.m_hXenmaker = EHandle();
        }
        else if( key == "entity_template" )
        {
            this.m_TemplateName = value;
            this.m_hTemplate = EHandle();
        }
        else
        {
            return BaseClass.KeyValue( key, value );
        }
        return true;
    }

    void Precache()
    {
        dictionary@ data = {};

        ASMonsterTeleporterTemplate@ template = this.Template;

        if( template !is null )
        {
            @data = template.Data;
        }

        const uint length = this.m_Monsters.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            CBaseEntity@ entity = g_EntityFuncs.CreateEntity( this.m_Monsters[ui], data, true );
            g_EntityFuncs.Remove( entity );
        }
    }

    const bool get_IsActive() const property final
    {
        return ( ( self.pev.spawnflags & 1 ) != 0 );
    }

    void Spawn()
    {
        Precache();

        self.pev.solid = SOLID_NOT;
        self.pev.movetype = MOVETYPE_NONE;

        if( ( self.pev.spawnflags & 1 ) != 0 )
        {
            Use(null, null, USE_ON, 0);
        }
    }

    void Shutdown()
    {
        self.pev.spawnflags &= ~1;
        self.pev.nextthink = 0;
        SetThink( null );

        this.RestoreOwnerState();
        this.m_Summoning = false;
    }

    void UpdateOnRemmove()
    {
        this.Shutdown();
    }

    void Use( CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value )
    {
        switch( useType )
        {
            case USE_ON:
            {
                self.pev.spawnflags |= 1;
                self.pev.nextthink = g_Engine.time;
                SetThink( ThinkFunction( this.Think ) );
                break;
            }
            case USE_OFF:
            {
                this.Shutdown();
                break;
            }
            case USE_TOGGLE:
            {
                self.Use(activator, caller, ( this.IsActive ? USE_OFF : USE_ON ), value );
                break;
            }
        }
    }

    CBaseEntity@ get_Xenmaker() property final
    {
        if( this.m_hXenmaker.IsValid() )
            return this.m_hXenmaker.GetEntity();

        if( this.m_XenmakerName.IsEmpty() )
            return null;

        CBaseEntity@ entity = g_EntityFuncs.FindEntityByTargetname( null, this.m_XenmakerName );

        this.m_hXenmaker = EHandle( entity );

        return entity;
    }

    ASMonsterTeleporterTemplate@ get_Template() property final
    {
        if( !this.m_hTemplate.IsValid() )
        {
            if( this.m_TemplateName.IsEmpty() )
                return null;

            CBaseEntity@ entity = g_EntityFuncs.FindEntityByTargetname( null, this.m_TemplateName );

            this.m_hTemplate = EHandle( entity );
        }

        return cast<ASMonsterTeleporterTemplate@>( CastToScriptClass( this.m_hTemplate.GetEntity() ) );
    }

    CBaseMonster@ get_Owner() property final
    {
        if( this.m_hOwner.IsValid() && this.m_hOwner.GetEntity() !is null && this.m_pMonster !is null && this.m_pMonster.IsAlive() )
        {
            return this.m_pMonster;
        }

        string targetEntity = string( self.pev.target );

        if( targetEntity.IsEmpty() )
        {
            g_Game.AlertMessage( at_console, "[%1] Got empty target at %2. Removing...\n", self.GetClassname(), self.pev.origin.ToString() );
            self.pev.flags |= EdictFlags::FL_KILLME;
            return null;
        }

        CBaseEntity@ entity = g_EntityFuncs.FindEntityByTargetname( null, targetEntity );

        if( entity is null )
        {
            g_Game.AlertMessage( at_console, "[%1] Can not find entity with name \"%2\" Removing...\n", self.GetClassname(), targetEntity );
            self.pev.flags |= EdictFlags::FL_KILLME;
            return null;
        }

        @this.m_pMonster = cast<CBaseMonster@>(entity);

        if( this.m_pMonster is null )
        {
            g_Game.AlertMessage( at_console, "[%1] Entity with name \"%2\" is not a monster! Removing...\n", self.GetClassname(), targetEntity );
            self.pev.flags |= EdictFlags::FL_KILLME;
            return null;
        }

        this.m_hOwner = EHandle( this.m_pMonster );
        @self.pev.owner = this.m_pMonster.edict();
        self.pev.target = string_t();
        this.m_IndexAnimation = this.m_pMonster.LookupSequence( this.m_AnimationName );

        if( this.m_IndexAnimation < 0 )
        {
            g_Game.AlertMessage( at_console, "[%1] Entity with name \"%2\" doesn't contain animation with name \"%3\" for model \"%4\" Removing...\n", self.GetClassname(), targetEntity, this.m_AnimationName, string( this.m_pMonster.pev.model ) );
            self.pev.flags |= EdictFlags::FL_KILLME;
            return null;
        }

        this.m_AnimationName.Clear();

        return this.m_pMonster;
    }

    // Deactivate any running animation or effects
    void RestoreOwnerState()
    {
        CBaseMonster@ owner = this.Owner;

        if( owner is null )
            return;

        if( owner.m_MonsterState == MONSTERSTATE::MONSTERSTATE_PLAYDEAD )
        {
            owner.CineCleanup();
            owner.RunAI();
            owner.SetState( this.m_PreviousMonsterState );
            owner.ClearSchedule();
            owner.StartMonster();
            owner.ResetSequenceInfo();
        }
    }

    void Think()
    {
        CBaseMonster@ owner = this.Owner;

        if( owner is null )
            return;

        CBaseEntity@ enemy;

        if( !owner.m_hEnemy.IsValid() || ( @enemy = owner.m_hEnemy.GetEntity() ) is null )
        {
            self.pev.nextthink = g_Engine.time + 3.0f;
            return;
        }

        this.m_hLastEnemy = EHandle( enemy );

        if( this.m_MaxLiving > 0 )
        {
            for( uint ui = 0; ui < this.m_Childrens.length(); ui++ )
            {
                EHandle handle = this.m_Childrens[ui];

                if( !handle.IsValid() || handle.GetEntity() is null || !handle.GetEntity().IsAlive() )
                {
                    this.m_Childrens.removeAt(ui--);
                }
            }

            if( this.m_MaxLiving <= int( this.m_Childrens.length() ) )
            {
                self.pev.nextthink = g_Engine.time + 5.0f;
                return;
            }
        }

        self.pev.nextthink = g_Engine.time + 0.1f;

        if( this.m_Summoning )
        {
            this.RestoreOwnerState();

            CBaseEntity@ xenmaker = this.Xenmaker;

            if( xenmaker !is null )
            {
                g_EntityFuncs.SetOrigin( xenmaker, self.pev.origin );
                xenmaker.Use(self, owner, USE_ON, 0.0f);
            }

            string candidate = this.m_Monsters[ Math.RandomLong( 0, this.m_Monsters.length() - 1 ) ];

            self.pev.noise = string_t( candidate );
            g_EntityFuncs.FireTargets( self.pev.netname, owner, self, USE_TOGGLE, 0.0f, 0.0f );

            dictionary@ data = {};

            ASMonsterTeleporterTemplate@ template = this.Template;

            if( template !is null )
            {
                @data = template.Data;
            }

            CBaseEntity@ entity = g_EntityFuncs.CreateEntity( candidate, data, true );

            g_EntityFuncs.SetOrigin( entity, self.pev.origin );
            entity.pev.angles = owner.pev.angles;
            @entity.pev.owner = owner.edict();
            entity.SetClassification( owner.GetClassification( owner.Classify() ) );

            if( this.m_MaxLiving > 0 )
            {
                this.m_Childrens.insertLast( entity );
            }

            g_EntityFuncs.FireTargets( self.pev.message, owner, self, USE_TOGGLE, 0.0f, 0.0f );

            owner.PushEnemy( m_hLastEnemy.GetEntity(), m_hLastEnemy.GetEntity().pev.origin );

            self.pev.nextthink = g_Engine.time + Math.RandomFloat( this.m_SummonCooldown[0], this.m_SummonCooldown[1] );
            this.m_Summoning = false;
            return;
        }

        if( owner.m_MonsterState == MONSTERSTATE::MONSTERSTATE_PLAYDEAD )
        {
            owner.pev.sequence = this.m_IndexAnimation;
            owner.ResetSequenceInfo();
            this.m_Summoning = true;
            self.pev.nextthink = g_Engine.time + this.m_SummonDelay;
            return;
        }

        if( !owner.CanPlaySequence( true, 0 ) )
            return;

        bool canSummon = false;

        Vector start = owner.pev.origin;
        start.z += ( owner.pev.maxs.z - owner.pev.mins.z ) * 0.5f;

        for( int i = 0; i < 8; i++ )
        {
            float angle = Math.RandomFloat( 0.0f, 2.0f * Math.PI );
            Vector target = owner.pev.origin + Vector(
                cos( angle ) * this.m_SummonDistance,
                sin( angle ) * this.m_SummonDistance,
                ( owner.pev.maxs.z - owner.pev.mins.z ) * 0.5f + this.m_SummonHeight
            );

            TraceResult trace;
            g_Utility.TraceHull( start, target, ignore_monsters, large_hull, owner.edict(), trace );

            if( trace.fStartSolid != 0 || trace.flFraction < 0.5f )
                continue;

            Vector direction = ( target - owner.pev.origin ).Normalize();
            self.pev.origin = trace.vecEndPos - direction * 40.0f;
            self.pev.origin.z -= 40.0f;
            canSummon = true;
            break;
        }

        if( !canSummon )
            return;

        this.m_PreviousMonsterState = owner.m_MonsterState;

        owner.SetState( MONSTERSTATE::MONSTERSTATE_PLAYDEAD );
        owner.Stop();
        owner.StopAnimation();
        owner.ClearSchedule();
    }
}

namespace ASMonsterTeleporter
{
    const bool Registered = Register();

    bool Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "ASMonsterTeleporter", "monster_teleporter" );
        g_CustomEntityFuncs.RegisterCustomEntity( "ASMonsterTeleporterTemplate", "monster_teleporter_template" );
        return g_CustomEntityFuncs.IsCustomEntity( "monster_teleporter" );
    }
}
