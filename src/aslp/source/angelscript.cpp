#include <extdll.h>

#include "angelscript.h"
#include "asext_api.h"
#include "angelscriptlib.h"

#include <meta_api.h>
#include "CASBinaryStringBuilder.h"
#include "CASSQLItem.h"
#include "CASSQLGrid.h"
#include "CASSQLite.h"
#include "CASJson.h"
#include <pm_defs.h>
#include <entity_state.h>

angelhook_t g_AngelHook;

/**
 * @brief Append the plugin's namespace string to *a*
 */
#define ASLP_NAMESPACE(a) "aslp::" #a

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
void RegisteGCObject(CASDocumentation* pASDoc, const char* szName) 
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

physent_t* SC_SERVER_DECL CASPlayerMove__GetPhysEntByIndex(playermove_t* pthis, SC_SERVER_DUMMYARG int index)
{
	return &pthis->physents[index];
}

void SC_SERVER_DECL CASPlayerMove__SetPhysEntByIndex(playermove_t* pthis, SC_SERVER_DUMMYARG physent_t* pPhyEnt, int oldindex)
{
	pthis->physents[oldindex] = *pPhyEnt;
}

/// <summary>
/// Regiter
/// </summary>
#define REGISTE_OBJMETHODEX(r, d, e, c, m, cc, mm, call) r=asMETHOD(cc,mm);ASEXT_RegisterObjectMethodEx(d,e,c,m,&r,call)
#define REGISTE_OBJMETHODPREX(r, d, e, c, m, cc, mm, pp, rr, call) r=asMETHODPR(cc,mm, pp, rr);ASEXT_RegisterObjectMethodEx(d,e,c,m,&r,call)
void RegisterAngelScriptMethods() 
{
	CASSQLite::LoadSQLite3DLL();

	ASEXT_RegisterScriptBuilderDefineCallback([](CScriptBuilder* pScriptBuilder) {

		ASEXT_CScriptBuilder_DefineWord(pScriptBuilder, "METAMOD_PLUGIN_ASLP");
	} );

	// -TODO How to get the const char doc* in the generate_as_predefined.cpp
	ASEXT_RegisterDocInitCallback([](CASDocumentation* pASDoc) 
	{
#pragma region HealthInfo
		//Regist HealthInfo type
		ASEXT_RegisterObjectType(pASDoc, "Entity takehealth info", "HealthInfo", 0, asOBJ_REF | asOBJ_NOCOUNT);
		ASEXT_RegisterObjectProperty(pASDoc, "Who get healing?", "HealthInfo", "CBaseEntity@ pEntity", offsetof(healthinfo_t, pEntity));
		ASEXT_RegisterObjectProperty(pASDoc, "Recover amount.", "HealthInfo", "float flHealth", offsetof(healthinfo_t, flHealth));
		ASEXT_RegisterObjectProperty(pASDoc, "Recover dmg type.", "HealthInfo", "int bitsDamageType", offsetof(healthinfo_t, bitsDamageType));
		ASEXT_RegisterObjectProperty(pASDoc, "If health_cap is non-zero, won't add more than health_cap. Returns true if it took damage, false otherwise.", "HealthInfo", "int health_cap", offsetof(healthinfo_t, health_cap));
#pragma endregion
#pragma region CBinaryStringBuilder
		asSFuncPtr reg;
		ASEXT_RegisterObjectType(pASDoc, "Binary String Builder", "CBinaryStringBuilder", 0, asOBJ_REF | asOBJ_GC);
		reg = asFUNCTION(CBinaryStringBuilder::Factory);
		ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "CBinaryStringBuilder", asBEHAVE_FACTORY, "CBinaryStringBuilder@ CBinaryStringBuilder()", &reg, asCALL_CDECL);
		reg = asFUNCTION(CBinaryStringBuilder::ParamFactory);
		ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "CBinaryStringBuilder", asBEHAVE_FACTORY, "CBinaryStringBuilder@ CBinaryStringBuilder(string&in buffer)", &reg, asCALL_CDECL);
		RegisteGCObject<CBinaryStringBuilder>(pASDoc, "CBinaryStringBuilder");
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
		RegisteGCObject<CASSQLItem>(pASDoc, "CSQLItem");
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get string", "CSQLItem", "void Get(string&out buffer)", CASSQLItem, Get, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get int64", "CSQLItem", "int64 GetLong()", CASSQLItem, GetInt64, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get int", "CSQLItem", "int GetInt()", CASSQLItem, GetInt, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get int", "CSQLItem", "uint64 GetULong()", CASSQLItem, GetUInt64, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get int", "CSQLItem", "uint GetUInt()", CASSQLItem, GetUInt, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get real", "CSQLItem", "double GetReal()", CASSQLItem, GetReal, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get blob", "CSQLItem", "CBinaryStringBuilder@ GetBlob()", CASSQLItem, GetBlob, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Is null", "CSQLItem", "bool IsNull()", CASSQLItem, IsNull, asCALL_THISCALL);

		ASEXT_RegisterObjectType(pASDoc, "SQL Grid", "CSQLGrid", 0, asOBJ_REF | asOBJ_GC);
		RegisteGCObject<CASSQLGrid>(pASDoc, "CSQLGrid");
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get CSQLItem", "CSQLGrid", "CSQLItem@ Get(uint row, uint column)", CASSQLGrid, Get, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get CSQLItem", "CSQLGrid", "CSQLItem@ opIndex(uint row, uint column)", CASSQLGrid, Get, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get Rows", "CSQLGrid", "uint Rows()", CASSQLGrid, Rows, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get Columns", "CSQLGrid", "uint Columns()", CASSQLGrid, Columns, asCALL_THISCALL);

		ASEXT_RegisterFuncDef(pASDoc, "SQLite Callback", "void fnSQLiteCallback(any@ pParam, int iColumnSize, array<CSQLItem@>@ aryColumnValue, array<CSQLItem@>@ aryColumnName)");

		ASEXT_RegisterObjectType(pASDoc, "SQLite", "CSQLite", 0, asOBJ_REF | asOBJ_GC);
		reg = asFUNCTION(CASSQLite::Factory);
		ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "CSQLite", asBEHAVE_FACTORY, "CSQLite@ CSQLite(string&in path, SQLiteMode iMode)", &reg, asCALL_CDECL);
		RegisteGCObject<CASSQLite>(pASDoc, "CSQLite");
		REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL", "CSQLite", "SQLiteResult Exec(string&in sql, string&out errMsg)", CASSQLite, Exec, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL In Sync", "CSQLite", "SQLiteResult Exec(string&in sql, CSQLGrid@ &out aryResult, string&out errMsg)", CASSQLite, ExecSync, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL", "CSQLite", "SQLiteResult Exec(string&in sql, fnSQLiteCallback@ pCallback, any@ pCallBackparam, string&out errMsg)", CASSQLite, ExecWithCallBack, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Close SQL", "CSQLite", "void Close()", CASSQLite, Close, asCALL_THISCALL);
#pragma endregion
#pragma region Json
		ASEXT_RegisterEnum( pASDoc, "JSON Value Type", "JsonType", 0 );
		ASEXT_RegisterEnumValue( pASDoc, "Object", "JsonType", "Object", CASJsonType::OBJECT_VALUE );
		ASEXT_RegisterEnumValue( pASDoc, "Array", "JsonType", "Array", CASJsonType::ARRAY_VALUE );
		ASEXT_RegisterEnumValue( pASDoc, "Boolean", "JsonType", "Boolean", CASJsonType::BOOLEAN_VALUE );
		ASEXT_RegisterEnumValue( pASDoc, "String", "JsonType", "String",CASJsonType::STRING_VALUE );
		ASEXT_RegisterEnumValue( pASDoc, "Integer", "JsonType", "Integer", CASJsonType::INTEGER_VALUE );
		ASEXT_RegisterEnumValue( pASDoc, "Float", "JsonType", "Float", CASJsonType::FLOAT_VALUE );
		ASEXT_RegisterEnumValue( pASDoc, "Null", "JsonType", "Null", CASJsonType::NULL_VALUE );

		ASEXT_RegisterObjectType( pASDoc, "JSON Object", "CJson", 0, asOBJ_REF | asOBJ_GC );
		reg = asFUNCTIONPR( CASJson::Factory, (), CASJson* );
		ASEXT_RegisterObjectBehaviourEx( pASDoc, "Factory", "CJson", asBEHAVE_FACTORY, "CJson@ f()", &reg, asCALL_CDECL);
		RegisteGCObject<CASJson>( pASDoc, "CJson" );
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a boolean", "CJson", "CJson& opAssign(bool)", CASJson, operator=, (bool), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign an integer", "CJson", "CJson& opAssign(int64)", CASJson, operator=, (asINT64), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a real number", "CJson", "CJson& opAssign(double)", CASJson, operator=, (double), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a string", "CJson", "CJson& opAssign(const string&in)", CASJson, operator=, (const CString&), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign another json", "CJson", "CJson& opAssign(const CJson&in)", CASJson, operator=, (const CASJson&), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a array of json", "CJson", "CJson& opAssign(const array<CJson@>&in)", CASJson, operator=, (const CScriptArray&), CASJson&, asCALL_THISCALL);

		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "CJson", "void Set(const string&in, bool)", CASJson, Set, (const jsonKey_t&, bool), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "CJson", "void Set(const string&in, int64)", CASJson, Set, (const jsonKey_t&, asINT64), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "CJson", "void Set(const string&in, double)", CASJson, Set, (const jsonKey_t&, double), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "CJson", "void Set(const string&in, const string&in)", CASJson, Set, (const jsonKey_t&, const CString&), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "CJson", "void Set(const string&in, array<CJson@>&in)", CASJson, Set, (const jsonKey_t&, const CScriptArray&), void, asCALL_THISCALL);

		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "CJson", "bool Get(const string&in, bool&out) const", CASJson, Get, (const jsonKey_t&, bool&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "CJson", "bool Get(const string&in, int64&out) const", CASJson, Get, (const jsonKey_t&, asINT64&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "CJson", "bool Get(const string&in, double&out) const", CASJson, Get, (const jsonKey_t&, double&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "CJson", "bool Get(string&in, string&out) const", CASJson, Get, (const jsonKey_t&, CString&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "CJson", "bool Get(string&in, array<CJson@>@ const) const", CASJson, Get, (const jsonKey_t&, CScriptArray&) const, bool, asCALL_THISCALL);

		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to boolean", "CJson", "bool opConv()", CASJson, GetBool, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to string", "CJson", "string& opConv()", CASJson, GetString, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to integer", "CJson", "int opConv()", CASJson, GetNumber, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to real number", "CJson", "double opConv()", CASJson, GetReal, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to array", "CJson", "array<CJson@>@ opConv()", CASJson, GetArray, asCALL_THISCALL);

		REGISTE_OBJMETHODEX(reg, pASDoc, "Access value by key", "CJson", "CJson& opIndex(const string&in)", CASJson, opIndex, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Access value by key (const)", "CJson", "const CJson& opIndex(const string&in) const", CASJson, opIndex_const, asCALL_THISCALL);

		REGISTE_OBJMETHODEX(reg, pASDoc, "Check if a key exists", "CJson", "bool Exists(const string&in) const", CASJson, Exists, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Check if the object is empty", "CJson", "bool IsEmpty() const", CASJson, IsEmpty, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get the number of elements", "CJson", "uint GetSize() const", CASJson, GetSize, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Clear all elements", "CJson", "void Clear()", CASJson, Clear, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get the value type", "CJson", "JsonType Type() const", CASJson, Type, asCALL_THISCALL);

		//Regist New Method

		extern bool SC_SERVER_DECL CASEngineFuncs_JsonDeserialize(void* pthis, SC_SERVER_DUMMYARG const CString& str, CASJson& obj);
		ASEXT_RegisterObjectMethod(pASDoc, "", "CEngineFuncs", "bool JsonDeserialize(const string &in str, CJson &out obj)", (void*)CASEngineFuncs_JsonDeserialize, asCALL_THISCALL);

		extern bool SC_SERVER_DECL CASEngineFuncs_JsonSerialize(void* pthis, SC_SERVER_DUMMYARG const CASJson& obj, CString& str, int indents = -1);
		ASEXT_RegisterObjectMethod(pASDoc, "", "CEngineFuncs", "bool JsonSerialize(const CJson &in obj, string &out str, int indents = -1)", (void*)CASEngineFuncs_JsonSerialize, asCALL_THISCALL );

		ASEXT_RegisterObjectMethod(pASDoc,
			"Caculate CRC32 for a string", "CEngineFuncs", "uint32 CRC32(const string& in szBuffer)",
			(void*)CASEngineFuncs_CRC32, asCALL_THISCALL);
		ASEXT_RegisterObjectMethod(pASDoc,
			"copy class, If src and dst are different type, return false.\nIf not class ref, crash game.", "CEngineFuncs", "bool ClassMemcpy(?& in src, ?& in dst)",
			(void*)CASEngineFuncs_ClassMemcpy, asCALL_THISCALL);
#pragma endregion
#pragma region entity_state_t
		ASEXT_RegisterObjectType(pASDoc, "Entity state is used for the baseline and for delta compression of a packet of entities that is sent to a client.", "entity_state_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int entityType", offsetof(entity_state_t, entityType));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int number", offsetof(entity_state_t, number));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float msg_time", offsetof(entity_state_t, msg_time));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int messagenum", offsetof(entity_state_t, messagenum));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector origin", offsetof(entity_state_t, origin));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector angles", offsetof(entity_state_t, angles));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int modelindex", offsetof(entity_state_t, modelindex));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int sequence", offsetof(entity_state_t, sequence));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float frame", offsetof(entity_state_t, frame));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int colormap", offsetof(entity_state_t, colormap));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int16 skin", offsetof(entity_state_t, skin));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int16 solid", offsetof(entity_state_t, solid));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int effects", offsetof(entity_state_t, effects));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float scale", offsetof(entity_state_t, scale));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int8 eflags", offsetof(entity_state_t, eflags));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int rendermode", offsetof(entity_state_t, rendermode));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int renderamt", offsetof(entity_state_t, renderamt));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector rendercolor", offsetof(entity_state_t, rendercolor));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int r", offsetof(entity_state_t, rendercolor.r));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int g", offsetof(entity_state_t, rendercolor.g));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int b", offsetof(entity_state_t, rendercolor.b));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int renderfx", offsetof(entity_state_t, renderfx));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int movetype", offsetof(entity_state_t, movetype));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float animtime", offsetof(entity_state_t, animtime));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float framerate", offsetof(entity_state_t, framerate));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int body", offsetof(entity_state_t, body));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector velocity", offsetof(entity_state_t, velocity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector mins", offsetof(entity_state_t, mins));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector maxs", offsetof(entity_state_t, maxs));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int aiment", offsetof(entity_state_t, aiment));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int owner", offsetof(entity_state_t, owner));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float friction", offsetof(entity_state_t, friction));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float gravity", offsetof(entity_state_t, gravity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int team", offsetof(entity_state_t, team));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int playerclass", offsetof(entity_state_t, playerclass));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int health", offsetof(entity_state_t, health));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int spectator", offsetof(entity_state_t, spectator));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int weaponmodel", offsetof(entity_state_t, weaponmodel));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int gaitsequence", offsetof(entity_state_t, gaitsequence));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector basevelocity", offsetof(entity_state_t, basevelocity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int usehull", offsetof(entity_state_t, usehull));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int oldbuttons", offsetof(entity_state_t, oldbuttons));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int onground", offsetof(entity_state_t, onground));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iStepLeft", offsetof(entity_state_t, iStepLeft));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float flFallVelocity", offsetof(entity_state_t, flFallVelocity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fov", offsetof(entity_state_t, fov));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int weaponanim", offsetof(entity_state_t, weaponanim));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser1", offsetof(entity_state_t, iuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser2", offsetof(entity_state_t, iuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser3", offsetof(entity_state_t, iuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "int iuser4", offsetof(entity_state_t, iuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser1", offsetof(entity_state_t, fuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser2", offsetof(entity_state_t, fuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser3", offsetof(entity_state_t, fuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "float fuser4", offsetof(entity_state_t, fuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser1", offsetof(entity_state_t, vuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser2", offsetof(entity_state_t, vuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser3", offsetof(entity_state_t, vuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "entity_state_t", "Vector vuser4", offsetof(entity_state_t, vuser4));
#pragma endregion
#pragma region physent_t
		ASEXT_RegisterObjectType(pASDoc, "Physics data", "physent_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
		//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "array<char>@ name", offsetof(physent_t, name));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int player", offsetof(physent_t, player));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector origin", offsetof(physent_t, origin));
		//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "model_t@ model", offsetof(physent_t, model));
		//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "model_t@ studiomodel", offsetof(physent_t, studiomodel));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector mins", offsetof(physent_t, mins));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector maxs", offsetof(physent_t, maxs));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int info", offsetof(physent_t, info));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector angles", offsetof(physent_t, angles));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int solid", offsetof(physent_t, solid));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int skin", offsetof(physent_t, skin));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int rendermode", offsetof(physent_t, rendermode));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float frame", offsetof(physent_t, frame));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int sequence", offsetof(physent_t, sequence));
		//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int controller", offsetof(physent_t, controller));
		//ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int blending", offsetof(physent_t, blending));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int movetype", offsetof(physent_t, movetype));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int takedamage", offsetof(physent_t, takedamage));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int blooddecal", offsetof(physent_t, blooddecal));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int team", offsetof(physent_t, team));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int classnumber", offsetof(physent_t, classnumber));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser1", offsetof(physent_t, iuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser2", offsetof(physent_t, iuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser3", offsetof(physent_t, iuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "int iuser4", offsetof(physent_t, iuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser1", offsetof(physent_t, fuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser2", offsetof(physent_t, fuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser3", offsetof(physent_t, fuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "float fuser4", offsetof(physent_t, fuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser1", offsetof(physent_t, vuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser2", offsetof(physent_t, vuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser3", offsetof(physent_t, vuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "physent_t", "Vector vuser4", offsetof(physent_t, vuser4));
#pragma endregion
#pragma region playermove_t
		ASEXT_RegisterObjectType(pASDoc, "Player movement data", "playermove_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int player_index", offsetof(playermove_t, player_index));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int server", offsetof(playermove_t, server));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int multiplayer", offsetof(playermove_t, multiplayer));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float time", offsetof(playermove_t, time));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float frametime", offsetof(playermove_t, frametime));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector forward", offsetof(playermove_t, forward));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector right", offsetof(playermove_t, right));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector up", offsetof(playermove_t, up));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector origin", offsetof(playermove_t, origin));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector angles", offsetof(playermove_t, angles));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector oldangles", offsetof(playermove_t, oldangles));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector velocity", offsetof(playermove_t, velocity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector movedir", offsetof(playermove_t, movedir));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector basevelocity", offsetof(playermove_t, basevelocity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector view_ofs", offsetof(playermove_t, view_ofs));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flDuckTime", offsetof(playermove_t, flDuckTime));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int bInDuck", offsetof(playermove_t, bInDuck));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int flTimeStepSound", offsetof(playermove_t, flTimeStepSound));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iStepLeft", offsetof(playermove_t, iStepLeft));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flFallVelocity", offsetof(playermove_t, flFallVelocity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector punchangle", offsetof(playermove_t, punchangle));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flSwimTime", offsetof(playermove_t, flSwimTime));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float flNextPrimaryAttack", offsetof(playermove_t, flNextPrimaryAttack));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int effects", offsetof(playermove_t, effects));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int flags", offsetof(playermove_t, flags));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int usehull", offsetof(playermove_t, usehull));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float gravity", offsetof(playermove_t, gravity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float friction", offsetof(playermove_t, friction));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int oldbuttons", offsetof(playermove_t, oldbuttons));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float waterjumptime", offsetof(playermove_t, waterjumptime));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int dead", offsetof(playermove_t, dead));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int deadflag", offsetof(playermove_t, deadflag));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int spectator", offsetof(playermove_t, spectator));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int movetype", offsetof(playermove_t, movetype));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int onground", offsetof(playermove_t, onground));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int waterlevel", offsetof(playermove_t, waterlevel));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int watertype", offsetof(playermove_t, watertype));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int oldwaterlevel", offsetof(playermove_t, oldwaterlevel));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "array<char>@ sztexturename", offsetof(playermove_t, sztexturename));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "char chtexturetype", offsetof(playermove_t, chtexturetype));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float maxspeed", offsetof(playermove_t, maxspeed));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float clientmaxspeed", offsetof(playermove_t, clientmaxspeed));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser1", offsetof(playermove_t, iuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser2", offsetof(playermove_t, iuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser3", offsetof(playermove_t, iuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int iuser4", offsetof(playermove_t, iuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser1", offsetof(playermove_t, fuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser2", offsetof(playermove_t, fuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser3", offsetof(playermove_t, fuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "float fuser4", offsetof(playermove_t, fuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser1", offsetof(playermove_t, vuser1));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser2", offsetof(playermove_t, vuser2));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser3", offsetof(playermove_t, vuser3));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "Vector vuser4", offsetof(playermove_t, vuser4));
		ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "int numphysent", offsetof(playermove_t, numphysent));
		ASEXT_RegisterObjectMethod(pASDoc, "", "playermove_t", "physent_t@ GetPhysEntByIndex(int index)", (void*)CASPlayerMove__GetPhysEntByIndex, asCALL_THISCALL);
		ASEXT_RegisterObjectMethod(pASDoc, "", "playermove_t", "void SetPhysEntByIndex(physent_t@ pPhyEnt, int newindex)", (void*)CASPlayerMove__SetPhysEntByIndex, asCALL_THISCALL);
		//ASEXT_RegisterObjectProperty(pASDoc, "", "playermove_t", "array<physent_t@>@ physents", offsetof(playermove_t, physents));
#pragma endregion
#pragma region META_RES
		ASEXT_RegisterEnum(pASDoc, "Flags returned by a plugin's api function.", "META_RES", 0);
		ASEXT_RegisterEnumValue(pASDoc, "", "META_RES", "Unset", (int)MRES_UNSET);
		ASEXT_RegisterEnumValue(pASDoc, "Plugin didn't take any action", "META_RES", "Ignored",(int)MRES_IGNORED);
		ASEXT_RegisterEnumValue(pASDoc, "Plugin did something, but real function should still be called", "META_RES", "Handled", (int)MRES_HANDLED);
		ASEXT_RegisterEnumValue(pASDoc, "Call real function, but use my return value", "META_RES", "Override", (int)MRES_OVERRIDE);
		ASEXT_RegisterEnumValue(pASDoc, "Skip real function; use my return value", "META_RES", "Supercede", (int)MRES_SUPERCEDE);
#pragma endregion
#pragma region addtofullpack_t
		/* addtofullpack_t */
		ASEXT_RegisterObjectType(pASDoc, "AddToFulPack data", "ClientPacket", 0, asOBJ_REF | asOBJ_NOCOUNT);
		ASEXT_RegisterObjectProperty(pASDoc, "", "ClientPacket", "entity_state_t@ state", offsetof(addtofullpack_t, state));
		ASEXT_RegisterObjectProperty(pASDoc, "", "ClientPacket", "int entityIndex", offsetof(addtofullpack_t, entityIndex));
		ASEXT_RegisterObjectProperty(pASDoc, "", "ClientPacket", "edict_t@ entity", offsetof(addtofullpack_t, entity));
		ASEXT_RegisterObjectProperty(pASDoc, "", "ClientPacket", "edict_t@ host", offsetof(addtofullpack_t, host));
		ASEXT_RegisterObjectProperty(pASDoc, "", "ClientPacket", "int hostFlags", offsetof(addtofullpack_t, hostFlags));
		ASEXT_RegisterObjectProperty(pASDoc, "", "ClientPacket", "int playerIndex", offsetof(addtofullpack_t, playerIndex));
		ASEXT_RegisterObjectProperty(pASDoc, "If set to true, the entity is not sent to the host", "ClientPacket", "bool SkipPacket", offsetof(addtofullpack_t, Result));
#pragma endregion
	} );
}
#undef REGISTE_OBJMETHODEX
#undef REGISTE_OBJMETHODPREX

#define CREATE_AS_HOOK(item, des, tag, name, arg) g_AngelHook.item=ASEXT_RegisterHook(des,StopMode_CALL_ALL,2,ASFlag_MapScript|ASFlag_Plugin,tag,name,arg)

void RegisterAngelScriptHooks()
{
	CREATE_AS_HOOK( pCientCommandHook,
		"Pre call of ClientCommand. See CEngineFuncs Cmd_Args, Cmd_Argv and Cmd_Argc",
		ASLP_NAMESPACE( Player ),
		"ClientCommand",
		"CBasePlayer@ player, META_RES &out meta_result"
	);
	CREATE_AS_HOOK( pPlayerUserInfoChanged,
		"Pre call before a player info changed",
		ASLP_NAMESPACE( Player ),
		"UserInfoChanged",
		"CBasePlayer@ player, string buffer, META_RES &out meta_result"
	);
	CREATE_AS_HOOK( pPreMovement,
		"Pre call of gEntityInterface.pfnPM_Move",
		ASLP_NAMESPACE( Player ),
		"PreMovement",
		"playermove_t@ &out pmove, META_RES &out meta_result"
	);
	CREATE_AS_HOOK( pPostMovement,
		"Pre call of gEntityInterface.pfnPM_Move",
		ASLP_NAMESPACE( Player ),
		"PostMovement",
		"playermove_t@ &out pmove, META_RES &out meta_result"
	);
	CREATE_AS_HOOK( pPreAddToFullPack,
		"Pre call of gEntityInterface.pfnAddToFullPack",
		ASLP_NAMESPACE( Player ),
		"PreAddToFullPack",
		"ClientPacket@ packet, META_RES &out meta_result"
	);
	CREATE_AS_HOOK( pPostAddToFullPack,
		"Post call of gEntityInterface.pfnAddToFullPack",
		ASLP_NAMESPACE( Player ),
		"PostAddToFullPack",
		"ClientPacket@ packet, META_RES &out meta_result"
	);
	CREATE_AS_HOOK( pPostEntitySpawn,
		"Post call after a Entity spawn",
		ASLP_NAMESPACE( Entity ),
		"PostEntitySpawn",
		"edict_t@ pEntity"
	);
	CREATE_AS_HOOK( pShouldCollide,
		"Pre call of gEntityInterface.pfnShouldCollide",
		ASLP_NAMESPACE( Entity ),
		"ShouldCollide",
		"CBaseEntity@ touched, CBaseEntity@ other, META_RES &out meta_result, bool &out Collide"
	);

	CREATE_AS_HOOK(pPlayerPostTakeDamage, "Pre call before a player took damage", "Player", "PlayerPostTakeDamage", "DamageInfo@ info");
	CREATE_AS_HOOK(pPlayerTakeHealth, "Pre call before a player took health", "Player", "PlayerTakeHealth", "HealthInfo@ info");

	CREATE_AS_HOOK(pEntityIRelationship, "Pre call before checking relation", "Entity", "IRelationship", "CBaseEntity@ pEntity, CBaseEntity@ pOther, bool param, int& out newValue");

	CREATE_AS_HOOK(pMonsterTraceAttack, "Pre call before a monster trace attack", "Monster", "MonsterTraceAttack", "CBaseMonster@ pMonster, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType");
	CREATE_AS_HOOK(pMonsterPostTakeDamage, "Post call after a monster took damage", "Monster", "MonsterPostTakeDamage", "DamageInfo@ info");

	CREATE_AS_HOOK(pBreakableTraceAttack, "Pre call before a breakable trace attack","Entity", "BreakableTraceAttack", "CBaseEntity@ pBreakable, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType");
	CREATE_AS_HOOK(pBreakableKilled, "Pre call before a breakable died", "Entity", "BreakableDie", "CBaseEntity@ pBreakable, entvars_t@ pevAttacker, int iGib");
	CREATE_AS_HOOK(pBreakableTakeDamage, "Pre call before a breakable took damage", "Entity", "BreakableTakeDamage", "DamageInfo@ info");

	CREATE_AS_HOOK(pGrappleCheckMonsterType, "Pre call before Weapon Grapple checking monster type", "Weapon", "GrappleGetMonsterType", "CBaseEntity@ pThis, CBaseEntity@ pEntity, uint& out flag");
	//CREATE_AS_HOOK(pSendScoreInfo, "Pre call before sending hud info to edict", "Player", "SendScoreInfo", "CBasePlayer@ pPlayer, edict_t@ pTarget, int iTeamID, string szTeamName, uint& out flag");
}
#undef CREATE_AS_HOOK

void CloseAngelScriptsItem() 
{
	CASSQLite::CloseSQLite3DLL();
}