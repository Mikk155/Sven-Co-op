#include <filesystem>

#include <extdll.h>
#include <meta_api.h>

#include "../string/CASBinaryStringBuilder.h"
#include "CASSQLItem.h"
#include "CASSQLGrid.h"
#include "CASSQLite.h"


typedef int(*fnSQLite3Open)(const char* filename, sqlite3** ppDb, int flags, const char* zVfs);
fnSQLite3Open SQLite3_Open;

typedef int(*fnSQLite3Exec)(sqlite3*,           /* An open database */
	const char* sql,                           /* SQL to be evaluated */
	fnSqlCallBack callback,  /* Callback function */
	void*,                                    /* 1st argument to callback */
	char** errmsg                              /* Error msg written here */);
fnSQLite3Exec SQLite3_Exec;

typedef int (*fnSQLite3GetTable)(
	sqlite3* db,          /* An open database */
	const char* zSql,     /* SQL to be evaluated */
	char*** pazResult,    /* Results of the query */
	int* pnRow,           /* Number of result rows written here */
	int* pnColumn,        /* Number of result columns written here */
	char** pzErrmsg       /* Error msg written here */);
fnSQLite3GetTable SQLite3_GetTable;

typedef int (*fnSQLite3FreeTable)(char** result);
fnSQLite3FreeTable SQLite3_FreeTable;

typedef int(*fnSQLite3Close)(sqlite3*);
fnSQLite3Close SQLite3_Close;

typedef void(*fnSQLite3Free)(void*);
fnSQLite3Free SQLite3_Free;

CASSQLite::CASSQLite(CString* szPath, int iMode){
	//not url and memory
	if ((iMode & 0x00000040) == 0 && (iMode & 0x00000080) == 0) {
		namespace fs = std::filesystem;
		std::string szNPath = szPath->c_str();
		szNPath = "./svencoop/scripts/plugins/store/" + szNPath;
		fs::path path = fs::relative(szNPath);
		if (path.native().starts_with(fs::relative("svencoop/scripts/plugins/store").native())) {
			if (!fs::exists(path.remove_filename()))
				fs::create_directories(path.remove_filename());
			m_szStoredPath = szNPath;
		}
	}
	else
		m_szStoredPath = szPath->c_str();

	m_iMode = iMode;
	SQLite3_Open(m_szStoredPath.c_str(), &m_pDatabase, m_iMode, nullptr);
	m_bAviliable = true;
	m_bClosed = false;

	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	m_pItemInfo = engine->GetTypeInfoByName("CSQLite");
}
CASSQLite* CASSQLite::Factory(CString* szPath, int iMode){
	CASSQLite* obj = new CASSQLite(szPath, iMode);
	ASEXT_GetServerManager()->scriptEngine->NotifyGarbageCollectorOfNewObject(obj, obj->m_pItemInfo);
	return obj;
}
int CASSQLite::Call(CString* sql, fnSqlCallBack callback, aslScriptFunction* pfnASCallBack, void* any, CString* errMsg) {
	if (m_bClosed)
		return 999;
	else if (!m_bAviliable)
		return 1;
	int iReturn;
	char* zErrMsg = nullptr;
	if (callback && pfnASCallBack && any) {
		void* param[2] = { pfnASCallBack , any };
		iReturn = SQLite3_Exec(m_pDatabase, sql->c_str(), callback, param, &zErrMsg);
	}
	else
		iReturn = SQLite3_Exec(m_pDatabase, sql->c_str(), nullptr, nullptr, &zErrMsg);
	if (zErrMsg) {
		errMsg->assign(zErrMsg, strlen(zErrMsg));
		SQLite3_Free(zErrMsg);
	}
	return iReturn;
}
int CASSQLite::Open(){
	if (!m_bClosed || !m_bAviliable)
		return 1;
	m_bClosed = false;
	return SQLite3_Open(m_szStoredPath.c_str(), &m_pDatabase, m_iMode, nullptr);
}
int CASSQLite::ExecSync(CString* sql, CASSQLGrid** gridOut, CString* errMsg){
	if (m_bClosed) 
		return 999;
	else if (!m_bAviliable)
		return 1;
	int iReturn = 0;
	char* zErrMsg = nullptr;
	char** pResult = nullptr;
	int nRow = 0;
	int nColumn = 0;
	iReturn = SQLite3_GetTable(m_pDatabase, sql->c_str(), &pResult, &nRow, &nColumn, &zErrMsg);
	if (iReturn != 0)
		return iReturn;
	CASSQLGrid* grid = CASSQLGrid::Factory(nRow + 1, nColumn);
	for (int i = 0; i <= nRow; i++){
		for (int j = 0; j < nColumn; j++){
			char* res = pResult[i * nColumn + j];
			//thee shall no be null in value, but could be in sqlite
			CASSQLItem* val = res == nullptr ? CASSQLItem::Factory() : CASSQLItem::ParamFactory(res);
			grid->Set(i, j, val);
		}
	}
	*gridOut = grid;
	if (zErrMsg) {
		errMsg->assign(zErrMsg, strlen(zErrMsg));
		SQLite3_Free(zErrMsg);
	}
	SQLite3_FreeTable(pResult);
	return iReturn;
}
int CASSQLite::Exec(CString* sql, CString* errMsg){
	return Call(sql, nullptr, nullptr, nullptr, errMsg);
}
int CASSQLite::ExecWithCallBack(CString* sql, aslScriptFunction* pfnASCallBack, void* any, CString* errMsg){
	return Call(sql, &Sqlite3Callback, pfnASCallBack, any, errMsg);
}
void CASSQLite::Close(){
	if (m_pDatabase) {
		SQLite3_Close(m_pDatabase);
		m_pDatabase = nullptr;
	}
	m_bClosed = true;
	m_bAviliable = false;
}
CASSQLite::~CASSQLite(){
	Close();
}
int CASSQLite::Sqlite3Callback(void* param[], int column_size, char* column_value[], char* column_name[]) {
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	asIScriptContext* ctx = engine->RequestContext();

    asITypeInfo* aryInfo = engine->GetTypeInfoByDecl("array<CSQLItem@>");
	asIScriptFunction* funcAryInsert = aryInfo->GetMethodByName("insertLast");

	void* aryVal = engine->CreateScriptObject(aryInfo);
	void* aryName = engine->CreateScriptObject(aryInfo);
	for (int i = 0; i < column_size; i++){
		ctx->Prepare(funcAryInsert);
		ctx->SetObject(aryVal);
		char* res = column_value[i];
		CASSQLItem* val = res == nullptr ? CASSQLItem::Factory() : CASSQLItem::ParamFactory(res);
		ctx->SetArgObject(0, &val);
		ctx->Execute();

		ctx->Prepare(funcAryInsert);
		ctx->SetObject(aryName);
		res = column_name[i];
		CASSQLItem* name = res == nullptr ? CASSQLItem::Factory() : CASSQLItem::ParamFactory(res);
		ctx->SetArgObject(0, &name);
		ctx->Execute();
	}
	aslScriptFunction* pfnASCallBack = static_cast<aslScriptFunction*>(param[0]);
	CASFunction* m_callback = ASEXT_CreateCASFunction(pfnASCallBack, ASEXT_GetServerManager()->curModule, 1);
	(*ASEXT_CallCASBaseCallable)(m_callback, 0, param[1], column_size, aryVal, aryName);
	engine->ReleaseScriptObject(aryVal, aryInfo);
	engine->ReleaseScriptObject(aryName, aryInfo);
	return 0;
}

DLHANDLE pSqlite3DLLHandle;
void CASSQLite::LoadSQLite3DLL(){
	pSqlite3DLLHandle = DLOPEN(
#ifdef _WIN32
		"svencoop/sqlite3.dll"
#else
		"svencoop/dlls/libsqlite3.so"
#endif
	);
#define DLSYM_SQLite(pfn, handle, name) pfn = (decltype(pfn))DLSYM(handle, name)
	DLSYM_SQLite(SQLite3_Open, pSqlite3DLLHandle, "sqlite3_open_v2");
	DLSYM_SQLite(SQLite3_GetTable, pSqlite3DLLHandle, "sqlite3_get_table");
	DLSYM_SQLite(SQLite3_FreeTable, pSqlite3DLLHandle, "sqlite3_free_table");
	DLSYM_SQLite(SQLite3_Exec, pSqlite3DLLHandle, "sqlite3_exec");
	DLSYM_SQLite(SQLite3_Close, pSqlite3DLLHandle, "sqlite3_close");
	DLSYM_SQLite(SQLite3_Free, pSqlite3DLLHandle, "sqlite3_free");
#undef DLSYM_SQLite
}

void CASSQLite::CloseSQLite3DLL() {
	DLCLOSE(pSqlite3DLLHandle);
}
