#pragma once

template <typename T>
class CBaseDelayTemplate : public CBaseEntityTemplate<T>
{
public:
	void SC_SERVER_DECL DelayThink(void* pThis SC_SERVER_DUMMYARG_NOCOMMA);
};