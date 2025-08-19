#include <string>
#include <bit>

#include <extdll.h>
#include "angelscript.h"

#include <meta_api.h>

#include "CASJson.h"

CASJson* CASJson::Factory()
{
    CASJson* obj = new CASJson();
    asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
    asITypeInfo* type = engine->GetTypeInfoByName("JsonValue");
    engine->NotifyGarbageCollectorOfNewObject(obj, type);
    return obj;
}

CASJson* CASJson::Factory(json js)
{
    CASJson* obj = new CASJson();
    *(obj->js_info) = js;
    asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
    asITypeInfo* type = engine->GetTypeInfoByName("JsonValue");
    engine->NotifyGarbageCollectorOfNewObject(obj, type);
    return obj;
}

// --- Constructor / Destructor ---

CASJson::CASJson()
{
    js_info = new json();
}

CASJson::~CASJson()
{
    if (js_info)
    {
        delete js_info;
        js_info = nullptr;
    }
}

// --- Operadores de Asignación ---

CASJson& CASJson::operator=(bool other)
{
    *js_info = other;
    return *this;
}

CASJson& CASJson::operator=(asINT64 other)
{
    *js_info = other;
    return *this;
}

CASJson& CASJson::operator=(double other)
{
    *js_info = other;
    return *this;
}

CASJson& CASJson::operator=(const std::string& other)
{
    *js_info = other;
    return *this;
}

CASJson& CASJson::operator=(const CASJson& other)
{
    if (this != &other)
    {
        *js_info = *other.js_info;
    }
    return *this;
}

CASJson& CASJson::operator=(const CScriptArray& other)
{
    json js_temp = json::array({});
    CScriptArray& non_const_other = const_cast<CScriptArray&>(other);
    void* array_base = non_const_other.data();
    size_t element_size = sizeof(CASJson*);

    for (asUINT i = 0; i < non_const_other.size(); i++)
    {
        CASJson** node = (CASJson**)((char*)array_base + (i * element_size));
        if (node && *node)
        {
            js_temp.push_back(*(*node)->js_info);
        }
    }
    *js_info = js_temp;
    return *this;
}

// --- Métodos Set y Get (con lógica de array corregida) ---

void CASJson::Set(const jsonKey_t& key, bool value) { (*js_info)[key] = value; }
void CASJson::Set(const jsonKey_t& key, asINT64 value) { (*js_info)[key] = value; }
void CASJson::Set(const jsonKey_t& key, double value) { (*js_info)[key] = value; }
void CASJson::Set(const jsonKey_t& key, const std::string& value) { (*js_info)[key] = value; }

void CASJson::Set(const jsonKey_t& key, const CScriptArray& value)
{
    json js_temp = json::array({});
    CScriptArray& non_const_value = const_cast<CScriptArray&>(value);
    void* array_base = non_const_value.data();
    size_t element_size = sizeof(CASJson*);

    for (asUINT i = 0; i < non_const_value.size(); i++)
    {
        CASJson** node = (CASJson**)((char*)array_base + (i * element_size));
        if (node && *node)
        {
            js_temp.push_back(*(*node)->js_info);
        }
    }
    (*js_info)[key] = js_temp;
}

bool CASJson::Get(const jsonKey_t& key, bool& value) const
{
    if (js_info->contains(key) && (*js_info)[key].is_boolean())
    {
        value = (*js_info)[key].get<bool>();
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, asINT64& value) const
{
    if (js_info->contains(key) && (*js_info)[key].is_number())
    {
        value = (*js_info)[key].get<asINT64>();
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, double& value) const
{
    if (js_info->contains(key) && (*js_info)[key].is_number())
    {
        value = (*js_info)[key].get<double>();
        return true;
    }
    return false;
}

bool CASJson::Get(CString& key, CString& value) const
{
    if (js_info->contains(key.c_str()) && (*js_info)[key.c_str()].is_string())
    {
        std::string strvalue = (*js_info)[key.c_str()].get<std::string>();
        value.assign(strvalue.c_str(), strvalue.length());
        return true;
    }
    return false;
}

bool CASJson::Get(const jsonKey_t& key, CScriptArray& value) const
{
    if (!js_info->contains(key) || !(*js_info)[key].is_array())
        return false;

    json js_temp = (*js_info)[key];
    asUINT new_size = js_temp.size();

    // --- Lógica de Resize manual para CScriptArray ---
    if (value.m_buffer)
    {
        delete[](char*)value.m_buffer;
        value.m_buffer = nullptr;
    }
    if (new_size > 0)
    {
        size_t element_size = sizeof(CASJson*);
        size_t buffer_size = offsetof(CScriptArrayBuffer, m_buf) + (new_size * element_size);
        value.m_buffer = (CScriptArrayBuffer*)new char[buffer_size];
        value.m_buffer->m_size = new_size;
    }
    // --- Fin de Resize ---

    for (asUINT i = 0; i < new_size; ++i)
    {
        CASJson* childNode = Factory(js_temp[i]);

        // --- Lógica de SetValue manual para CScriptArray ---
        void* array_base = value.data();
        void* target_address = (char*)array_base + (i * sizeof(CASJson*));
        *((CASJson**)target_address) = childNode;
        // --- Fin de SetValue ---

        childNode->Release();
    }
    return true;
}

bool CASJson::GetBool() const { return js_info->is_boolean() ? js_info->get<bool>() : false; }
std::string CASJson::GetString() const { return js_info->is_string() ? js_info->get<std::string>() : ""; }
int CASJson::GetNumber() const { return js_info->is_number() ? js_info->get<int>() : 0; }
double CASJson::GetReal() const { return js_info->is_number() ? js_info->get<double>() : 0.0; }

CScriptArray* CASJson::GetArray() const
{
    if (!js_info->is_array()) return nullptr;

    asIScriptEngine* engine = ASEXT_GetServerManager()->scriptEngine;
    asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<JsonValue@>");
    if (!arrayType) return nullptr; 
    CScriptArray* retVal = new CScriptArray();
    retVal->m_buffer = nullptr;
    retVal->m_ElementTypeId = arrayType->GetTypeId();

    asUINT final_size = js_info->size();
    if (final_size > 0)
    {
        size_t element_size = sizeof(CASJson*);
        size_t buffer_size = offsetof(CScriptArrayBuffer, m_buf) + (final_size * element_size);

        retVal->m_buffer = (CScriptArrayBuffer*)new char[buffer_size];
        retVal->m_buffer->m_size = final_size;

        void* array_base = retVal->data();

        asUINT i = 0;
        for (const auto& item : *js_info)
        {
            CASJson* childNode = Factory(item);

            void* target_address = (char*)array_base + (i * element_size);
            *((CASJson**)target_address) = childNode;

            childNode->Release();
            i++;
        }
    }

    return retVal;
}

// --- Métodos de Utilidad y Acceso ---
CASJson* CASJson::opIndex(const jsonKey_t& key)
{
    // Esta implementación es compleja de replicar sin fugas de memoria.
    // Una forma segura es devolver un nuevo nodo que es una copia.
    if (!js_info->contains(key))
    {
        (*js_info)[key] = json::object(); // Crea un objeto vacío si no existe
    }
    return Factory((*js_info)[key]);
}

const CASJson* CASJson::opIndex_const(const jsonKey_t& key) const
{
    if (js_info->contains(key))
    {
        return Factory((*js_info)[key]);
    }
    return nullptr;
}

bool CASJson::Exists(const jsonKey_t& key) const { return js_info->contains(key); }
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