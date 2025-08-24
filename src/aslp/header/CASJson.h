// Contenido de CASJson.h

#pragma once
#include <vector>
#include <cstdio> 
#include "CASBaseObject.h"
namespace std { using ::_snprintf; }
#include <nlohmann/json.hpp>

typedef CString jsonKey_t;
using json = nlohmann::json;

enum CASJsonType
{
    OBJECT_VALUE,
    ARRAY_VALUE,
    BOOLEAN_VALUE,
    STRING_VALUE,
    NUMBER_VALUE,
    REAL_VALUE,
    NULL_VALUE
};

class CASJson : public CASBaseGCObject
{
public:
    static CASJson* Factory();
    static CASJson* Factory(const json& js);

    CASJson& operator=(bool other);
    CASJson& operator=(asINT64 other);
    CASJson& operator=(double other);
    CASJson& operator=(const CString& other);
    CASJson& operator=(const CScriptArray& other);
    CASJson& operator=(const CASJson& other);

    void Set(const jsonKey_t& key, bool value);
    void Set(const jsonKey_t& key, asINT64 value);
    void Set(const jsonKey_t& key, double value);
    void Set(const jsonKey_t& key, const CString& value);
    void Set(const jsonKey_t& key, const CScriptArray& value);

    bool Get(const jsonKey_t& key, bool& value) const;
    bool Get(const jsonKey_t& key, asINT64& value) const;
    bool Get(const jsonKey_t& key, double& value) const;
    bool Get(const jsonKey_t& key, CString& value) const;
    bool Get(const jsonKey_t& key, CScriptArray& value) const;

    bool GetBool() const;
    CString& GetString() const;
    int GetNumber() const;
    double GetReal() const;
    CScriptArray* GetArray() const;

    CASJson* opIndex(const jsonKey_t& key);
    const CASJson* opIndex_const(const jsonKey_t& key) const;

    bool Exists(const jsonKey_t& key) const;
    bool IsEmpty() const;
    asUINT GetSize() const;
    void Clear();
    CASJsonType Type() const;

    json* js_info = nullptr;

private:
    CASJson();
    ~CASJson();

    asIScriptEngine* engine;
    asITypeInfo* m_pJsonInfo;
    asITypeInfo* m_pArrJsonInfo;
};