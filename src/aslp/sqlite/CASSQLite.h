#pragma once
#include <string>

#include "CASBaseObject.h"

struct sqlite3;
typedef int (*fnSqlCallBack)(void*[], int, char**, char**);

class CASSQLite : public CASBaseGCObject
{
public:
	CASSQLite(CString* szPath, int iMode);
	static CASSQLite* Factory(CString* szPath, int iMode);
	static int Sqlite3Callback(void* param[], int column_size, char* column_value[], char* column_name[]);
	static void LoadSQLite3DLL();
	static void CloseSQLite3DLL();

	int Open();
	int ExecSync(CString* sql, CASSQLGrid** gridOut, CString* errMsg);
	int Exec(CString* sql, CString* errMsg);
	int ExecWithCallBack(CString* sql, aslScriptFunction* pfnCallBack, void* any, CString* errMsg);
	void Close();

	~CASSQLite();
private:
	int Call(CString* sql, fnSqlCallBack pfnSqlCallBack, aslScriptFunction* pfnCallBack, void* any, CString* errMsg);
	sqlite3* m_pDatabase = nullptr;
	bool m_bClosed = false;
	bool m_bAviliable = false;
	std::string m_szStoredPath;
	int m_iMode = 0;

	asITypeInfo* m_pItemInfo;
};