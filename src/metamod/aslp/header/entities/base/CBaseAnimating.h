#pragma once

template <typename T>
class CBaseAnimatingTemplate : public CBaseDelayTemplate<T>
{
public:
	void SC_SERVER_DECL HandleAnimEvent(void* pThis SC_SERVER_DUMMYARG_NOCOMMA, MonsterEvent* pEvent);
};