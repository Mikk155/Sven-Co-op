#include "../string/CASBinaryStringBuilder.h"
#include "CASSQLGrid.h"

CASSQLGrid::CASSQLGrid(){

}

CASSQLGrid::~CASSQLGrid(){
	for (auto iter = m_aryData.begin(); iter != m_aryData.end(); iter++) {
		for (auto iter2 = (*iter).begin(); iter2 != (*iter).end(); iter2++) {
			(*iter2)->Release();
		}
		(*iter).clear();
	}
	m_aryData.clear();
}

CASSQLGrid* CASSQLGrid::Factory(size_t row, size_t column){
	CASSQLGrid* obj = new CASSQLGrid();
	obj->m_aryData.resize(row);
	for (auto iter = obj->m_aryData.begin(); iter != obj->m_aryData.end(); iter++) {
		(*iter).resize(column);
	}
	obj->m_iRow = row;
	obj->m_iColumn = column;
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	asITypeInfo* type = engine->GetTypeInfoByName("CSQLGrid");
	engine->NotifyGarbageCollectorOfNewObject(obj, type);
	return obj;
}

void CASSQLGrid::Set(size_t row, size_t column, CASSQLItem* pItem){
	m_aryData[row][column] = pItem;
}

CASSQLItem* CASSQLGrid::Get(size_t row, size_t column){
	if (row >= m_iRow || column >= m_iColumn)
		return nullptr;
	return m_aryData[row][column];
}
CASSQLItem* CASSQLGrid::opIndex(size_t row, size_t column){
	return Get(row, column);
}
size_t CASSQLGrid::Rows(){
	return m_iRow;
}
size_t CASSQLGrid::Columns(){
	return m_iColumn;
}
