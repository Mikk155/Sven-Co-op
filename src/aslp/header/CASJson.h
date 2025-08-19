// Contenido de CASJson.h

#pragma once
#include <vector>
#include "CASBaseObject.h"

// --- INICIO DE LA SOLUCI�N DEFINITIVA PARA SNPRINTF ---

#include <cstdio> // 1. Incluir para tener _snprintf disponible en el namespace global

// 2. "Inyectamos" el nombre _snprintf en el namespace std.
//    Esto le dice al compilador que cuando vea "std::_snprintf", debe usar
//    la funci�n global "::_snprintf" que s� existe.
namespace std {
    using ::_snprintf;
}

#include "nlohmann/json.hpp" // 3. Ahora incluir la librer�a JSON

// --- FIN DE LA SOLUCI�N ---


typedef std::string jsonKey_t;
using json = nlohmann::json;

enum CASJsonType
{
    OBJECT_VALUE,
    ARRAY_VALUE,
    BOOLEAN_VALUE,
    STRING_VALUE,
    NUMBER_VALUE,
    REAL_VALUE,
    NULL_VALUE
};

class CASJson : public CASBaseGCObject
{
public:
    // Factory functions adaptadas al estilo del proyecto
    static CASJson* Factory();
    static CASJson* Factory(json js);

    // AddRef y Release son heredados de CASBaseGCObject

    // Operadores de asignaci�n
    CASJson& operator=(bool other);
    CASJson& operator=(asINT64 other);
    CASJson& operator=(double other);
    CASJson& operator=(const std::string& other);
    CASJson& operator=(const CScriptArray& other);
    CASJson& operator=(const CASJson& other);

    // M�todos Set para modificar el objeto JSON
    void Set(const jsonKey_t& key, bool value);
    void Set(const jsonKey_t& key, asINT64 value);
    void Set(const jsonKey_t& key, double value);
    void Set(const jsonKey_t& key, const std::string& value);
    void Set(const jsonKey_t& key, const CScriptArray& value);

    // M�todos Get para obtener valores
    bool Get(const jsonKey_t& key, bool& value) const;
    bool Get(const jsonKey_t& key, asINT64& value) const;
    bool Get(const jsonKey_t& key, double& value) const;
    bool Get(CString& key, CString& value) const;
    bool Get(const jsonKey_t& key, CScriptArray& value) const;

    // Conversores de tipo para el script
    bool        GetBool() const;
    std::string GetString() const;
    int         GetNumber() const;
    double      GetReal() const;
    CScriptArray* GetArray() const;

    // Acceso por �ndice
    CASJson* opIndex(const jsonKey_t& key);
    const CASJson* opIndex_const(const jsonKey_t& key) const;

    // M�todos de utilidad
    bool Exists(const jsonKey_t& key) const;
    bool IsEmpty() const;
    asUINT GetSize() const;
    void Clear();
    CASJsonType Type() const;

    // Puntero al objeto nlohmann::json
    json* js_info = nullptr;

private:
    CASJson();
    ~CASJson();
};