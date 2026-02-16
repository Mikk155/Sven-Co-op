#pragma once
#define GetEntVarsVTable(var)var==nullptr?nullptr:ENT(var)->pvPrivateData

constexpr auto OFFSET_ENTVAR = 4;
constexpr edict_t* PrivateToEdict(void* PrivateData){
	if (PrivateData == nullptr)
		return nullptr;
	entvars_t* pev = *((entvars_t**)((char*)PrivateData + OFFSET_ENTVAR));
	if (pev == nullptr)
		return nullptr;
	return pev->pContainingEntity;
};