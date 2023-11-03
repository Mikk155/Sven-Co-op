
void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

CCVar@ g_disabled;
CCVar@ g_cooldown;
CCVar@ g_stomp_mode;

enum STOMP_MODE {
	STOMP_OFF = 0,			// normal fall damage logic
	STOMP_SPLIT,			// split damage between all players involved
	STOMP_SPLIT_BOTTOM,		// split damage across the players that got stomped on
	STOMP_DUPLICATE,		// apply full damage to each player
	STOMP_MODES
}

class DoorState {
	EHandle ent;
	int lastToggleState = 0;
	int blockCounter = 0;
	float lastToggleTime = 0;
	float originalDamage = 0;
}

array<DoorState> g_rotating_doors;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "w00tguy" );
	g_Module.ScriptInfo.SetContactInfo( "w00tguy123 - forums.svencoop.com" );
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerUse, @PlayerUse );
	g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	
	@g_disabled = CCVar("disabled", 0, "disables AntiBlock", ConCommandFlag::AdminOnly);
	@g_cooldown = CCVar("cooldown", 0.6f, "Time before a swapped player can be swapped with again", ConCommandFlag::AdminOnly);
	@g_stomp_mode = CCVar("stomp", STOMP_SPLIT, "Stomp mode (0=off, 1=split, 2=bottom only, 3=duplicate)", ConCommandFlag::AdminOnly);
	
	findRotatingDoors();
	
	g_Scheduler.SetInterval("doorLoop", 0.1f, -1); // odd number to prevent toggle state getting in sync with door thinking
}

void MapActivate() {
	findRotatingDoors();
}

void findRotatingDoors() {
	g_rotating_doors.resize(0);
	
	CBaseEntity@ ent = null;
	do {
		@ent = g_EntityFuncs.FindEntityByClassname(ent, "func_door_rotating"); 
		if (ent !is null)
		{
			if (ent.pev.dmg <= 10) {
				DoorState doorState;
				doorState.originalDamage = ent.pev.dmg;
				
				doorState.ent = EHandle(ent);
				g_rotating_doors.insertLast(doorState);
			}
		}
	} while (ent !is null);
}

void doorLoop() {
	for (uint i = 0; i < g_rotating_doors.length(); i++) {
		DoorState@ state = g_rotating_doors[i];
		CBaseDoor@ ent = cast<CBaseDoor@>(state.ent.GetEntity());
		if (ent is null) {
			continue;
		}
		
		if (ent.m_toggle_state != state.lastToggleState) {
			float delay = g_Engine.time - state.lastToggleTime;
			
			if (delay < 1.0f) {
				state.blockCounter++;
				
				if (state.blockCounter >= 40) {
					ent.pev.dmg = 1000;
				}
				else if (state.blockCounter >= 32) {
					ent.pev.dmg = 500;
				}
				else if (state.blockCounter >= 24) {
					ent.pev.dmg = 100;
				}
				else if (state.blockCounter >= 16) {
					ent.pev.dmg = 40; // any higher than this and there's a chance to gib
				}
				else if (state.blockCounter >= 8) {
					ent.pev.dmg = 10;
				}
				
				// blocker could be also be the opener, which the door won't always do damage to when blocked
				// openers can do this by lodging themselves into the hinge of the door and looking in a certain direction.
				if (state.blockCounter >= 32) {
					CBaseEntity@ activator = ent.m_hActivator;
					if (ent !is null) {
						activator.TakeDamage( ent.pev, ent.pev, ent.pev.dmg, DMG_CRUSH);
					}
				}
				
			} else {
				state.blockCounter = 0;
				ent.pev.dmg = state.originalDamage;
			}
			
			state.lastToggleState = ent.m_toggle_state;
			state.lastToggleTime = g_Engine.time;
		}	
	}
}

Vector getSwapDir(CBasePlayer@ plr) {
	Vector angles = plr.pev.v_angle;
	
	// snap to 90 degree angles
	angles.y = (int((angles.y + 180 + 45) / 90) * 90) - 180;
	angles.x = (int((angles.x + 180 + 45) / 90) * 90) - 180;
	
	// vertical unblocking has priority
	if (angles.x != 0) {
		angles.y = 0; 
	} else {
		angles.x = 0;
	}
	
	Math.MakeVectors( angles );
	
	return g_Engine.v_forward;
}

CBaseEntity@ TraceLook(CBasePlayer@ plr, Vector swapDir, float dist=1)
{
	Vector vecSrc = plr.pev.origin;	
	
	plr.pev.solid = SOLID_NOT;
	
	TraceResult tr;
	Vector dir = swapDir * dist;
	HULL_NUMBER hullType = plr.pev.flags & FL_DUCKING != 0 ? head_hull : human_hull;
	g_Utility.TraceHull( vecSrc, vecSrc + dir, dont_ignore_monsters, hullType, null, tr );
	
	// try again in case the blocker is on a slope or stair
	if (swapDir.z == 0 and g_EntityFuncs.Instance( tr.pHit ) !is null and g_EntityFuncs.Instance( tr.pHit ).IsBSPModel()) {
		Vector verticalDir = Vector(0,0,36);
		if (plr.pev.flags & FL_ONGROUND == 0) {
			// probably on the ceiling, so try starting the trace lower instead (e.g. negative gravity or ladder)
			verticalDir.z = -36; 
		}
		
		g_Utility.TraceHull( vecSrc, vecSrc + verticalDir, dont_ignore_monsters, hullType, null, tr );
		if (g_EntityFuncs.Instance( tr.pHit ) is null or g_EntityFuncs.Instance( tr.pHit ).IsBSPModel()) {
			g_Utility.TraceHull( tr.vecEndPos, tr.vecEndPos + dir, dont_ignore_monsters, hullType, null, tr );
		}
	}
	
	plr.pev.solid = SOLID_SLIDEBOX;

	return g_EntityFuncs.Instance( tr.pHit );
}

string format_float(float f)
{
	uint decimal = uint(((f - int(f)) * 10)) % 10;
	return "" + int(f) + "." + decimal;
}

bool isSwappableMonster(CBasePlayer@ plr, CBaseEntity@ target) {	
	if (!target.IsMonster() or !target.IsAlive()) {
		return false;
	}
	
	CBaseMonster@ mon = cast<CBaseMonster@>(target);

	if (plr.IRelationship(mon) > R_NO) {
		g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCENTER, "Swap target not friendly\n");
		return false;
	}
	
	Vector plrSz = plr.pev.absmax - plr.pev.absmin;
	Vector monSz = mon.pev.absmax - mon.pev.absmin;
	
	float epsilon = 0.01f; // bounding boxes are sometimes off by a tiny fraction
	if (monSz.x-epsilon > plrSz.x || monSz.y-epsilon > plrSz.y || monSz.z-epsilon > plrSz.z) {
		if (plr.pev.flags & FL_DUCKING != 0) {
			g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCENTER, "Swap target too large or can't duck\n");
		} else {
			g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCENTER, "Swap target too large\n");
		}
		
		return false;
	}
	
	if (mon.m_hCine.GetEntity() !is null) {
		g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCENTER, "Swap target is busy\n");
		return false;
	}
	
	return true;
}

array<CBaseEntity@> getAntiblockTargets(CBasePlayer@ plr, Vector swapDir, bool playersNotMonsters) {
	array<CBaseEntity@> targets;

	for (int i = 0; i < 4; i++) {
		CBaseEntity@ target = TraceLook(plr, swapDir);
		
		if (target is null) {
			break;
		}
		
		if (playersNotMonsters and !target.IsPlayer()) {
			continue;
		}
		
		if (!playersNotMonsters and (target.IsPlayer() or !isSwappableMonster(plr, target))) {
			continue;
		}
		
		targets.insertLast(target);
		target.pev.solid = SOLID_NOT;
	}
	
	for (uint i = 0; i < targets.length(); i++) {
		targets[i].pev.solid = SOLID_SLIDEBOX;
	}
	
	return targets;
}

bool swapCooledDown(CBasePlayer@ swapper, float maxSwapTime) {
	if (g_Engine.time - maxSwapTime < g_cooldown.GetFloat()) {
		if (g_cooldown.GetFloat() > 1) {
			float waitTime = (maxSwapTime + g_cooldown.GetFloat()) - g_Engine.time;
			g_PlayerFuncs.PrintKeyBindingString(swapper, "Wait " + format_float(waitTime) + " seconds\n");
		}
		return false;
	}
	return true;
}

HookReturnCode PlayerUse( CBasePlayer@ plr, uint& out uiFlags )
{	
	if (plr.m_afButtonPressed & (IN_RELOAD | IN_USE) == 0 or g_disabled.GetBool()) {
		return HOOK_CONTINUE;
	}
	bool wantsPlayerSwap = plr.m_afButtonPressed & IN_USE != 0;
	
	Vector swapDir = getSwapDir(plr);
	array<CBaseEntity@> targets = getAntiblockTargets(plr, swapDir, wantsPlayerSwap);
	if (targets.length() == 0)
		return HOOK_CONTINUE;
		
	CBaseEntity@ target = targets[0];
	
	if (target !is null and plr.pev.flags & FL_ONTRAIN == 0) {	
		bool swappedMultiple = false;
		
		CustomKeyvalues@ pCustom = plr.GetCustomKeyvalues();
		CustomKeyvalue pValue( pCustom.GetKeyvalue( "$f_lastAntiBlock" ) );
		
		if (targets.length() > 1) {
			bool allSafeSwaps = true;
			
			float mostRecentSwapTime = pValue.GetFloat();
			for (uint i = 0; i < targets.length(); i++) {
				CustomKeyvalues@ tCustom = targets[i].GetCustomKeyvalues();
				CustomKeyvalue tValue( tCustom.GetKeyvalue( "$f_lastAntiBlock" ) );
				float time = tValue.GetFloat();
				if (time > mostRecentSwapTime) {
					mostRecentSwapTime = time;
				}
			}
			
			if (!swapCooledDown(plr, mostRecentSwapTime)) {
				return HOOK_CONTINUE;
			}
			
			array<Vector> newTargetPos;
			
			float maxDist = -999;
			plr.pev.solid = SOLID_NOT;
			for (uint i = 0; i < targets.length(); i++) {
				targets[i].pev.solid = SOLID_NOT;
			}
			
			for (uint i = 0; i < targets.length(); i++) {
				Vector vecSrc = targets[i].pev.origin;
				
				newTargetPos.insertLast(targets[i].pev.origin);
				if (swapDir.z != 0) {
					newTargetPos[i].z = plr.pev.origin.z;
				} else if (swapDir.y != 0) {
					newTargetPos[i].y = plr.pev.origin.y;
				} else if (swapDir.x != 0) {
					newTargetPos[i].x = plr.pev.origin.x;
				}
				
				float dist = (newTargetPos[i] - targets[i].pev.origin).Length();
				if (dist > maxDist) {
					maxDist = dist;
				}
					
				TraceResult tr;
				
				HULL_NUMBER spaceNeeded = targets[i].IsPlayer() or plr.pev.flags & FL_DUCKING != 0 ? head_hull : human_hull;
				g_Utility.TraceHull( vecSrc, newTargetPos[i], dont_ignore_monsters, spaceNeeded, targets[i].edict(), tr );
				
				if (tr.flFraction < 1.0f) {
					allSafeSwaps = false;
					break;
				}
			}
			
			if (allSafeSwaps) {
				TraceResult tr;
				g_Utility.TraceHull( plr.pev.origin, plr.pev.origin + swapDir*maxDist, dont_ignore_monsters, head_hull, null, tr );
				allSafeSwaps = tr.flFraction >= 1.0f;
			}
			
			if (allSafeSwaps) {				
				for (uint i = 0; i < targets.length(); i++) {
					targets[i].pev.origin = newTargetPos[i];
					if (targets[i].IsPlayer()) {
						targets[i].pev.flDuckTime = 26;
						targets[i].pev.flags |= FL_DUCKING;
						targets[i].pev.view_ofs = Vector(0,0,12);
					} else {
						// monster origins are on the floor and player origins aren't
						float zDiff = plr.pev.flags & FL_DUCKING != 0 ? 18 : 36;
						plr.pev.origin.z += zDiff;
						target.pev.origin.z -= zDiff;
					}
					
					CustomKeyvalues@ t2Custom = targets[i].GetCustomKeyvalues();
					t2Custom.SetKeyvalue( "$f_lastAntiBlock", g_Engine.time );
				}
				
				plr.pev.origin = plr.pev.origin + swapDir*maxDist;
				plr.pev.flDuckTime = 26;
				plr.pev.flags |= FL_DUCKING;
				plr.pev.view_ofs = Vector(0,0,12);
				
				swappedMultiple = true;
			}
			
			plr.pev.solid = SOLID_SLIDEBOX;
			for (uint i = 0; i < targets.length(); i++) {
				targets[i].pev.solid = SOLID_SLIDEBOX;
			}
		}
	
		if (!swappedMultiple) {
			CustomKeyvalues@ tCustom = target.GetCustomKeyvalues();
			CustomKeyvalue tValue( tCustom.GetKeyvalue( "$f_lastAntiBlock" ) );
			
			// don't let blockers immediately swap back to where they were
			if (!swapCooledDown(plr, Math.max(pValue.GetFloat(), tValue.GetFloat()))) {
				return HOOK_CONTINUE;
			}
			
			Vector srcOri = plr.pev.origin;
			bool srcDucking = plr.pev.flags & FL_DUCKING != 0;
			bool dstDucking = target.pev.flags & FL_DUCKING != 0 || !target.IsPlayer();
			
			plr.pev.origin = target.pev.origin;
			target.pev.origin = srcOri;
			
			if (!target.IsPlayer()) {
				float zDiff = srcDucking ? 18 : 36;
				plr.pev.origin.z += zDiff;
				target.pev.origin.z -= zDiff;
			}
			
			if (dstDucking) {
				plr.pev.flDuckTime = 26;
				plr.pev.flags |= FL_DUCKING;
				plr.pev.view_ofs = Vector(0,0,12);
				
				// prevent gibbing on elevators when swapper is crouching and swappee is not
				CBaseEntity@ dstElev = g_EntityFuncs.Instance( target.pev.groundentity );
				if (!srcDucking && dstElev !is null && dstElev.pev.velocity.z > 0) {
					plr.pev.origin.z += 18; 
				}
			}
			if (srcDucking) {
				target.pev.flDuckTime = 26;
				target.pev.flags |= FL_DUCKING;
				target.pev.view_ofs = Vector(0,0,12);
				
				CBaseEntity@ srcElev = g_EntityFuncs.Instance( plr.pev.groundentity );
				if (!dstDucking && srcElev !is null && srcElev.pev.velocity.z > 0) {
					target.pev.origin.z += 18; 
				}
			}
			
			pCustom.SetKeyvalue( "$f_lastAntiBlock", g_Engine.time );
			tCustom.SetKeyvalue( "$f_lastAntiBlock", g_Engine.time );
		}
		
		g_SoundSystem.PlaySound( plr.edict(), CHAN_BODY, "weapons/xbow_hitbod2.wav", 0.7f, 1.0f, 0, 130 + Math.RandomLong(0, 10));
		
		uiFlags |= PlrHook_SkipUse;
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerTakeDamage(DamageInfo@ info)
{
	CBasePlayer@ plr = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pVictim.pev));
	entvars_t@ pevInflictor = info.pInflictor !is null ? info.pInflictor.pev : null;
	entvars_t@ pevAttacker = info.pAttacker !is null ? info.pAttacker.pev : null;
	
	int stomp_mode = g_stomp_mode.GetInt();
	bool stomping_enabled = stomp_mode > STOMP_OFF && stomp_mode < STOMP_MODES;

	if (stomping_enabled && info.bitsDamageType & DMG_FALL != 0) {		
		array<CBaseEntity@> ent_hits;
		array<int> ent_hit_old_solid;
		
		ent_hits.insertLast(plr);
		ent_hit_old_solid.insertLast(plr.pev.solid);
		
		int splitCount = 1;
		int infiniteLoopSafety = 1000;
		for (int i = 0; i < infiniteLoopSafety; i++) {
			TraceResult tr;
			Vector dir = Vector(0,0,-1);
			HULL_NUMBER hullType = plr.pev.flags & FL_DUCKING != 0 ? head_hull : human_hull;
			g_Utility.TraceHull( plr.pev.origin, plr.pev.origin + dir, dont_ignore_monsters, hullType, plr.edict(), tr );
			
			CBaseEntity@ phit = g_EntityFuncs.Instance( tr.pHit );
			if (phit is null || phit.IsBSPModel())
				break;
		
			ent_hits.insertLast(phit);
			ent_hit_old_solid.insertLast(phit.pev.solid);
			
			if (phit.IsPlayer()) { // monsters take damage from stomping already, and that can't be bypassed(?)
				splitCount += 1;
			}
			
			if (splitCount >= 5) {
				break; // don't split damage across players that are stuck inside each other
			}
			
			if (i == infiniteLoopSafety-1) {
				println("WARNING: Infinite loop in AntiBlock plugin stomp logic. Tell w00tguy how that happened pls.");
			}
			
			phit.pev.solid = SOLID_NOT; // check for other ents in the same spot
		}
		
		if (stomp_mode == STOMP_SPLIT_BOTTOM) {
			splitCount -= 1;
		}
		
		if (splitCount > 0) {
			int dmgSplit = int(info.flDamage / float(splitCount));
			
			if (stomp_mode == STOMP_DUPLICATE) {
				dmgSplit = int(info.flDamage);
				//println("Applying " + info.flDamage + " damage to " + splitCount + " players");
			}
			else {
				//println("Splitting " + info.flDamage + " damage across " + splitCount + " players = " + dmgSplit);
			}
			
			for (uint i = 0; i < ent_hits.size(); i++) {
				ent_hits[i].pev.solid = ent_hit_old_solid[i];
				
				if (stomp_mode == STOMP_SPLIT_BOTTOM && i == 0) {
					continue; // first idx is always the stomper
				}
				
				if (ent_hits[i].IsPlayer() and (ent_hits[i].pev.flags & FL_GODMODE) == 0) {
					ent_hits[i].pev.dmg_take += dmgSplit;
					ent_hits[i].pev.health -= dmgSplit;
					if (ent_hits[i].pev.health <= 0) {
						ent_hits[i].Killed( pevAttacker, GIB_NORMAL );
					}
					if (i != 0) {
						// fall damage effect for victims (best guess)
						ent_hits[i].pev.punchangle.x += 4 + 12*(Math.min(100, dmgSplit) / 100.0f);
						g_PlayerFuncs.ScreenShake(ent_hits[i].pev.origin, 255.0f, 255.0f, 0.5f, 1.0f);
					}
				}
			}
			
			// bypass sven damage logic
			info.flDamage = 0;
		}
	}
	
	return HOOK_CONTINUE;
}


bool doCommand(CBasePlayer@ plr, const CCommand@ args)
{	
	if ( args.ArgC() > 0 )
	{
		if ( args[0] == ".antiblock" )
		{
			g_PlayerFuncs.SayText(plr, "AntiBlock version 3\n");
			
			if (g_disabled.GetBool()) {
				g_PlayerFuncs.SayText(plr, "    Disabled on this map\n");
				return true;
			}
			
			g_PlayerFuncs.SayText(plr, "    Cooldown = " + g_cooldown.GetFloat() + "\n");
			
			string stompMode = "" + g_stomp_mode.GetInt();
			
			switch(g_stomp_mode.GetInt()) {
				
				case STOMP_SPLIT: stompMode += " (split damage)"; break;
				case STOMP_SPLIT_BOTTOM: stompMode += " (bottom only)"; break;
				case STOMP_DUPLICATE: stompMode += " (duplicate damage)"; break;
				case STOMP_OFF:
				default:
					stompMode += " (disabled)";
			}
			
			g_PlayerFuncs.SayText(plr, "    Stomp mode = " + stompMode + "\n");
			
			return true;
		}
	}
	return false;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{	
	CBasePlayer@ plr = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if (doCommand(plr, args))
	{
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}

CClientCommand _antiblock("antiblock", "Anti-rush status", @consoleCmd );

void consoleCmd( const CCommand@ args )
{
	CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
	doCommand(plr, args);
}