#pragma once

template <typename T>
class CBasePickupObjectTemplate : public CBasePhysicObjectTemplate<T>
{
public:
	void SC_SERVER_DECL CanCollect(T* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther, int iCollectType);
	void SC_SERVER_DECL Collect(T* pThis, SC_SERVER_DUMMYARG int iCollectType);
	void SC_SERVER_DECL Collected(T* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther, int iCollectTyp);
	void SC_SERVER_DECL DefaultUse(T* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float value);
	void SC_SERVER_DECL Dropped(T* pThis SC_SERVER_DUMMYARG_NOCOMMA, CBasePlayerItem* pNewEntity);
	float SC_SERVER_DECL GetFadeDelay(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
};