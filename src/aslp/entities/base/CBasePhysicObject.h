#pragma once

template <typename T>
class CBasePhysicObjectTemplate : public  CBaseAnimatingTemplate<T>
{
public:
	void SC_SERVER_DECL WorldInit(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL Materialize(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL TouchedWorld(T* pThis SC_SERVER_DUMMYARG_NOCOMMA, bool touch);
	void SC_SERVER_DECL Kill(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL GetBounceSound(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL FallInit(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
};
