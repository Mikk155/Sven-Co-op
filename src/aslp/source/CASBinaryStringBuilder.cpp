#include <string>
#include <bit>

#include <extdll.h>
#include "aslp.h"

#include <meta_api.h>
#include "CASBinaryStringBuilder.h"

CBinaryStringBuilder::CBinaryStringBuilder(){
	refCount = 1;
	asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
	m_pStrInfo = engine->GetTypeInfoByDecl("string");
	m_pVectorInfo = engine->GetTypeInfoByDecl("Vector");
}
CBinaryStringBuilder* CBinaryStringBuilder::Factory() {
	CBinaryStringBuilder* obj = new CBinaryStringBuilder();
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	asITypeInfo* type = engine->GetTypeInfoByName("CBinaryStringBuilder");
	engine->NotifyGarbageCollectorOfNewObject(obj, type);
	return obj;
}
CBinaryStringBuilder* CBinaryStringBuilder::ParamFactory(CString* str) {
	CBinaryStringBuilder* obj = new CBinaryStringBuilder();
	obj->Set(str);
	CASServerManager* manager = ASEXT_GetServerManager();
	asIScriptEngine* engine = manager->scriptEngine;
	asITypeInfo* type = engine->GetTypeInfoByName("CBinaryStringBuilder");
	engine->NotifyGarbageCollectorOfNewObject(obj, type);
	return obj;
}

void CBinaryStringBuilder::EnumReferences(asIScriptEngine* engine){
	for (auto iter = m_aryRef.begin(); iter != m_aryRef.end(); iter++) {
		engine->ForwardGCEnumReferences((*iter)->data, (*iter)->type);
	}
}

void CBinaryStringBuilder::ReleaseReferences(asIScriptEngine* engine){
	for (auto iter = m_aryRef.begin(); iter != m_aryRef.end(); iter++) {
		engine->ForwardGCReleaseReferences((*iter)->data, (*iter)->type);
		delete (*iter);
	}
	m_aryRef.clear();
}

CString CBinaryStringBuilder::Get(){
	asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
	CString* szOutBuffer = static_cast<CString*>(engine->CreateScriptObject(m_pStrInfo));
	char* temp = new char[m_szBuffer.size() + 1];
	std::copy(m_szBuffer.begin(), m_szBuffer.end(), temp);
	szOutBuffer->assign(temp, m_szBuffer.size());
	delete[] temp;
	GCRefObject* gcobj = new GCRefObject();
	gcobj->data = szOutBuffer;
	gcobj->value = true;
	gcobj->type = m_pStrInfo;
	m_aryRef.push_back(gcobj);
	return *szOutBuffer;
}
void CBinaryStringBuilder::Set(CString* buffer){
	m_szBuffer.clear();
	for (size_t i = 0; i < buffer->length(); i++) {
		m_szBuffer.push_back(buffer->chatAt(i));
	}
	m_iReadPointer = 0;
}
size_t CBinaryStringBuilder::GetReadPointer(){
	return m_iReadPointer;
}
void CBinaryStringBuilder::SetReadPointer(size_t pointer){
#ifdef _WIN32
#undef min
#endif // _WIN32
	m_iReadPointer = std::min(m_szBuffer.size(), pointer);
}
template <typename T>
void WriteBuffer(CBinaryStringBuilder* pThis, T value) {
	size_t length = sizeof(value);
	for (size_t i = 0; i < length; i++) {
		pThis->m_szBuffer.push_back(static_cast<unsigned char>(value << (i * 8) >> ((length - 1) * 8)));
	}
}
void CBinaryStringBuilder::WriteInt(int value){
	WriteBuffer(this, value);
}
void CBinaryStringBuilder::WriteLong(int64 value){
	WriteBuffer(this, value);
}
void CBinaryStringBuilder::WriteFloat(float value){
	WriteBuffer(this, std::bit_cast<int>(value));
}
void CBinaryStringBuilder::WriteDouble(double value){
	WriteBuffer(this, std::bit_cast<int64>(value));
}
void CBinaryStringBuilder::WriteVector(vec3_t value){
	WriteBuffer(this, std::bit_cast<int>(value.x));
	WriteBuffer(this, std::bit_cast<int>(value.y));
	WriteBuffer(this, std::bit_cast<int>(value.z));
}
void CBinaryStringBuilder::WriteString(CString* value){
	for (size_t i = 0; i < value->length(); i++) {
		m_szBuffer.push_back(value->chatAt(i));
	}
}
void CBinaryStringBuilder::WriteData(const char* value, size_t len){
	for (size_t i = 0; i < len; i++) {
		m_szBuffer.push_back(value[i]);
	}
}
template <typename T1, typename T2>
T1 ReadBuffer(CBinaryStringBuilder* pThis) {
	T2 temp = 0;
	size_t length = sizeof(T2);
	for (size_t i = 0; i < length; i++) {
		temp += static_cast<T2>(pThis->m_szBuffer[pThis->m_iReadPointer]) << ((length - 1 - i) * 8);
		pThis->m_iReadPointer++;
	}
	return std::bit_cast<T1>(temp);
}
int CBinaryStringBuilder::ReadInt(){
	return m_iReadPointer < m_szBuffer.size() ? ReadBuffer<int, int>(this) : 0;
}
int64 CBinaryStringBuilder::ReadLong(){
	return m_iReadPointer < m_szBuffer.size() ? ReadBuffer<int64, int64>(this) : 0;
}
float CBinaryStringBuilder::ReadFloat(){
	return m_iReadPointer < m_szBuffer.size() ? ReadBuffer<float, int>(this) : 0.0f;
}
double CBinaryStringBuilder::ReadDouble(){
	return m_iReadPointer < m_szBuffer.size() ? ReadBuffer<double, int64>(this) : 0.0;
}
vec3_t CBinaryStringBuilder::ReadVector(){
	asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
	vec3_t* vecBuffer = static_cast<vec3_t*>(engine->CreateScriptObject(m_pVectorInfo));
	GCRefObject* gcobj = new GCRefObject();
	gcobj->data = vecBuffer;
	gcobj->value = true;
	gcobj->type = m_pVectorInfo;
	m_aryRef.push_back(gcobj);
	vecBuffer->x = ReadBuffer<float, int>(this);
	vecBuffer->y = ReadBuffer<float, int>(this);
	vecBuffer->z = ReadBuffer<float, int>(this);
	return *vecBuffer;
}
CString CBinaryStringBuilder::ReadString(){
	std::string temp;
	for (size_t i = m_iReadPointer; i < m_szBuffer.size(); i++) {
		char c = m_szBuffer[m_iReadPointer];
		temp += c;
		m_iReadPointer++;
		if (c == '\0')
			break;
	}
	asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
	CString* szOutBuffer = static_cast<CString*>(engine->CreateScriptObject(m_pStrInfo));
	GCRefObject* gcobj = new GCRefObject();
	gcobj->data = szOutBuffer;
	gcobj->value = true;
	gcobj->type = m_pStrInfo;
	m_aryRef.push_back(gcobj);
	szOutBuffer->assign(temp.c_str(), temp.length());
	return *szOutBuffer;
}
bool CBinaryStringBuilder::IsReadToEnd(){
	return m_iReadPointer >= m_szBuffer.size();
}