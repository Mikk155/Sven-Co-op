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

angelhook_t g_AngelHook;

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

CASJson* SC_SERVER_DECL CASEngineFuncs_JsonParse(void* pthis, SC_SERVER_DUMMYARG CString* szBuffer)
{
	json js_data = json::parse((char*)szBuffer->c_str());
	return CASJson::Factory(js_data);;
}

std::string SC_SERVER_DECL CASEngineFuncs_JsonWrite(void* pthis, const CASJson& node)
{
	if (node.js_info) {
		return node.js_info->dump(1, '\t');
	}
	return "";
}

/// <summary>
/// Regiter
/// </summary>
#define REGISTE_OBJMETHODEX(r, d, e, c, m, cc, mm, call) r=asMETHOD(cc,mm);ASEXT_RegisterObjectMethodEx(d,e,c,m,&r,call)
#define REGISTE_OBJMETHODPREX(r, d, e, c, m, cc, mm, pp, rr, call) r=asMETHODPR(cc,mm, pp, rr);ASEXT_RegisterObjectMethodEx(d,e,c,m,&r,call)
void RegisterAngelScriptMethods() 
{
	CASSQLite::LoadSQLite3DLL();

	ASEXT_RegisterDocInitCallback([](CASDocumentation* pASDoc) 
	{
		//Regist HealthInfo type
		ASEXT_RegisterObjectType(pASDoc, "Entity takehealth info", "HealthInfo", 0, asOBJ_REF | asOBJ_NOCOUNT);
		ASEXT_RegisterObjectProperty(pASDoc, "Who get healing?", "HealthInfo", "CBaseEntity@ pEntity", offsetof(healthinfo_t, pEntity));
		ASEXT_RegisterObjectProperty(pASDoc, "Recover amount.", "HealthInfo", "float flHealth", offsetof(healthinfo_t, flHealth));
		ASEXT_RegisterObjectProperty(pASDoc, "Recover dmg type.", "HealthInfo", "int bitsDamageType", offsetof(healthinfo_t, bitsDamageType));
		ASEXT_RegisterObjectProperty(pASDoc, "If health_cap is non-zero, won't add more than health_cap. Returns true if it took damage, false otherwise.", "HealthInfo", "int health_cap", offsetof(healthinfo_t, health_cap));
		
		//CBinaryStringBuilder
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

		//CSQLite
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
		REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL In Sync", "CSQLite", "SQLiteResult Exec(string&in sql, CSQLGrid@&out aryResult, string&out errMsg)", CASSQLite, ExecSync, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Excute SQL", "CSQLite", "SQLiteResult Exec(string&in sql, fnSQLiteCallback@ pCallback, any@ pCallBackparam, string&out errMsg)", CASSQLite, ExecWithCallBack, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Close SQL", "CSQLite", "void Close()", CASSQLite, Close, asCALL_THISCALL);

		//CASJson
		//Enum
		ASEXT_RegisterEnum(pASDoc, "JSON Value Type", "JsonType", 0);
		ASEXT_RegisterEnumValue(pASDoc, "Object", "JsonType", "OBJECT_VALUE", OBJECT_VALUE);
		ASEXT_RegisterEnumValue(pASDoc, "Array", "JsonType", "ARRAY_VALUE", ARRAY_VALUE);
		ASEXT_RegisterEnumValue(pASDoc, "Boolean", "JsonType", "BOOLEAN_VALUE", BOOLEAN_VALUE);
		ASEXT_RegisterEnumValue(pASDoc, "String", "JsonType", "STRING_VALUE", STRING_VALUE);
		ASEXT_RegisterEnumValue(pASDoc, "Integer Number", "JsonType", "NUMBER_VALUE", NUMBER_VALUE);
		ASEXT_RegisterEnumValue(pASDoc, "Real Number", "JsonType", "REAL_VALUE", REAL_VALUE);
		ASEXT_RegisterEnumValue(pASDoc, "Null", "JsonType", "NULL_VALUE", NULL_VALUE);

		//Class
		ASEXT_RegisterObjectType(pASDoc, "JSON Value Object", "json", 0, asOBJ_REF | asOBJ_GC);
		reg = asFUNCTIONPR(CASJson::Factory, (), CASJson*);
		ASEXT_RegisterObjectBehaviourEx(pASDoc, "Factory", "json", asBEHAVE_FACTORY, "json@ f()", &reg, asCALL_CDECL);
		RegisteGCObject<CASJson>(pASDoc, "json");
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a boolean", "json", "json& opAssign(bool)", CASJson, operator=, (bool), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign an integer", "json", "json& opAssign(int64)", CASJson, operator=, (asINT64), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a real number", "json", "json& opAssign(double)", CASJson, operator=, (double), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a string", "json", "json& opAssign(const string&in)", CASJson, operator=, (const CString&), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign another json", "json", "json& opAssign(const json&in)", CASJson, operator=, (const CASJson&), CASJson&, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Assign a array of json", "json", "json& opAssign(const array<json@>&in)", CASJson, operator=, (const CScriptArray&), CASJson&, asCALL_THISCALL);

		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "json", "void Set(const string&in, bool)", CASJson, Set, (const jsonKey_t&, bool), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "json", "void Set(const string&in, int64)", CASJson, Set, (const jsonKey_t&, asINT64), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "json", "void Set(const string&in, double)", CASJson, Set, (const jsonKey_t&, double), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "json", "void Set(const string&in, const string&in)", CASJson, Set, (const jsonKey_t&, const CString&), void, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Set a key/value pair", "json", "void Set(const string&in, array<json@>&in)", CASJson, Set, (const jsonKey_t&, const CScriptArray&), void, asCALL_THISCALL);

		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "json", "bool Get(const string&in, bool&out) const", CASJson, Get, (const jsonKey_t&, bool&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "json", "bool Get(const string&in, int64&out) const", CASJson, Get, (const jsonKey_t&, asINT64&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "json", "bool Get(const string&in, double&out) const", CASJson, Get, (const jsonKey_t&, double&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "json", "bool Get(string&in, string&out) const", CASJson, Get, (const jsonKey_t&, CString&) const, bool, asCALL_THISCALL);
		REGISTE_OBJMETHODPREX(reg, pASDoc, "Get a value by key", "json", "bool Get(string&in, array<json@>@ const) const", CASJson, Get, (const jsonKey_t&, CScriptArray&) const, bool, asCALL_THISCALL);

		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to boolean", "json", "bool opConv()", CASJson, GetBool, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to string", "json", "string& opConv()", CASJson, GetString, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to integer", "json", "int opConv()", CASJson, GetNumber, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to real number", "json", "double opConv()", CASJson, GetReal, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Convert to array", "json", "array<json@>@ opConv()", CASJson, GetArray, asCALL_THISCALL);

		REGISTE_OBJMETHODEX(reg, pASDoc, "Access value by key", "json", "json& opIndex(const string&in)", CASJson, opIndex, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Access value by key (const)", "json", "const json& opIndex(const string&in) const", CASJson, opIndex_const, asCALL_THISCALL);

		REGISTE_OBJMETHODEX(reg, pASDoc, "Check if a key exists", "json", "bool Exists(const string&in) const", CASJson, Exists, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Check if the object is empty", "json", "bool IsEmpty() const", CASJson, IsEmpty, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get the number of elements", "json", "uint GetSize() const", CASJson, GetSize, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Clear all elements", "json", "void Clear()", CASJson, Clear, asCALL_THISCALL);
		REGISTE_OBJMETHODEX(reg, pASDoc, "Get the value type", "json", "JsonType Type() const", CASJson, Type, asCALL_THISCALL);

		//Regist New Method
		ASEXT_RegisterObjectMethod(pASDoc,
			"", "CEngineFuncs", "json@ JsonParse(const string& in szBuffer)",
			(void*)CASEngineFuncs_JsonParse, asCALL_THISCALL);
		ASEXT_RegisterObjectMethod(pASDoc,
			"", "CEngineFuncs", "string JsonWrite(const json&in)",
			(void*)CASEngineFuncs_JsonWrite, asCALL_THISCALL);

		ASEXT_RegisterObjectMethod(pASDoc,
			"Caculate CRC32 for a string", "CEngineFuncs", "uint32 CRC32(const string& in szBuffer)",
			(void*)CASEngineFuncs_CRC32, asCALL_THISCALL);
		ASEXT_RegisterObjectMethod(pASDoc,
			"copy class, If src and dst are different type, return false.\nIf not class ref, crash game.", "CEngineFuncs", "bool ClassMemcpy(?& in src, ?& in dst)",
			(void*)CASEngineFuncs_ClassMemcpy, asCALL_THISCALL);
	});
}
#undef REGISTE_OBJMETHODEX
#undef REGISTE_OBJMETHODPREX

#define CREATE_AS_HOOK(item, des, tag, name, arg) g_AngelHook.item=ASEXT_RegisterHook(des,StopMode_CALL_ALL,2,ASFlag_MapScript|ASFlag_Plugin,tag,name,arg)
void RegisterAngelScriptHooks(){
	CREATE_AS_HOOK(pPlayerUserInfoChanged, "Pre call before a player info changed", "Player", "PlayerUserInfoChanged", "CBasePlayer@ pClient, string szInfoBuffer, uint&out uiFlag");
	CREATE_AS_HOOK(pPlayerPostTakeDamage, "Pre call before a player took damage", "Player", "PlayerPostTakeDamage", "DamageInfo@ info");
	CREATE_AS_HOOK(pPlayerTakeHealth, "Pre call before a player took health", "Player", "PlayerTakeHealth", "HealthInfo@ info");
	CREATE_AS_HOOK(pPlayerCallMedic, "Pre call before a player call medic", "Player", "PlayerCallMedic", "CBasePlayer@ pPlayer");
	CREATE_AS_HOOK(pPlayerCallGrenade, "Pre call before a player call grenade", "Player", "PlayerCallGrenade", "CBasePlayer@ pPlayer");

	CREATE_AS_HOOK(pEntitySpawn, "Post call after a Entity spawn", "Entity", "EntitySpawn", "CBaseEntity@ pEntity");
	CREATE_AS_HOOK(pEntityIRelationship, "Pre call before checking relation", "Entity", "IRelationship", "CBaseEntity@ pEntity, CBaseEntity@ pOther, bool param, int& out newValue");

	CREATE_AS_HOOK(pMonsterSpawn, "Post call after a monster spawn", "Monster", "MonsterSpawn", "CBaseMonster@ pEntity");
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