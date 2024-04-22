#pragma once

#include "../angelscript/angelscript.h"

void RegisterAngelScriptCvar();
void RegisterAngelScriptMethods();
void RegisterAngelScriptHooks();

void VtableUnhook();
void NewServerActivate(edict_t* pEdictList, int edictCount, int clientMax);

extern cvar_t init_ignore_tracer_player;
extern cvar_t* mp_ignore_tracer_player;
extern cvar_t* mp_allowmonsterinfo;