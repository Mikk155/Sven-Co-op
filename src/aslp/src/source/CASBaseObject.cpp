#include "CASBaseObject.h"

void CASBaseRefObject::AddRef(){
	refCount++;
}
void CASBaseRefObject::Release(){
	if (--refCount == 0)
		delete this;
}

void CASBaseGCObject::AddRef() {
	refCount = (refCount & 0x7FFFFFFF) + 1;
}
void CASBaseGCObject::Release() {
	refCount &= 0x7FFFFFFF;
	if (--refCount == 0)
		delete this;
}
void CASBaseGCObject::SetGCFlag() {
	refCount |= 0x80000000;
}
bool CASBaseGCObject::GetGCFlag() {
	return (refCount & 0x80000000) ? true : false;
}
int CASBaseGCObject::GetRefCount() {
	return (refCount & 0x7FFFFFFF);
}
void CASBaseGCObject::EnumReferences(asIScriptEngine* engine) {
}
void CASBaseGCObject::ReleaseReferences(asIScriptEngine* engine) {
}