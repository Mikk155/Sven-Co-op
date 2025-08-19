#pragma once
#include <vector>
#include "CASBaseObject.h"
class CBinaryStringBuilder : public CASBaseGCObject
{
public:
    CBinaryStringBuilder();
    static CBinaryStringBuilder* Factory();
    static CBinaryStringBuilder* ParamFactory(CString* str);

    virtual void EnumReferences(asIScriptEngine* engine) override;
    virtual void ReleaseReferences(asIScriptEngine* engine) override;

    CString Get();
    void Set(CString* buffer);

    size_t GetReadPointer();
    void SetReadPointer(size_t pointer);

    void WriteInt(int value);
    void WriteLong(int64 value);
    void WriteFloat(float value);
    void WriteDouble(double value);
    void WriteVector(vec3_t value);
    void WriteString(CString* value);

    void WriteData(const char* value, size_t len);

    int ReadInt();
    int64 ReadLong();
    float ReadFloat();
    double ReadDouble();
    vec3_t ReadVector();
    CString ReadString();
    bool IsReadToEnd();

    size_t m_iReadPointer = 0;
    std::vector<unsigned char> m_szBuffer;
private:
    asITypeInfo* m_pStrInfo;
    asITypeInfo* m_pVectorInfo;
    std::vector<GCRefObject*> m_aryRef;
};