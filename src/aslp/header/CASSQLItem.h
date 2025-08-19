#pragma once
#include <string>
#include "CASBaseObject.h"

class CBinaryStringBuilder;
class CASSQLItem : public CASBaseGCObject{
public:
    //Only for c++ not expose to as
    CASSQLItem();
    ~CASSQLItem();
    static CASSQLItem* Factory();
    static CASSQLItem* ParamFactory(char* str);
    //Angel Scripts
    void  Get(CString* str);
    int64 GetInt64();
    int32 GetInt();
    uint64 GetUInt64();
    uint32 GetUInt();
    double GetReal();
    CBinaryStringBuilder* GetBlob();
    bool IsNull();
private:
    void SetData(char* str);

    asITypeInfo* m_pBlobInfo;
    std::string m_szData;

    bool m_bIsNull;
};