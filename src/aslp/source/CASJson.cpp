#include <string>
#include <bit>

#include <extdll.h>
#include "angelscript.h"

#include <meta_api.h>

#include "CASJson.h"

class CScriptArray;

CASJson::CASJson() 
{
    js_info = new json();
	engine = ASEXT_GetServerManager()->scriptEngine;
    m_pJsonValueInfo = engine->GetTypeInfoByName("JsonValue");
}

CASJson::~CASJson() 
{
    if (js_info) 
    {
        js_info->clear();
        delete js_info;
    }
}

CASJson* CASJson::Factory() 
{
    CASJson* obj = new CASJson();
    ASEXT_GetServerManager()->scriptEngine->NotifyGarbageCollectorOfNewObject(obj, obj->m_pJsonValueInfo);
    return obj;
}

CASJson* CASJson::Factory(const json& js) 
{
    CASJson* obj = new CASJson();
    if (obj->js_info) 
        *(obj->js_info) = js;

    ASEXT_GetServerManager()->scriptEngine->NotifyGarbageCollectorOfNewObject(obj, obj->m_pJsonValueInfo);
    return obj;
}

CASJson& CASJson::operator=(bool other) { *js_info = other; return *this; }
CASJson& CASJson::operator=(asINT64 other) { *js_info = other; return *this; }
CASJson& CASJson::operator=(double other) { *js_info = other; return *this; }
CASJson& CASJson::operator=(const CString& other) { *js_info = other.c_str(); return *this; }
CASJson& CASJson::operator=(const CASJson& other) { if (this != &other) { *js_info = *other.js_info; } return *this; }

CASJson& CASJson::operator=(const CScriptArray& other) 
{
    json js_temp = json::array();
    asITypeInfo* elementType = engine->GetTypeInfoById(other.m_ElementTypeId);

    if (!elementType) 
    {
        ALERT(at_console, "%s %s %s.\n", "[JSON ERROR]", "operator=:", "No se pudo obtener el tipo de elemento del array.");
        *js_info = js_temp;
        return *this;
    }

    if(elementType->GetName() != m_pJsonValueInfo->GetName())
    {
        ALERT(at_console, "%s %s %s '%s'.\n", "[JSON ERROR]", "operator=:", "El tipo de elemento no es valido:", elementType->GetName());
        *js_info = js_temp;
        return *this;
    }

    asITypeInfo* arrayType = engine->GetTypeInfoByDecl(std::string("array<" + std::string(elementType->GetName()) + "@>").c_str());

    if (arrayType)
    {
        asIScriptFunction* opIndex = arrayType->GetMethodByName("opIndex");
        asIScriptFunction* length = arrayType->GetMethodByName("length");

        if (opIndex && length) 
        {
            try
            {
                asIScriptContext* ctx = engine->RequestContext();

                ctx->Prepare(length);
                ctx->SetObject((void*)&other);
                ctx->Execute();
                asUINT size = ctx->GetReturnDWord();

                for (asUINT i = 0; i < size; i++) 
                {
                    ctx->Prepare(opIndex);
                    ctx->SetObject((void*)&other);
                    ctx->SetArgDWord(0, i);
                    ctx->Execute();

                    void** objPtr = (void**)ctx->GetReturnAddress();
                    if (objPtr && *objPtr) 
                    {
                        CASJson* node = (CASJson*)*objPtr;
                        if (node && node->js_info) 
                        {
                            js_temp.push_back(*(node->js_info));
                        }
                    }
                }
                engine->ReturnContext(ctx);
            }
            catch (const std::exception& e) 
            {
                ALERT(at_console, "%s %s %s.\n", "[JSON CRASH]", "Excepción de C++ capturada en operator=:", e.what());
            }
            catch (...) 
            {
                ALERT(at_console, "%s %s.\n", "[JSON CRASH]", "Excepción desconocida capturada en operator=.");
            }
        }
    }

    *js_info = js_temp;

    return *this;
}

void CASJson::Set(const jsonKey_t& key, bool value) { (*js_info)[key.c_str()] = value; }
void CASJson::Set(const jsonKey_t& key, asINT64 value) { (*js_info)[key.c_str()] = value; }
void CASJson::Set(const jsonKey_t& key, double value) { (*js_info)[key.c_str()] = value; }
void CASJson::Set(const jsonKey_t& key, const CString& value) { (*js_info)[key.c_str()] = value.c_str(); }

void CASJson::Set(const jsonKey_t& key, const CScriptArray& value) {
    CASJson tempJson;
    tempJson = value;
    (*js_info)[key.c_str()] = *tempJson.js_info;
}

bool CASJson::Get(const jsonKey_t& key, bool& value) const
{
    if (js_info->contains(key.c_str()) && (*js_info)[key.c_str()].is_boolean())
    {
        value = (*js_info)[key.c_str()].get<bool>();
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, asINT64& value) const
{
    if (js_info->contains(key.c_str()) && (*js_info)[key.c_str()].is_number())
    {
        value = (*js_info)[key.c_str()].get<asINT64>();
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, double& value) const
{
    if (js_info->contains(key.c_str()) && (*js_info)[key.c_str()].is_number())
    {
        value = (*js_info)[key.c_str()].get<double>();
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, CString& value) const
{
    if (js_info->contains(key.c_str()) && (*js_info)[key.c_str()].is_string())
    {
        std::string strvalue = (*js_info)[key.c_str()].get<std::string>();
        value.assign(strvalue.c_str(), strvalue.length());
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, CScriptArray& value) const {

    if (js_info->contains(key.c_str()) && (*js_info)[key.c_str()].is_array())
    {
        asITypeInfo* arrayType = engine->GetTypeInfoById(value.m_ElementTypeId);
        asITypeInfo* arrayInfo = engine->GetTypeInfoByDecl(std::string("array<" + std::string(arrayType->GetName()) + "@>").c_str()); //array<JsonValue@>
        asIScriptFunction* resizeFunc = arrayInfo->GetMethodByName("resize");
        asIScriptFunction* insertLast = arrayInfo->GetMethodByName("insertLast");
        asIScriptContext* ctx = engine->RequestContext();

        try
        {
            ctx->Prepare(resizeFunc);
            ctx->SetObject(&value);
            ctx->SetArgDWord(0, 0);
            ctx->Execute();

            const json& js_array = (*js_info)[key.c_str()];
            for (const auto& item : js_array) {
                CASJson* childNode = CASJson::Factory(item);
                if (!childNode) {
                    continue;
                }

                ctx->Prepare(insertLast);
                ctx->SetObject(&value);
                ctx->SetArgObject(0, &childNode);
                int r = ctx->Execute();
                if (r != asEXECUTION_FINISHED) {
                    ALERT(at_console, "%s %s %d.\n", "[JSON ERROR]", "Execute en insertLast falló con código", r);
                }

                childNode->Release();
            }

            engine->ReturnContext(ctx);
        }
        catch (const std::exception& e) {
            ALERT(at_console, "%s %s %s.\n", "[JSON CRASH]", "Excepción de C++ capturada en Get:", e.what());
            return false;
        }
        catch (...) {
            ALERT(at_console, "%s %s.\n", "[JSON CRASH]", "Excepción desconocida capturada en Get. ¡Esto es grave!");
            return false;
        }
    }

    return true;
}

bool CASJson::GetBool() const { return js_info->is_boolean() ? js_info->get<bool>() : false; }
int CASJson::GetNumber() const { return js_info->is_number() ? js_info->get<int>() : 0; }
double CASJson::GetReal() const { return js_info->is_number() ? js_info->get<double>() : 0.0; }

CString& CASJson::GetString() const
{
    const std::string source = js_info->is_string() ? js_info->get<std::string>() : "";
    CString* result = new CString();
    result->assign(source.c_str(), source.length());
    return *result;
}

CScriptArray* CASJson::GetArray() const 
{
    if (!js_info->is_array()) 
        return nullptr;

    asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<JsonValue@>");
    CScriptArray* retVal = (CScriptArray*)engine->CreateScriptObject(arrayType);

    if (retVal)
    {
        json temp_json_obj;
        temp_json_obj["temp_array"] = *js_info;

        CASJson temp_cas_json;
        *temp_cas_json.js_info = temp_json_obj;

        const std::string source = "temp_array";
        CString* result = new CString();
        result->assign(source.c_str(), source.length());
        temp_cas_json.Get(*result, *retVal);
    }

    return retVal;
}

CASJson* CASJson::opIndex(const jsonKey_t& key)
{
    if (!js_info->contains(key.c_str()))
    {
        (*js_info)[key.c_str()] = json::object();
    }
    return Factory((*js_info)[key.c_str()]);
}

const CASJson* CASJson::opIndex_const(const jsonKey_t& key) const
{
    if (js_info->contains(key.c_str()))
    {
        return Factory((*js_info)[key.c_str()]);
    }
    return nullptr;
}

bool CASJson::Exists(const jsonKey_t& key) const { return js_info->contains(key.c_str()); }
bool CASJson::IsEmpty() const { return js_info->empty(); }
asUINT CASJson::GetSize() const { return js_info->size(); }
void CASJson::Clear() { js_info->clear(); }

CASJsonType CASJson::Type() const
{
    switch (js_info->type())
    {
        case json::value_t::object: return OBJECT_VALUE;
        case json::value_t::array: return ARRAY_VALUE;
        case json::value_t::string: return STRING_VALUE;
        case json::value_t::boolean: return BOOLEAN_VALUE;
        case json::value_t::number_integer:
        case json::value_t::number_unsigned: return NUMBER_VALUE;
        case json::value_t::number_float: return REAL_VALUE;
        default: return NULL_VALUE;
    }
}