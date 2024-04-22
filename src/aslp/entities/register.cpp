#include <extdll.h>
#include <meta_api.h>
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

std::vector<hook_t*> g_hooks;
bool g_HookedFlag = false;

void NewServerActivate(edict_t* pEdictList, int edictCount, int clientMax)
{
	if (!g_HookedFlag)
	{
		CPlayer::Register();
		CSentry::Register();
		CApache::Register();
		CBloater::Register();
		CTurret::Register();
		COsprey::Register();

		g_HookedFlag = true;
		SET_META_RESULT(META_RES::MRES_HANDLED);
	}
	else
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
	}
}

void VtableUnhook()
{
	for (auto iter = g_hooks.begin(); iter != g_hooks.end(); iter++)
	{
		if (*iter)
		{
			gpMetaUtilFuncs->pfnUnHook(*iter);
			*iter = nullptr;
		}
	}
	g_hooks.clear();
}