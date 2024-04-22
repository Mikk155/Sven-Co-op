#pragma once
#define GetEntVarsVTable(var)var==nullptr?nullptr:ENT(var)->pvPrivateData
#define OFFSET_ENTVAR 4

inline edict_t* PrivateToEdict(void* PrivateData){
	if (PrivateData == nullptr)
		return nullptr;
	return (*((entvars_t**)((char*)PrivateData + OFFSET_ENTVAR)))->pContainingEntity;
};