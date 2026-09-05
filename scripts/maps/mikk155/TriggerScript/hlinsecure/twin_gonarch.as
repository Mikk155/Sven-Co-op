/**
 *  Copyright (c) 2026 Mikk155
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of the files covered by this license, to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the files, subject to the
 *  following condition:
 *
 *  The original repository must be credited by including a link to:
 *
 *  https://github.com/Mikk155/Sven-Co-op
 *
 *  This notice and the attribution requirement shall be included in all
 *  substantial copies or distributions of the files.
 *
 *  THE FILES ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE FILES OR THE USE OR OTHER DEALINGS IN THE
 *  FILES.
**/

namespace ASTwinGonarch
{
    int __ControllerCount__ = 0;

    const int gTGSpitSprite = g_Game.PrecacheModel( "sprites/mommaspout.spr" );

    const Cvar@ twinGonarchDmgBlast = g_EngineFuncs.CVarGetPointer( "sk_bigmomma_dmg_blast" );
    const Cvar@ twinGonarchRadiusBlast = g_EngineFuncs.CVarGetPointer( "sk_bigmomma_radius_blast" );

    void TGMortarSpray( const Vector&in position, const Vector&in direction, int spriteModel, int count )
    {
        NetworkMessage m( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, position );
            m.WriteByte( TE_SPRITE_SPRAY );
            m.WriteCoord( position.x ); // pos
            m.WriteCoord( position.y );
            m.WriteCoord( position.z );
            m.WriteCoord( direction.x ); // dir
            m.WriteCoord( direction.y );
            m.WriteCoord( direction.z );
            m.WriteShort( spriteModel ); // model
            m.WriteByte( count ); // count
            m.WriteByte( 130 ); // speed
            m.WriteByte( 80 ); // noise ( client will divide by 100 )
        m.End();
    }

    final class ASTwinGonarchMortar : ScriptBaseEntity
    {
        int m_maxFrame;

        void Spawn()
        {
            pev.movetype = MOVETYPE_TOSS;
            pev.solid = SOLID_BBOX;
            pev.rendermode = kRenderTransAlpha;
            pev.renderamt = 255;

            g_EntityFuncs.SetModel( self, "sprites/mommaspit.spr" );

            pev.frame = 0;
            pev.scale = 0.5;

            g_EntityFuncs.SetSize( pev, g_vecZero, g_vecZero );

            g_EngineFuncs.ModelFrames( pev.modelindex ) - 1;

            pev.dmgtime = g_Engine.time + 0.4;
            pev.nextthink = g_Engine.time + 0.1;
        }

        void Touch( CBaseEntity@ pOther )
        {
            TraceResult tr;
            int iPitch;

            // splat sound
            iPitch = Math.RandomLong( 90, 110 );

            g_SoundSystem.EmitSoundDyn( pev.owner, CHAN_VOICE, "bullchicken/bc_acid1.wav", 1, ATTN_NORM, 0, iPitch );

            switch( Math.RandomLong( 0, 1 ) )
            {
                case 0:
                    g_SoundSystem.EmitSoundDyn( pev.owner, CHAN_WEAPON, "bullchicken/bc_spithit1.wav", 1, ATTN_NORM, 0, iPitch );
                    break;
                case 1:
                    g_SoundSystem.EmitSoundDyn( pev.owner, CHAN_WEAPON, "bullchicken/bc_spithit2.wav", 1, ATTN_NORM, 0, iPitch );
                    break;
            }

            if( pOther !is null && pOther.IsBSPModel() )
            {
                // make a splat on the wall
                g_Utility.TraceLine( pev.origin, pev.origin + pev.velocity * 18, dont_ignore_monsters, self.edict(), tr );
                g_Utility.DecalTrace( tr, DECAL_MOMMASPLAT );
            }
            else
            {
                tr.vecEndPos = pev.origin;
                tr.vecPlaneNormal = -1 * pev.velocity.Normalize();
            }

            // make some flecks
            TGMortarSpray( tr.vecEndPos, tr.vecPlaneNormal, gTGSpitSprite, 24 );

            entvars_t@ owner = g_EngineFuncs.GetVarsOfEnt( pev.owner );

            g_WeaponFuncs.RadiusDamage( pev.origin, pev, owner, twinGonarchDmgBlast.value, twinGonarchRadiusBlast.value, CLASS_NONE, DMG_ACID );
            g_EntityFuncs.Remove( self );
        }

        void Think()
        {
            pev.nextthink = g_Engine.time + 0.1;

            if( g_Engine.time > pev.dmgtime )
            {
                pev.dmgtime = g_Engine.time + 0.2;
                TGMortarSpray( pev.origin, pev.velocity.Normalize(), gTGSpitSprite, 3 );
            }

            if( 0 != pev.frame++ )
            {
                if( pev.frame > m_maxFrame )
                {
                    pev.frame = 0;
                }
            }
        }
    };

    ASTwinGonarchMortar@ Shoot( edict_t@ owner, const Vector&in vecStart, const Vector&in vecVelocity )
    {
        CBaseEntity@ pSpit = g_EntityFuncs.Create( "tmortar", vecStart, g_vecZero, false, owner );
        pSpit.pev.velocity = vecVelocity;
        pSpit.pev.scale = 2.5;
        return cast<ASTwinGonarchMortar@>( CastToScriptClass( pSpit ) );
    }

    final class ASTwinGonarch : ScriptBaseEntity
    {
        ASTwinGonarch()
        {
            ++__ControllerCount__;
        }

        ~ASTwinGonarch()
        {
            if( --__ControllerCount__ == 0 )
            {
                g_CustomEntityFuncs.UnRegisterCustomEntity( "tmortar" );
                g_CustomEntityFuncs.UnRegisterCustomEntity( "tcontroller" );
            }
        }

        private
            CBaseMonster@ m_Gonarch = null;

        CBaseMonster@ get_Gonarch()
        {
            CBaseMonster@ monster = null;
            CBaseEntity@ entity = null;

            if( this.m_Gonarch is null )
            {
                if( pev.owner !is null
                && ( @entity = g_EntityFuncs.Instance( pev.owner ) ) !is null
                && ( @monster = cast<CBaseMonster@>( entity ) ) !is null )
                {
                    @this.m_Gonarch = monster;
                }
            }

            if( this.m_Gonarch !is null && this.m_Gonarch.IsAlive() )
            {
                return @this.m_Gonarch;
            }

            self.pev.flags |= FL_KILLME;

            return null;
        }

        void Spawn()
        {
            pev.solid = SOLID_NOT;
            pev.movetype = MOVETYPE_NONE;
            pev.nextthink = g_Engine.time + 0.0;
        }

        void Think()
        {
            if( Gonarch is null )
                return;

            pev.nextthink = g_Engine.time + 0.01f;

            // ADDITION: Makes gonarch to cum more frequently on phase two
            if( Gonarch.pev.fuser1 < g_Engine.time && Gonarch.pev.fuser1 > 0 )
            {
                Gonarch.m_IdealActivity = ACT_RANGE_ATTACK1;
            }

            // cumming
            if( Gonarch.pev.iuser1 == 1 )
            {
                CBaseEntity@ bmortar = g_EntityFuncs.FindEntityByClassname( null, "bmortar" );

                if( bmortar !is null )
                {
                    bmortar.UpdateOnRemove();
                    g_EntityFuncs.Remove(bmortar);

                    Vector vecSpitDir;

                    CBaseEntity@ enemy = Gonarch.m_hEnemy.GetEntity();

                    Vector vecStart = Gonarch.pev.origin;
                    vecStart.z += 16;

                    vecSpitDir = ( ( enemy.pev.origin + enemy.pev.view_ofs ) - vecStart ).Normalize();

                    ASTwinGonarchMortar@ tmortar = Shoot( Gonarch.edict(), vecStart, vecSpitDir * 2000 );

                    if( ( Gonarch.pev.spawnflags & 64 ) != 0 )
                    {
                        Vector startPos = Gonarch.pev.origin;

                        if( Math.RandomLong( 0, 1 ) == 1 )
                        {
                            startPos.y -= 120;
                        }
                        else
                        {
                            startPos.y += 120;
                        }
                        startPos.z += 180;

                        switch( Math.RandomLong( 0, 2 ) )
                        {
                            case 0:
                                g_SoundSystem.EmitSoundDyn( Gonarch.edict(), CHAN_WEAPON, "gonarch/gon_sack1.wav", 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -5, 5 ) );
                            break;
                            case 1:
                                g_SoundSystem.EmitSoundDyn( Gonarch.edict(), CHAN_WEAPON, "gonarch/gon_sack2.wav", 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -5, 5 ) );
                            break;
                            case 2:
                                g_SoundSystem.EmitSoundDyn( Gonarch.edict(), CHAN_WEAPON, "gonarch/gon_sack3.wav", 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -5, 5 ) );
                            break;
                        }

                        ASTwinGonarchMortar@ tmortar2 = Shoot( Gonarch.edict(), startPos, Gonarch.pev.movedir );
                        tmortar2.pev.gravity = 1.0;

                        // ADDITION: Makes gonarch to cum more frequently on phase two
                        Gonarch.pev.fuser1 = g_Engine.time + Math.RandomLong( 5, 15 );
                    }

                    // Launch particles to the sky (Original)
//                    TGMortarSpray( vecStart, Vector(0, 0, 1), gTGSpitSprite, 24 );

                    // ADDITION: Launch particles to the aiming direction
                    TGMortarSpray( vecStart, vecSpitDir, gTGSpitSprite, 24 );
                    // Sadly we can not prevent the game from playing the original bmortar particles so these are still visible

                    Gonarch.pev.iuser1 = 0;
                }
            }
            // She wants to cum?
            else if( Gonarch.pev.sequence == 9 )
            {
                Gonarch.pev.iuser1 = 1;
            }
        }
    }

    void Register( CBaseEntity@ triggerScript, CBaseEntity@ caller, USE_TYPE, float value )
    {
        if( triggerScript is null || triggerScript.GetClassname() != "trigger_script" )
        {
            g_Game.AlertMessage( at_console, "[Twin gonarch] missing trigger script as activator!\n" );
            int[]i;i[1]; // When Exception addon
        }

        if( __ControllerCount__ == 0 )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( "ASTwinGonarch::ASTwinGonarchMortar", "tmortar" );
            g_CustomEntityFuncs.RegisterCustomEntity( "ASTwinGonarch::ASTwinGonarch", "tcontroller" );
        }

        string gonarchName = string( triggerScript.pev.netname );

        if( gonarchName.IsEmpty() )
        {
            g_Game.AlertMessage( at_console, "[Twin gonarch] missing \"netname\" (bigGonarch targetname) in trigger_script\n" );
            int[]i;i[1]; // When Exception addon
        }

        CBaseEntity@ gonarch = g_EntityFuncs.FindEntityByTargetname( null, gonarchName );

        if( gonarch is null )
        {
            g_Game.AlertMessage( at_console, "[Twin gonarch] Could not find big Gonarch named \"" + gonarchName + "\"\n" );
            int[]i;i[1]; // When Exception addon
        }

        g_EntityFuncs.Create( "tcontroller", g_vecZero, g_vecZero, false, gonarch.edict() );

        triggerScript.pev.flags |= FL_KILLME;
    }
}
