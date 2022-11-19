/*
INSTALL:

#include "mikk/game_debug"

void MapInit()
{
	RegisterGameDebugMessager();
}
*/
void RegisterGameDebugMessager(){
g_CustomEntityFuncs.RegisterCustomEntity("game_debug","game_debug");}
class game_debug:ScriptBaseEntity{
void Use(CBaseEntity@ pActivator,CBaseEntity@ pCaller,USE_TYPE useType,float value){
UTILS::Debug(string(self.pev.message)+"\n");}}