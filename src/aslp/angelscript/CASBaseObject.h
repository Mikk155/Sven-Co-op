#pragma once
#include <extdll.h>

#include "asext_api.h"
#include "angelscriptlib.h"
class CASBaseRefObject {
public:
	virtual void AddRef();
    virtual void Release();
protected:
    size_t  refCount = 1;
};
class CASBaseGCObject : public CASBaseRefObject {
public:
    virtual void AddRef() override;
    virtual void Release() override;

    virtual void SetGCFlag();
    virtual bool GetGCFlag();
    virtual int GetRefCount();
    virtual void EnumReferences(asIScriptEngine* engine);
    virtual void ReleaseReferences(asIScriptEngine* engine);

    typedef struct GCRefObject_s {
        void* data;
        asITypeInfo* type;
        bool value;
    } GCRefObject;
};