#include <extdll.h>
#include <pm_defs.h>
#include <entity_state.h>
#include <meta_api.h>

#include "aslp.h"
#include "asext_api.h"
#include "angelscriptlib.h"

#include "angelscript/json.hpp"

#include "sqlite/CASSQLItem.h"
#include "sqlite/CASSQLGrid.h"
#include "sqlite/CASSQLite.h"

#include "string/CASBinaryStringBuilder.h"

#include "Hooks/AddToFullPack.hpp"
#include "Hooks/PM_Move.hpp"

angelhook_t g_AngelHook;

/**
 * @brief The plugin's namespace
**/
#define NAMESPACE_ASLP "aslp"

/**
 * @brief Global name space
**/
#define NAMESPACE_NONE ""

uint32 SC_SERVER_DECL CASEngineFuncs_CRC32(void* pthis, SC_SERVER_DUMMYARG CString* szBuffer)
{
    CRC32_t crc;
    CRC32_INIT(&crc);
    CRC32_PROCESS_BUFFER(&crc, (void*)szBuffer->c_str(), szBuffer->length());
    return CRC32_FINAL(crc);
}

bool SC_SERVER_DECL CASEngineFuncs_ClassMemcpy(void* pthis, SC_SERVER_DUMMYARG void* _src, int srctypeid, void* _dst, int dsttypeid) 
{
    if (srctypeid != dsttypeid)
        return false;
    asIScriptObject* src = *static_cast<asIScriptObject**>(_src);
    asIScriptObject* dst = *static_cast<asIScriptObject**>(_dst);
    if (!src || !dst)
        return false;
    dst->CopyFrom(src);
    return true;
}

template <typename T>
void RegisteRefObject(CASDocumentation* pASDoc, const char* szName) 
{
    asSFuncPtr reg;
    reg = asMETHOD(T, AddRef);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "AddRef", szName, asBEHAVE_ADDREF, "void AddRef()", &reg, asCALL_THISCALL);
    reg = asMETHOD(T, Release);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "Release", szName, asBEHAVE_RELEASE, "void Release()", &reg, asCALL_THISCALL);
}
template <typename T>
void RegisterGCObject(CASDocumentation* pASDoc, const char* szName) 
{
    RegisteRefObject<T>(pASDoc, szName);
    asSFuncPtr reg;
    reg = asMETHOD(T, SetGCFlag);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "Set GC Flag", szName, asBEHAVE_SETGCFLAG, "void SetGCFlag()", &reg, asCALL_THISCALL);
    reg = asMETHOD(T, GetGCFlag);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "Get GC Flag", szName, asBEHAVE_GETGCFLAG, "bool GetGCFlag() const", &reg, asCALL_THISCALL);
    reg = asMETHOD(T, GetRefCount);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "Get reference count", szName, asBEHAVE_GETREFCOUNT, "int GetRefCount() const", &reg, asCALL_THISCALL);
    reg = asMETHOD(T, EnumReferences);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "Enumerate references held by this class", szName, asBEHAVE_ENUMREFS, "void EnumReferences(int& in)", &reg, asCALL_THISCALL);
    reg = asMETHOD(T, ReleaseReferences);
    ASEXT_RegisterObjectBehaviourEx(pASDoc, "Release all references held by this class", szName, asBEHAVE_RELEASEREFS, "void ReleaseReferences(int& in)", &reg, asCALL_THISCALL);
}

/// <summary>
/// Regiter
/// </summary>
#define REGISTE_OBJMETHODEX(r, d, e, c, m, cc, mm, call) r=asMETHOD(cc,mm);ASEXT_RegisterObjectMethodEx(d,e,c,m,&r,call)
#define REGISTE_OBJMETHODPREX(r, d, e, c, m, cc, mm, pp, rr, call) r=asMETHODPR(cc,mm, pp, rr);ASEXT_RegisterObjectMethodEx(d,e,c,m,&r,call)
void RegisterAngelScriptMethods() 
{
    CASSQLite::LoadSQLite3DLL();

ASEXT_RegisterScriptBuilderDefineCallback( []( CScriptBuilder* pScriptBuilder )
{
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "METAMOD_PLUGIN_ASLP" );

#if _DEBUG
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "METAMOD_DEBUG" );
#else
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "METAMOD_RELEASE" );
#endif

#if LINUX
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "LINUX" );
#endif

#if WIN32
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "WIN32" );
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "WINDOWS" );
#endif
} );

ASEXT_RegisterDocInitCallback([](CASDocumentation* pASDoc) 
{
#pragma region HealthInfo
ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_ASLP );
ASEXT_RegisterObjectType( pASDoc, "Arguments for when a player is getting healed", "HealthInfo", 0, asOBJ_REF | asOBJ_NOCOUNT );
ASEXT_RegisterObjectProperty( pASDoc, "The player that is being healed", "HealthInfo", "CBasePlayer@ player", offsetof( healthinfo_t, player ) );
ASEXT_RegisterObjectProperty( pASDoc, "Health to recover.", "HealthInfo", "float health", offsetof( healthinfo_t, health ) );
ASEXT_RegisterObjectProperty( pASDoc, "Damage type.", "HealthInfo", "int bits", offsetof( healthinfo_t, bits ) );
ASEXT_RegisterObjectProperty( pASDoc, "Whatever to cap the max health capacity. Zero to not cap.", "HealthInfo", "int cap", offsetof( healthinfo_t, cap ) );
ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_NONE );
#pragma endregion
#pragma region CBinaryStringBuilder
        asSFuncPtr reg;
        ASEXT_RegisterObjectType(pASDoc, "Binary String Builder", "CBinaryStringBuilder", 0, asOBJ_REF | asOBJ_GC);
        reg = asFUNCTION(CBinaryStringBuilder::Factory);
        ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "CBinaryStringBuilder", asBEHAVE_FACTORY, "CBinaryStringBuilder@ CBinaryStringBuilder()", &reg, asCALL_CDECL);
        reg = asFUNCTION(CBinaryStringBuilder::ParamFactory);
        ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "CBinaryStringBuilder", asBEHAVE_FACTORY, "CBinaryStringBuilder@ CBinaryStringBuilder(string&in buffer)", &reg, asCALL_CDECL);
        RegisterGCObject<CBinaryStringBuilder>(pASDoc, "CBinaryStringBuilder");
        REGISTE_OBJMETHODEX(reg, pASDoc, "Is Read to end?", "CBinaryStringBuilder", "bool IsReadToEnd()", CBinaryStringBuilder, IsReadToEnd, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get output to a string", "CBinaryStringBuilder", "string Get()", CBinaryStringBuilder, Get, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Set a read buffer", "CBinaryStringBuilder", "bool Set(string&in buffer)", CBinaryStringBuilder, Set, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get the read pointer", "CBinaryStringBuilder", "uint GetReadPointer()", CBinaryStringBuilder, GetReadPointer, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Set the read pointer", "CBinaryStringBuilder", "void SetReadPointer(uint iPointer)", CBinaryStringBuilder, SetReadPointer, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Write a Value", "CBinaryStringBuilder", "void WriteInt(int value)", CBinaryStringBuilder, WriteInt, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Write a Value", "CBinaryStringBuilder", "void WriteLong(int64 value)", CBinaryStringBuilder, WriteLong, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Write a Value", "CBinaryStringBuilder", "void WriteFloat(float value)", CBinaryStringBuilder, WriteFloat, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Write a Value", "CBinaryStringBuilder", "void WriteDouble(double value)", CBinaryStringBuilder, WriteDouble, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Write a Value", "CBinaryStringBuilder", "void WriteVector(Vector value)", CBinaryStringBuilder, WriteVector, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Write a Value", "CBinaryStringBuilder", "void WriteString(string&in value)", CBinaryStringBuilder, WriteString, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Read a Value", "CBinaryStringBuilder", "int ReadInt()", CBinaryStringBuilder, ReadInt, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Read a Value", "CBinaryStringBuilder", "int64 ReadLong()", CBinaryStringBuilder, ReadLong, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Read a Value", "CBinaryStringBuilder", "float ReadFloat()", CBinaryStringBuilder, ReadFloat, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Read a Value", "CBinaryStringBuilder", "double ReadDouble()", CBinaryStringBuilder, ReadDouble, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Read a Value", "CBinaryStringBuilder", "Vector ReadVector()", CBinaryStringBuilder, ReadVector, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Read a Value", "CBinaryStringBuilder", "string ReadString()", CBinaryStringBuilder, ReadString, asCALL_THISCALL);
#pragma endregion
#pragma region CSQLite
        //Enum
        ASEXT_RegisterEnum(pASDoc, "SQLite Return Value", "SQLiteResult", 0);
        ASEXT_RegisterEnumValue(pASDoc, "Successful result ", "SQLiteResult", "SQLITE_OK", 0);
        ASEXT_RegisterEnumValue(pASDoc, "Generic error ", "SQLiteResult", "SQLITE_ERROR", 1);
        ASEXT_RegisterEnumValue(pASDoc, "Internal logic error in SQLite ", "SQLiteResult", "SQLITE_INTERNAL", 2);
        ASEXT_RegisterEnumValue(pASDoc, "Access permission denied ", "SQLiteResult", "SQLITE_PERM", 3);
        ASEXT_RegisterEnumValue(pASDoc, "Callback routine requested an abort ", "SQLiteResult", "SQLITE_ABORT", 4);
        ASEXT_RegisterEnumValue(pASDoc, "The database file is locked ", "SQLiteResult", "SQLITE_BUSY", 5);
        ASEXT_RegisterEnumValue(pASDoc, "A table in the database is locked ", "SQLiteResult", "SQLITE_LOCKED", 6);
        ASEXT_RegisterEnumValue(pASDoc, "A malloc() failed ", "SQLiteResult", "SQLITE_NOMEM", 7);
        ASEXT_RegisterEnumValue(pASDoc, "Attempt to write a readonly database ", "SQLiteResult", "SQLITE_READONLY", 8);
        ASEXT_RegisterEnumValue(pASDoc, "Operation terminated by sqlite3_interrupt()", "SQLiteResult", "SQLITE_INTERRUPT", 9);
        ASEXT_RegisterEnumValue(pASDoc, "Some kind of disk I/O error occurred ", "SQLiteResult", "SQLITE_IOERR", 10);
        ASEXT_RegisterEnumValue(pASDoc, "The database disk image is malformed ", "SQLiteResult", "SQLITE_CORRUPT", 11);
        ASEXT_RegisterEnumValue(pASDoc, "Unknown opcode in sqlite3_file_control() ", "SQLiteResult", "SQLITE_NOTFOUND", 12);
        ASEXT_RegisterEnumValue(pASDoc, "Insertion failed because database is full ", "SQLiteResult", "SQLITE_FULL", 13);
        ASEXT_RegisterEnumValue(pASDoc, "Unable to open the database file ", "SQLiteResult", "SQLITE_CANTOPEN", 14);
        ASEXT_RegisterEnumValue(pASDoc, "Database lock protocol error ", "SQLiteResult", "SQLITE_PROTOCOL", 15);
        ASEXT_RegisterEnumValue(pASDoc, "Internal use only ", "SQLiteResult", "SQLITE_EMPTY", 16);
        ASEXT_RegisterEnumValue(pASDoc, "The database schema changed ", "SQLiteResult", "SQLITE_SCHEMA", 17);
        ASEXT_RegisterEnumValue(pASDoc, "String or BLOB exceeds size limit ", "SQLiteResult", "SQLITE_TOOBIG", 18);
        ASEXT_RegisterEnumValue(pASDoc, "Abort due to constraint violation ", "SQLiteResult", "SQLITE_CONSTRAINT", 19);
        ASEXT_RegisterEnumValue(pASDoc, "Data type mismatch ", "SQLiteResult", "SQLITE_MISMATCH", 20);
        ASEXT_RegisterEnumValue(pASDoc, "Library used incorrectly ", "SQLiteResult", "SQLITE_MISUSE", 21);
        ASEXT_RegisterEnumValue(pASDoc, "Uses OS features not supported on host ", "SQLiteResult", "SQLITE_NOLFS", 22);
        ASEXT_RegisterEnumValue(pASDoc, "Authorization denied ", "SQLiteResult", "SQLITE_AUTH", 23);
        ASEXT_RegisterEnumValue(pASDoc, "Not used ", "SQLiteResult", "SQLITE_FORMAT", 24);
        ASEXT_RegisterEnumValue(pASDoc, "2nd parameter to sqlite3_bind out of range ", "SQLiteResult", "SQLITE_RANGE", 25);
        ASEXT_RegisterEnumValue(pASDoc, "File opened that is not a database file ", "SQLiteResult", "SQLITE_NOTADB", 26);
        ASEXT_RegisterEnumValue(pASDoc, "Notifications from sqlite3_log() ", "SQLiteResult", "SQLITE_NOTICE", 27);
        ASEXT_RegisterEnumValue(pASDoc, "Warnings from sqlite3_log() ", "SQLiteResult", "SQLITE_WARNING", 28);
        ASEXT_RegisterEnumValue(pASDoc, "sqlite3_step() has another row ready ", "SQLiteResult", "SQLITE_ROW", 100);
        ASEXT_RegisterEnumValue(pASDoc, "sqlite3_step() has finished executing ", "SQLiteResult", "SQLITE_DONE", 101);
        ASEXT_RegisterEnumValue(pASDoc, "sql has been closed ", "SQLiteResult", "SQLITE_CLOSED", 999);

        ASEXT_RegisterEnum(pASDoc, "SQLite Open Mode", "SQLiteMode", 0);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_READONLY", 0x00000001);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_READWRITE", 0x00000002);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_CREATE", 0x00000004);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_DELETEONCLOSE", 0x00000008);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_EXCLUSIVE", 0x00000010);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_AUTOPROXY", 0x00000020);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_URI", 0x00000040);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_MEMORY", 0x00000080);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_MAIN_DB", 0x00000100);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_TEMP_DB", 0x00000200);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_TRANSIENT_DB", 0x00000400);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_MAIN_JOURNAL", 0x00000800);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_TEMP_JOURNAL", 0x00001000);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_SUBJOURNAL", 0x00002000);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_SUPER_JOURNAL", 0x00004000);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_NOMUTEX", 0x00008000);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_FULLMUTEX", 0x00010000);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_SHAREDCACHE", 0x00020000);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_PRIVATECACHE", 0x00040000);
        ASEXT_RegisterEnumValue(pASDoc, "VFS only", "SQLiteMode", "SQLITE_OPEN_WAL", 0x00080000);
        ASEXT_RegisterEnumValue(pASDoc, "Ok for sqlite3_open_v2()", "SQLiteMode", "SQLITE_OPEN_NOFOLLOW", 0x01000000);
        ASEXT_RegisterEnumValue(pASDoc, "Extended result codes", "SQLiteMode", "SQLITE_OPEN_EXRESCODE", 0x02000000);

        //Class
        ASEXT_RegisterObjectType(pASDoc, "SQL Item", "CSQLItem", 0, asOBJ_REF | asOBJ_GC);
        RegisterGCObject<CASSQLItem>(pASDoc, "CSQLItem");
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get string", "CSQLItem", "void Get(string&out buffer)", CASSQLItem, Get, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get int64", "CSQLItem", "int64 GetLong()", CASSQLItem, GetInt64, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get int", "CSQLItem", "int GetInt()", CASSQLItem, GetInt, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get int", "CSQLItem", "uint64 GetULong()", CASSQLItem, GetUInt64, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get int", "CSQLItem", "uint GetUInt()", CASSQLItem, GetUInt, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get real", "CSQLItem", "double GetReal()", CASSQLItem, GetReal, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get blob", "CSQLItem", "CBinaryStringBuilder@ GetBlob()", CASSQLItem, GetBlob, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Is null", "CSQLItem", "bool IsNull()", CASSQLItem, IsNull, asCALL_THISCALL);

        ASEXT_RegisterObjectType(pASDoc, "SQL Grid", "CSQLGrid", 0, asOBJ_REF | asOBJ_GC);
        RegisterGCObject<CASSQLGrid>(pASDoc, "CSQLGrid");
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get CSQLItem", "CSQLGrid", "CSQLItem@ Get(uint row, uint column)", CASSQLGrid, Get, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get CSQLItem", "CSQLGrid", "CSQLItem@ opIndex(uint row, uint column)", CASSQLGrid, Get, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get Rows", "CSQLGrid", "uint Rows()", CASSQLGrid, Rows, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Get Columns", "CSQLGrid", "uint Columns()", CASSQLGrid, Columns, asCALL_THISCALL);

        ASEXT_RegisterFuncDef(pASDoc, "SQLite Callback", "void fnSQLiteCallback(any@ pParam, int iColumnSize, array<CSQLItem@>@ aryColumnValue, array<CSQLItem@>@ aryColumnName)");

        ASEXT_RegisterObjectType(pASDoc, "SQLite", "CSQLite", 0, asOBJ_REF | asOBJ_GC);
        reg = asFUNCTION(CASSQLite::Factory);
        ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "CSQLite", asBEHAVE_FACTORY, "CSQLite@ CSQLite(string&in path, SQLiteMode iMode)", &reg, asCALL_CDECL);
        RegisterGCObject<CASSQLite>(pASDoc, "CSQLite");
        REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL", "CSQLite", "SQLiteResult Exec(string&in sql, string&out errMsg)", CASSQLite, Exec, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL In Sync", "CSQLite", "SQLiteResult Exec(string&in sql, CSQLGrid@ &out aryResult, string&out errMsg)", CASSQLite, ExecSync, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL", "CSQLite", "SQLiteResult Exec(string&in sql, fnSQLiteCallback@ pCallback, any@ pCallBackparam, string&out errMsg)", CASSQLite, ExecWithCallBack, asCALL_THISCALL);
        REGISTE_OBJMETHODEX(reg, pASDoc, "Close SQL", "CSQLite", "void Close()", CASSQLite, Close, asCALL_THISCALL);
ASEXT_RegisterObjectMethod(pASDoc,
    "Caculate CRC32 for a string", "CEngineFuncs", "uint32 CRC32(const string& in szBuffer)",
    (void*)CASEngineFuncs_CRC32, asCALL_THISCALL);
ASEXT_RegisterObjectMethod(pASDoc,
    "copy class, If src and dst are different type, return false.\nIf not class ref, crash game.", "CEngineFuncs", "bool ClassMemcpy(?& in src, ?& in dst)",
    (void*)CASEngineFuncs_ClassMemcpy, asCALL_THISCALL);
#pragma endregion

ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_ASLP "::json" );
#pragma region Json
ASEXT_RegisterGlobalFunction( pASDoc, "Deserialize a string json-format into a dictionary. if str ends with .json it will be a file to open",
    "bool Deserialize( const string &in str, dictionary &out obj )", (void*)CASJsonDeserialize, asCALL_CDECL );
#pragma endregion

ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_ASLP );

#pragma region physent_t
ASEXT_RegisterObjectType( pASDoc, "Physics data",
    "PhysicalEntity", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectMethod( pASDoc, "Classname of this entity",
    "PhysicalEntity", "string get_name() property",  (void*)CASPlayerMove__GetPhysEntName, asCALL_THISCALL );

ASEXT_RegisterObjectMethod( pASDoc, "Is this entity a player?",
    "PhysicalEntity", "bool IsPlayer() const",
    (void*)( +[]( physent_t* pthis SC_SERVER_DUMMYARG_NOCOMMA ) -> bool
    {
        return( strcmp( pthis->name, "player" ) == 0 );
    } ), asCALL_THISCALL );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector origin", offsetof( physent_t, origin ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector mins", offsetof( physent_t, mins ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector maxs", offsetof( physent_t, maxs ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index or identifier associated with this physent.",
    "PhysicalEntity", "int info", offsetof( physent_t, info ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector angles", offsetof( physent_t, angles ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int solid", offsetof( physent_t, solid ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int skin", offsetof( physent_t, skin ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int rendermode", offsetof( physent_t, rendermode ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float frame", offsetof( physent_t, frame ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int sequence", offsetof( physent_t, sequence ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int controller", offsetof( physent_t, controller ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int blending", offsetof( physent_t, blending ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int movetype", offsetof( physent_t, movetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int takedamage", offsetof( physent_t, takedamage ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int blooddecal", offsetof( physent_t, blooddecal ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int team", offsetof( physent_t, team ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int classnumber", offsetof( physent_t, classnumber ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser1", offsetof( physent_t, iuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser2", offsetof( physent_t, iuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser3", offsetof( physent_t, iuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser4", offsetof( physent_t, iuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser1", offsetof( physent_t, fuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser2", offsetof( physent_t, fuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser3", offsetof( physent_t, fuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser4", offsetof( physent_t, fuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser1", offsetof( physent_t, vuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser2", offsetof( physent_t, vuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser3", offsetof( physent_t, vuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser4", offsetof( physent_t, vuser4 ) );
#pragma endregion

#pragma region playermove_t
ASEXT_RegisterObjectType( pASDoc, "Player movement data",
    "PlayerMovement", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectMethod( pASDoc, "index of the player that is moving",
    "PlayerMovement", "int get_player() const property", (void*)CASPlayerMove__PlayerIndex, asCALL_THISCALL );

ASEXT_RegisterObjectProperty( pASDoc, "Realtime on host, for reckoning duck timing",
    "PlayerMovement", "const float time", offsetof( playermove_t, time ) );

ASEXT_RegisterObjectProperty( pASDoc, "Duration of this frame",
    "PlayerMovement", "const float frametime", offsetof( playermove_t, frametime ) );

ASEXT_RegisterObjectProperty( pASDoc, "Vectors for angles",
    "PlayerMovement", "Vector forward", offsetof( playermove_t, forward ) );

ASEXT_RegisterObjectProperty( pASDoc, "Vectors for angles",
    "PlayerMovement", "Vector right", offsetof( playermove_t, right ) );

ASEXT_RegisterObjectProperty( pASDoc, "Vectors for angles",
    "PlayerMovement", "Vector up", offsetof( playermove_t, up ) );

ASEXT_RegisterObjectProperty( pASDoc, "Movement origin.",
    "PlayerMovement", "Vector origin", offsetof( playermove_t, origin ) );

ASEXT_RegisterObjectProperty( pASDoc, "Movement view angles.",
    "PlayerMovement", "Vector angles", offsetof( playermove_t, angles ) );

ASEXT_RegisterObjectProperty( pASDoc, "Angles before movement view angles were looked at.",
    "PlayerMovement", "Vector oldangles", offsetof( playermove_t, oldangles ) );

ASEXT_RegisterObjectProperty( pASDoc, "Current movement direction.",
    "PlayerMovement", "Vector velocity", offsetof( playermove_t, velocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "For waterjumping, a forced forward velocity so we can fly over lip of ledge.",
    "PlayerMovement", "Vector movedir", offsetof( playermove_t, movedir ) );

ASEXT_RegisterObjectProperty( pASDoc, "Velocity of the conveyor we are standing, e.g.",
    "PlayerMovement", "Vector basevelocity", offsetof( playermove_t, basevelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "Our eye position.",
    "PlayerMovement", "Vector view_ofs", offsetof( playermove_t, view_ofs ) );

ASEXT_RegisterObjectProperty( pASDoc, "Time we started duck",
    "PlayerMovement", "float flDuckTime", offsetof( playermove_t, flDuckTime ) );

ASEXT_RegisterObjectProperty( pASDoc, "In process of ducking or ducked already?",
    "PlayerMovement", "int bInDuck", offsetof( playermove_t, bInDuck ) );

ASEXT_RegisterObjectProperty( pASDoc, "Next time we can play a step sound",
    "PlayerMovement", "int flTimeStepSound", offsetof( playermove_t, flTimeStepSound ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iStepLeft", offsetof( playermove_t, iStepLeft ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float flFallVelocity", offsetof( playermove_t, flFallVelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector punchangle", offsetof( playermove_t, punchangle ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float flSwimTime", offsetof( playermove_t, flSwimTime ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float flNextPrimaryAttack", offsetof( playermove_t, flNextPrimaryAttack ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int effects", offsetof( playermove_t, effects ) );

ASEXT_RegisterObjectProperty( pASDoc, "FL_ONGROUND, FL_DUCKING, etc.",
    "PlayerMovement", "int flags", offsetof( playermove_t, flags ) );

ASEXT_RegisterObjectProperty( pASDoc, "0 = regular player hull, 1 = ducked player hull, 2 = point hull",
    "PlayerMovement", "int usehull", offsetof( playermove_t, usehull ) );

ASEXT_RegisterObjectProperty( pASDoc, "Our current gravity and friction.",
    "PlayerMovement", "float gravity", offsetof( playermove_t, gravity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float friction", offsetof( playermove_t, friction ) );

ASEXT_RegisterObjectProperty( pASDoc, "Buttons last usercmd",
    "PlayerMovement", "int oldbuttons", offsetof( playermove_t, oldbuttons ) );

ASEXT_RegisterObjectProperty( pASDoc, "Amount of time left in jumping out of water cycle.",
    "PlayerMovement", "float waterjumptime", offsetof( playermove_t, waterjumptime ) );

ASEXT_RegisterObjectProperty( pASDoc, "Are we a dead player?",
    "PlayerMovement", "const int dead", offsetof( playermove_t, dead ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "const int deadflag", offsetof( playermove_t, deadflag ) );

ASEXT_RegisterObjectProperty( pASDoc, "Should we use spectator physics model?",
    "PlayerMovement", "const int spectator", offsetof( playermove_t, spectator ) );

ASEXT_RegisterObjectProperty( pASDoc, "Our movement type, NOCLIP, WALK, FLY",
    "PlayerMovement", "int movetype", offsetof( playermove_t, movetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index the player is standing on (-1 if none).",
    "PlayerMovement", "int onground", offsetof( playermove_t, onground ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int waterlevel", offsetof( playermove_t, waterlevel ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int watertype", offsetof( playermove_t, watertype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int oldwaterlevel", offsetof( playermove_t, oldwaterlevel ) );

ASEXT_RegisterObjectMethod( pASDoc, "Texture name the player is currently standing at",
    "PlayerMovement", "string get_TextureName() property",  (void*)CASPlayerMove__GetTextureName, asCALL_THISCALL );

ASEXT_RegisterObjectProperty( pASDoc, "Texture type the player is currently standing at",
    "PlayerMovement", "const char TextureType", offsetof( playermove_t, chtexturetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float maxspeed", offsetof( playermove_t, maxspeed ) );

ASEXT_RegisterObjectProperty( pASDoc, "Player specific maxspeed",
    "PlayerMovement", "float clientmaxspeed", offsetof( playermove_t, clientmaxspeed ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser1", offsetof( playermove_t, iuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser2", offsetof( playermove_t, iuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser3", offsetof( playermove_t, iuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser4", offsetof( playermove_t, iuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser1", offsetof( playermove_t, fuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser2", offsetof( playermove_t, fuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser3", offsetof( playermove_t, fuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser4", offsetof( playermove_t, fuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser1", offsetof( playermove_t, vuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser2", offsetof( playermove_t, vuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser3", offsetof( playermove_t, vuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser4", offsetof( playermove_t, vuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "Number of physical entities in collision list.",
    "PlayerMovement", "int numphysent", offsetof( playermove_t, numphysent ) );

ASEXT_RegisterObjectMethod( pASDoc, "Get the physical entity in collision list for the given index.",
    "PlayerMovement", NAMESPACE_ASLP "::PhysicalEntity@ GetPhysEntByIndex( int index )", (void*)CASPlayerMove__GetPhysEntByIndex, asCALL_THISCALL );

ASEXT_RegisterObjectMethod( pASDoc, "Set the physical entity in collision list for the given index.",
    "PlayerMovement", "void SetPhysEntByIndex( " NAMESPACE_ASLP "::PhysicalEntity@ pPhyEnt, int newindex )", ( void* )CASPlayerMove__SetPhysEntByIndex, asCALL_THISCALL );
#pragma endregion

#pragma region MetaResult
ASEXT_RegisterEnum( pASDoc, "Flags returned by a plugin's api function.",
    "MetaResult", 0 );
ASEXT_RegisterEnumValue( pASDoc, "Plugin didn't take any action",
    "MetaResult", "Ignored", static_cast<int>( META_RES::MRES_IGNORED ) );
ASEXT_RegisterEnumValue( pASDoc, "Plugin did something, but real function should still be called",
    "MetaResult", "Handled", static_cast<int>( META_RES::MRES_HANDLED ) );
ASEXT_RegisterEnumValue( pASDoc, "Call real function, but use my return value",
    "MetaResult", "Override", static_cast<int>( META_RES::MRES_OVERRIDE ) );
ASEXT_RegisterEnumValue( pASDoc, "Skip real function and use my return value",
    "MetaResult", "Supercede", static_cast<int>( META_RES::MRES_SUPERCEDE ) );
#pragma endregion

#pragma region entity_state_t
ASEXT_RegisterObjectType(pASDoc, "Entity state is used for the baseline and for delta compression of a packet of entities that is sent to a client.",
    "EntityState", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectProperty( pASDoc, "Type classification used by the engine (normal entity, player, beam, etc.). Mostly internal; affects how the client interprets the state.",
    "EntityState", "int entityType", offsetof( entity_state_t, entityType ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index",
    "EntityState", "int number", offsetof( entity_state_t, number ) );

ASEXT_RegisterObjectProperty( pASDoc, "Server time when this state was generated. Used for interpolation and networking.",
    "EntityState", "float msg_time", offsetof( entity_state_t, msg_time ) );

ASEXT_RegisterObjectProperty( pASDoc, "Incrementing message sequence number. Helps delta compression determine differences.",
    "EntityState", "int messagenum", offsetof( entity_state_t, messagenum ) );

ASEXT_RegisterObjectProperty( pASDoc, "Position in world",
    "EntityState", "Vector origin", offsetof( entity_state_t, origin ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity angles",
    "EntityState", "Vector angles", offsetof( entity_state_t, angles ) );

ASEXT_RegisterObjectProperty( pASDoc, "Index into the precached model table. Determines which .mdl, .spr, or brush model to render.",
    "EntityState", "int modelindex", offsetof( entity_state_t, modelindex ) );

ASEXT_RegisterObjectProperty( pASDoc, "Model animation sequence number.",
    "EntityState", "int sequence", offsetof( entity_state_t, sequence ) );

ASEXT_RegisterObjectProperty( pASDoc, "Current animation frame.",
    "EntityState", "float frame", offsetof( entity_state_t, frame ) );

ASEXT_RegisterObjectProperty( pASDoc, "Color remap index",
    "EntityState", "int colormap", offsetof( entity_state_t, colormap ) );

ASEXT_RegisterObjectProperty( pASDoc, "Skin index inside the model.",
    "EntityState", "int16 skin", offsetof( entity_state_t, skin ) );

ASEXT_RegisterObjectProperty( pASDoc, "Bodygroup selection.",
    "EntityState", "int body", offsetof( entity_state_t, body ) );

ASEXT_RegisterObjectProperty( pASDoc, "Solid mode (How the client interacts with this entity)",
    "EntityState", "int16 solid", offsetof( entity_state_t, solid ) );

ASEXT_RegisterObjectProperty( pASDoc, "Rendering effects flag",
    "EntityState", "int effects", offsetof( entity_state_t, effects ) );

ASEXT_RegisterObjectProperty( pASDoc, "Model/Sprite scale multiplier",
    "EntityState", "float scale", offsetof( entity_state_t, scale ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int8 eflags", offsetof( entity_state_t, eflags ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render mode",
    "EntityState", "int rendermode", offsetof( entity_state_t, rendermode ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render ammount",
    "EntityState", "int renderamt", offsetof( entity_state_t, renderamt ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render color",
    "EntityState", "Vector rendercolor", offsetof( entity_state_t, rendercolor ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render effect",
    "EntityState", "int renderfx", offsetof( entity_state_t, renderfx ) );

ASEXT_RegisterObjectProperty( pASDoc, "Move type",
    "EntityState", "int movetype", offsetof( entity_state_t, movetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float animtime", offsetof( entity_state_t, animtime ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float framerate", offsetof( entity_state_t, framerate ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector velocity", offsetof( entity_state_t, velocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector mins", offsetof( entity_state_t, mins ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector maxs", offsetof( entity_state_t, maxs ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int aiment", offsetof( entity_state_t, aiment ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int owner", offsetof( entity_state_t, owner ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float friction", offsetof( entity_state_t, friction ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float gravity", offsetof( entity_state_t, gravity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int team", offsetof( entity_state_t, team ) );

ASEXT_RegisterObjectProperty( pASDoc, "Player-specific classification",
    "EntityState", "int playerclass", offsetof( entity_state_t, playerclass ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int health", offsetof( entity_state_t, health ) );

ASEXT_RegisterObjectProperty( pASDoc, "Player-specific spectator. 0/1 false/true",
    "EntityState", "int spectator", offsetof( entity_state_t, spectator ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int weaponmodel", offsetof( entity_state_t, weaponmodel ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int gaitsequence", offsetof( entity_state_t, gaitsequence ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector basevelocity", offsetof( entity_state_t, basevelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int usehull", offsetof( entity_state_t, usehull ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int oldbuttons", offsetof( entity_state_t, oldbuttons ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index the player is standing on (-1 if none).",
    "EntityState", "int onground", offsetof( entity_state_t, onground ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iStepLeft", offsetof( entity_state_t, iStepLeft ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float flFallVelocity", offsetof( entity_state_t, flFallVelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fov", offsetof( entity_state_t, fov ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int weaponanim", offsetof( entity_state_t, weaponanim ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser1", offsetof( entity_state_t, iuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser2", offsetof( entity_state_t, iuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser3", offsetof( entity_state_t, iuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser4", offsetof( entity_state_t, iuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser1", offsetof( entity_state_t, fuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser2", offsetof( entity_state_t, fuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser3", offsetof( entity_state_t, fuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser4", offsetof( entity_state_t, fuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser1", offsetof( entity_state_t, vuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser2", offsetof( entity_state_t, vuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser3", offsetof( entity_state_t, vuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser4", offsetof( entity_state_t, vuser4 ) );
#pragma endregion

#pragma region addtofullpack_t
ASEXT_RegisterObjectType( pASDoc, "Entity networking packet.",
    "ClientPacket", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectProperty( pASDoc, "Entity state being processed.",
    "ClientPacket", NAMESPACE_ASLP "::EntityState@ state", offsetof( addtofullpack_t, state ) );

ASEXT_RegisterObjectProperty( pASDoc, "The index of the entity currently being considered for transmission.",
    "ClientPacket", "const int index", offsetof( addtofullpack_t, index ) );

ASEXT_RegisterObjectProperty( pASDoc, "The entity currently being considered for transmission.",
    "ClientPacket", "edict_t@ entity", offsetof( addtofullpack_t, entity ) );

ASEXT_RegisterObjectProperty( pASDoc, "The client receiving this packet.",
    "ClientPacket", "edict_t@ host", offsetof( addtofullpack_t, host ) );

ASEXT_RegisterObjectProperty( pASDoc, "Flags describing properties of the receiving client.",
    "ClientPacket", "int hostFlags", offsetof( addtofullpack_t, hostFlags ) );

ASEXT_RegisterObjectProperty( pASDoc, "The index of the client receiving this packet.",
    "ClientPacket", "const int playerIndex", offsetof( addtofullpack_t, playerIndex ) );
#pragma endregion

ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_NONE );
    } );
}
#undef REGISTE_OBJMETHODEX
#undef REGISTE_OBJMETHODPREX

#define CREATE_AS_HOOK(item, des, tag, name, arg) g_AngelHook.item=ASEXT_RegisterHook(des,StopMode_CALL_ALL,2,ASFlag_MapScript|ASFlag_Plugin,tag,name,arg)

void RegisterAngelScriptHooks()
{
CREATE_AS_HOOK( pClientCommandHook, "Pre call of ClientCommand. See CEngineFuncs Cmd_Args, Cmd_Argv and Cmd_Argc",
    NAMESPACE_ASLP, "ClientCommand", "CBasePlayer@ player, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPlayerUserInfoChanged, "Pre call before a player info changed",
    NAMESPACE_ASLP, "UserInfoChanged", "CBasePlayer@ player, string buffer, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPreMovement, "Called before the Server-side logic of the player movement.",
    NAMESPACE_ASLP, "PlayerPreMovement", NAMESPACE_ASLP "::PlayerMovement@ &out movement, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPostMovement, "Called after the Server-side logic of the player movement.",
    NAMESPACE_ASLP, "PlayerPostMovement", NAMESPACE_ASLP "::PlayerMovement@ &out movement, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPreAddToFullPack, "Called when the server is about to network a entity to a client",
    NAMESPACE_ASLP, "PreAddToFullPack", NAMESPACE_ASLP "::ClientPacket@ packet, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPostAddToFullPack, "Called when the server is about to network a entity to a client",
    NAMESPACE_ASLP, "PostAddToFullPack", NAMESPACE_ASLP "::ClientPacket@ packet, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pShouldCollide, "Called whatever a entity is touched by another. Set Collide to false to prevent the interaction.",
    NAMESPACE_ASLP, "ShouldCollide", "CBaseEntity@ touched, CBaseEntity@ other, " NAMESPACE_ASLP "::MetaResult &out meta_result, bool &out Collide" );

CREATE_AS_HOOK(pPlayerPostTakeDamage, "Pre call before a player took damage", "Player", "PlayerPostTakeDamage", "DamageInfo@ info");

CREATE_AS_HOOK( pPlayerTakeHealth,
    "Pre call before a player is healed",
    NAMESPACE_ASLP,
    "PlayerTakeHealth", NAMESPACE_ASLP "::HealthInfo@ info"
);

CREATE_AS_HOOK( pEntityIRelationship, "Pre call before checking relation", "Entity", "IRelationship", "CBaseEntity@ pEntity, CBaseEntity@ pOther, bool param, int& out newValue");

CREATE_AS_HOOK( pMonsterTraceAttack,
    "Pre call before a monster trace attack",
    "Monster", "MonsterTraceAttack", "CBaseMonster@ pMonster, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType");
CREATE_AS_HOOK( pMonsterPostTakeDamage,
    "Post call after a monster took damage",
    "Monster", "MonsterPostTakeDamage", "DamageInfo@ info"
);

CREATE_AS_HOOK( pBreakableTraceAttack,
    "Pre call before a breakable trace attack",
    "Entity", "BreakableTraceAttack", "CBaseEntity@ pBreakable, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType"
);

CREATE_AS_HOOK( pBreakableKilled,
    "Pre call before a breakable died",
    "Entity", "BreakableDie", "CBaseEntity@ pBreakable, entvars_t@ pevAttacker, int iGib"
);

CREATE_AS_HOOK( pBreakableTakeDamage,
    "Pre call before a breakable took damage",
    "Entity", "BreakableTakeDamage", "DamageInfo@ info"
);

CREATE_AS_HOOK( pGrappleCheckMonsterType,
    "Pre call before Weapon Grapple checking monster type",
    "Weapon", "GrappleGetMonsterType", "CBaseEntity@ pThis, CBaseEntity@ pEntity, uint& out flag"
);
}
#undef CREATE_AS_HOOK

void CloseAngelScriptsItem() 
{
    CASSQLite::CloseSQLite3DLL();
}
