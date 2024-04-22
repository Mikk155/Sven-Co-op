#include <extdll.h>
#include <dllapi.h>
#include <meta_api.h>

#include <cl_entity.h>
#include <entity_state.h>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"

physent_t* SC_SERVER_DECL CASPlayerMove__GetPhysEntByIndex(playermove_t* pthis, SC_SERVER_DUMMYARG int index)
{
	return &pthis->physents[index];
}

void SC_SERVER_DECL CASPlayerMove__SetPhysEntByIndex(playermove_t* pthis, SC_SERVER_DUMMYARG physent_t* pPhyEnt, int oldindex)
{
	pthis->physents[oldindex] = *pPhyEnt;
}

void SC_SERVER_DECL CASEntityFuncs__IterateEntities(void* pThis, SC_SERVER_DUMMYARG aslScriptFunction* aslfn)
{
	/*
	std::function<void(aslScriptFunction*)> callback = [=](aslScriptFunction* AsFunction)
	{
		edict_t* pEdict = g_engfuncs.pfnPEntityOfEntIndex(1);

		for (int i = 1; i < gpGlobals->maxEntities; i++, pEdict++)
		{
			if (!pEdict->pvPrivateData || pEdict->free)
				continue;

			if (ASEXT_CallCASBaseCallable && (*ASEXT_CallCASBaseCallable))
			{
				CASFunction* pF = ASEXT_CreateCASFunction(AsFunction, ASEXT_GetServerManager()->curModule, 1);

				(*ASEXT_CallCASBaseCallable)(pF, 0, pEdict->pvPrivateData, i);

				long long nanosegundos = static_cast<long long>(1);
				std::this_thread::sleep_for(std::chrono::nanoseconds(nanosegundos));
			}
		}
	};


	std::thread([=]()
	{
		callback(aslfn);
	}).detach();
	*/
}

void RegisterAngelScriptMethods()
{
	ASEXT_RegisterDocInitCallback([](CASDocumentation* pASDoc) 
	{
			/* TraceInfo */
			ASEXT_RegisterObjectType(pASDoc, "Entidad traceattack info", "TraceInfo", 0, asOBJ_REF | asOBJ_NOCOUNT);
			ASEXT_RegisterObjectProperty(pASDoc, "", "TraceInfo", "CBaseEntity@ pVictim", offsetof(traceinfo_t, pVictim));
			ASEXT_RegisterObjectProperty(pASDoc, "", "TraceInfo", "CBaseEntity@ pInflictor", offsetof(traceinfo_t, pInflictor));
			ASEXT_RegisterObjectProperty(pASDoc, "", "TraceInfo", "float flDamage", offsetof(traceinfo_t, flDamage));
			ASEXT_RegisterObjectProperty(pASDoc, "", "TraceInfo", "Vector vecDir", offsetof(traceinfo_t, vecDir));
			ASEXT_RegisterObjectProperty(pASDoc, "", "TraceInfo", "TraceResult ptr", offsetof(traceinfo_t, ptr));
			ASEXT_RegisterObjectProperty(pASDoc, "", "TraceInfo", "int bitsDamageType", offsetof(traceinfo_t, bitsDamageType));

			/* HealthInfo */
			ASEXT_RegisterObjectType(pASDoc, "Entidad takehealth info", "HealthInfo", 0, asOBJ_REF | asOBJ_NOCOUNT);
			ASEXT_RegisterObjectProperty(pASDoc, "", "HealthInfo", "CBaseEntity@ pEntity", offsetof(healthinfo_t, pEntity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "HealthInfo", "float flHealth", offsetof(healthinfo_t, flHealth));
			ASEXT_RegisterObjectProperty(pASDoc, "", "HealthInfo", "int bitsDamageType", offsetof(healthinfo_t, bitsDamageType));
			ASEXT_RegisterObjectProperty(pASDoc, "", "HealthInfo", "int health_cap", offsetof(healthinfo_t, health_cap));

			/* entity_state_t */
			ASEXT_RegisterObjectType(pASDoc, "Estados de la entidad que se transmiten al jugador", "entity_state_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int entityType", offsetof(entity_state_t, entityType));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int number", offsetof(entity_state_t, number));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float msg_time", offsetof(entity_state_t, msg_time));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int messagenum", offsetof(entity_state_t, messagenum));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector origin", offsetof(entity_state_t, origin));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector angles", offsetof(entity_state_t, angles));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int modelindex", offsetof(entity_state_t, modelindex));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int sequence", offsetof(entity_state_t, sequence));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float frame", offsetof(entity_state_t, frame));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int colormap", offsetof(entity_state_t, colormap));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int16 skin", offsetof(entity_state_t, skin));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int16 solid", offsetof(entity_state_t, solid));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int effects", offsetof(entity_state_t, effects));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float scale", offsetof(entity_state_t, scale));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int8 eflags", offsetof(entity_state_t, eflags));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int rendermode", offsetof(entity_state_t, rendermode));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int renderamt", offsetof(entity_state_t, renderamt));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "RGBA rendercolor", offsetof(entity_state_t, rendercolor));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int r", offsetof(entity_state_t, rendercolor.r));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int g", offsetof(entity_state_t, rendercolor.g));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int b", offsetof(entity_state_t, rendercolor.b));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int renderfx", offsetof(entity_state_t, renderfx));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int movetype", offsetof(entity_state_t, movetype));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float animtime", offsetof(entity_state_t, animtime));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float framerate", offsetof(entity_state_t, framerate));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int body", offsetof(entity_state_t, body));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector velocity", offsetof(entity_state_t, velocity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector mins", offsetof(entity_state_t, mins));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector maxs", offsetof(entity_state_t, maxs));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int aiment", offsetof(entity_state_t, aiment));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int owner", offsetof(entity_state_t, owner));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float friction", offsetof(entity_state_t, friction));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float gravity", offsetof(entity_state_t, gravity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int team", offsetof(entity_state_t, team));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int playerclass", offsetof(entity_state_t, playerclass));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int health", offsetof(entity_state_t, health));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int spectator", offsetof(entity_state_t, spectator));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int weaponmodel", offsetof(entity_state_t, weaponmodel));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int gaitsequence", offsetof(entity_state_t, gaitsequence));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector basevelocity", offsetof(entity_state_t, basevelocity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int usehull", offsetof(entity_state_t, usehull));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int oldbuttons", offsetof(entity_state_t, oldbuttons));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int onground", offsetof(entity_state_t, onground));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iStepLeft", offsetof(entity_state_t, iStepLeft));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float flFallVelocity", offsetof(entity_state_t, flFallVelocity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fov", offsetof(entity_state_t, fov));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int weaponanim", offsetof(entity_state_t, weaponanim));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser1", offsetof(entity_state_t, iuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser2", offsetof(entity_state_t, iuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser3", offsetof(entity_state_t, iuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser4", offsetof(entity_state_t, iuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser1", offsetof(entity_state_t, fuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser2", offsetof(entity_state_t, fuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser3", offsetof(entity_state_t, fuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser4", offsetof(entity_state_t, fuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser1", offsetof(entity_state_t, vuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser2", offsetof(entity_state_t, vuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser3", offsetof(entity_state_t, vuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser4", offsetof(entity_state_t, vuser4));

			/* physent_t */
			ASEXT_RegisterObjectType(pASDoc, "Informacion de las fisicas", "physent_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
			//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "array<char>@ name", offsetof(physent_t, name));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int player", offsetof(physent_t, player));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector origin", offsetof(physent_t, origin));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "model_t@ model", offsetof(physent_t, model));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "model_t@ studiomodel", offsetof(physent_t, studiomodel));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector mins", offsetof(physent_t, mins));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector maxs", offsetof(physent_t, maxs));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int info", offsetof(physent_t, info));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector angles", offsetof(physent_t, angles));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int solid", offsetof(physent_t, solid));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int skin", offsetof(physent_t, skin));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int rendermode", offsetof(physent_t, rendermode));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float frame", offsetof(physent_t, frame));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int sequence", offsetof(physent_t, sequence));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int controller", offsetof(physent_t, controller));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int blending", offsetof(physent_t, blending));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int movetype", offsetof(physent_t, movetype));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int takedamage", offsetof(physent_t, takedamage));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int blooddecal", offsetof(physent_t, blooddecal));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int team", offsetof(physent_t, team));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int classnumber", offsetof(physent_t, classnumber));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser1", offsetof(physent_t, iuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser2", offsetof(physent_t, iuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser3", offsetof(physent_t, iuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser4", offsetof(physent_t, iuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser1", offsetof(physent_t, fuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser2", offsetof(physent_t, fuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser3", offsetof(physent_t, fuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser4", offsetof(physent_t, fuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser1", offsetof(physent_t, vuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser2", offsetof(physent_t, vuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser3", offsetof(physent_t, vuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser4", offsetof(physent_t, vuser4));

			/* playermove_t */
			ASEXT_RegisterObjectType(pASDoc, "Estados de la entidad que se transmiten al jugador", "playermove_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int player_index", offsetof(playermove_t, player_index));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int server", offsetof(playermove_t, server));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int multiplayer", offsetof(playermove_t, multiplayer));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float time", offsetof(playermove_t, time));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float frametime", offsetof(playermove_t, frametime));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector forward", offsetof(playermove_t, forward));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector right", offsetof(playermove_t, right));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector up", offsetof(playermove_t, up));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector origin", offsetof(playermove_t, origin));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector angles", offsetof(playermove_t, angles));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector oldangles", offsetof(playermove_t, oldangles));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector velocity", offsetof(playermove_t, velocity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector movedir", offsetof(playermove_t, movedir));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector basevelocity", offsetof(playermove_t, basevelocity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector view_ofs", offsetof(playermove_t, view_ofs));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flDuckTime", offsetof(playermove_t, flDuckTime));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int bInDuck", offsetof(playermove_t, bInDuck));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int flTimeStepSound", offsetof(playermove_t, flTimeStepSound));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iStepLeft", offsetof(playermove_t, iStepLeft));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flFallVelocity", offsetof(playermove_t, flFallVelocity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector punchangle", offsetof(playermove_t, punchangle));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flSwimTime", offsetof(playermove_t, flSwimTime));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flNextPrimaryAttack", offsetof(playermove_t, flNextPrimaryAttack));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int effects", offsetof(playermove_t, effects));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int flags", offsetof(playermove_t, flags));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int usehull", offsetof(playermove_t, usehull));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float gravity", offsetof(playermove_t, gravity));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float friction", offsetof(playermove_t, friction));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int oldbuttons", offsetof(playermove_t, oldbuttons));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float waterjumptime", offsetof(playermove_t, waterjumptime));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int dead", offsetof(playermove_t, dead));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int deadflag", offsetof(playermove_t, deadflag));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int spectator", offsetof(playermove_t, spectator));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int movetype", offsetof(playermove_t, movetype));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int onground", offsetof(playermove_t, onground));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int waterlevel", offsetof(playermove_t, waterlevel));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int watertype", offsetof(playermove_t, watertype));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int oldwaterlevel", offsetof(playermove_t, oldwaterlevel));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "array<char>@ sztexturename", offsetof(playermove_t, sztexturename));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "char chtexturetype", offsetof(playermove_t, chtexturetype));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float maxspeed", offsetof(playermove_t, maxspeed));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float clientmaxspeed", offsetof(playermove_t, clientmaxspeed));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser1", offsetof(playermove_t, iuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser2", offsetof(playermove_t, iuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser3", offsetof(playermove_t, iuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser4", offsetof(playermove_t, iuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser1", offsetof(playermove_t, fuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser2", offsetof(playermove_t, fuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser3", offsetof(playermove_t, fuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser4", offsetof(playermove_t, fuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser1", offsetof(playermove_t, vuser1));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser2", offsetof(playermove_t, vuser2));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser3", offsetof(playermove_t, vuser3));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser4", offsetof(playermove_t, vuser4));
			ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int numphysent", offsetof(playermove_t, numphysent));
			ASEXT_RegisterObjectMethod(pASDoc, "", "playermove_t", "physent_t@ GetPhysEntByIndex(int index)", (void*)CASPlayerMove__GetPhysEntByIndex, asCALL_THISCALL);
			ASEXT_RegisterObjectMethod(pASDoc, "", "playermove_t", "void SetPhysEntByIndex(physent_t@ pPhyEnt, int newindex)", (void*)CASPlayerMove__SetPhysEntByIndex, asCALL_THISCALL);
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "array<physent_t@>@ physents", offsetof(playermove_t, physents));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int nummoveent", offsetof(playermove_t, nummoveent));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int numvisent", offsetof(playermove_t, numvisent));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int numtouch", offsetof(playermove_t, numtouch));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "physent_t@ moveents", offsetof(playermove_t, moveents));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "physent_t@ visents", offsetof(playermove_t, visents));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "physent_t@ touchindex", offsetof(playermove_t, touchindex));
			//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "string physinfo", offsetof(playermove_t, physinfo));

				/*META_RES*/
			ASEXT_RegisterEnum(pASDoc, "Prioridad del plugin", "META_RES", 0);
			ASEXT_RegisterEnumValue(pASDoc, "", "META_RES", "MRES_UNSET", 0);
			ASEXT_RegisterEnumValue(pASDoc, "", "META_RES", "MRES_IGNORED", 1);
			ASEXT_RegisterEnumValue(pASDoc, "", "META_RES", "MRES_HANDLED", 2);
			ASEXT_RegisterEnumValue(pASDoc, "", "META_RES", "MRES_OVERRIDE", 3);
			ASEXT_RegisterEnumValue(pASDoc, "", "META_RES", "MRES_SUPERCEDE", 4);

			ASEXT_RegisterFuncDef(pASDoc, "Callback", "void IterateEntities(CBaseEntity@ pEntity, int iteration_num)");
			ASEXT_RegisterObjectMethod(pASDoc, "", "CEntityFuncs", "void IterateEntities( IterateEntities @callback )", (void*)CASEntityFuncs__IterateEntities, asCALL_THISCALL);
	});
}