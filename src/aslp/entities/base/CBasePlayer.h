#pragma once

template <typename T>
class CBasePlayerTemplate : public CBaseMonsterTemplate<T>
{
public:
	void SC_SERVER_DECL SpecialSpawn(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL Jump(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL Duck(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL PreThink(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL PostThink(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL EnteredObserver(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL LeftObserver(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	bool SC_SERVER_DECL IsObserver(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	bool SC_SERVER_DECL IsConnected(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL UpdateClientData(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ImpulseCommands(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL IsValidInfoEntity(T* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther);
	void SC_SERVER_DECL LevelEnd(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL VoteStarted(T* pThis, SC_SERVER_DUMMYARG int votetype);
	bool SC_SERVER_DECL CanStartNextVote(T* pThis, SC_SERVER_DUMMYARG int votetype);
	void SC_SERVER_DECL Vote(T* pThis, SC_SERVER_DUMMYARG int votetype, char* decription);
	bool SC_SERVER_DECL HasVoted(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ResetVote(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void* SC_SERVER_DECL LastVoteInput(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL InitVote(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL TimeToStartNextVote(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ResetView(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL GetLogFrequency(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL LogPlayerStats(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
};