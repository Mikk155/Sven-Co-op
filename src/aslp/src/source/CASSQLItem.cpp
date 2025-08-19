#include "CASBinaryStringBuilder.h"
#include "CASSQLItem.h"

CASSQLItem::CASSQLItem(){
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	m_pBlobInfo = engine->GetTypeInfoByDecl("CBinaryStringBuilder");
	m_bIsNull = true;
}

CASSQLItem::~CASSQLItem(){
	m_szData.clear();
}

CASSQLItem* CASSQLItem::Factory(){
	CASSQLItem* obj = new CASSQLItem();
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	asITypeInfo* type = engine->GetTypeInfoByName("CSQLItem");
	engine->NotifyGarbageCollectorOfNewObject(obj, type);
	return obj;
}

CASSQLItem* CASSQLItem::ParamFactory(char* str){
	CASSQLItem* pItem = Factory();
	pItem->SetData(str);
	return pItem;
}

void CASSQLItem::SetData(char* str){
	m_szData = str;
	m_bIsNull = false;
}

void CASSQLItem::Get(CString* str){
	if (m_bIsNull)
		str->assign("", 0);
	else
		str->assign(m_szData.c_str(), m_szData.size());
}

int64 CASSQLItem::GetInt64(){
	return m_bIsNull ? 0 : std::atoll(m_szData.c_str());
}

int32 CASSQLItem::GetInt(){
	return m_bIsNull ? 0 : std::atoi(m_szData.c_str());
}

uint64 CASSQLItem::GetUInt64(){
	return m_bIsNull ? 0 : std::strtoull(m_szData.c_str(), nullptr, 10);
}

uint32 CASSQLItem::GetUInt(){
	//ILP32 so... yeah, thats fine
	return m_bIsNull ? 0 : std::strtoul(m_szData.c_str(), nullptr, 10);
}

double CASSQLItem::GetReal(){
	return m_bIsNull ? 0.0 : std::atof(m_szData.c_str());
}

CBinaryStringBuilder* CASSQLItem::GetBlob(){
	if (m_bIsNull)
		return nullptr;
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	CBinaryStringBuilder* pBlob = static_cast<CBinaryStringBuilder*>(engine->CreateScriptObject(m_pBlobInfo));
	pBlob->WriteData(m_szData.c_str(), m_szData.size());
	return pBlob;
}

bool CASSQLItem::IsNull(){
	return m_bIsNull;
}
