#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#include <string>
#include <sstream>
#include <cstdio>
#include <cstring>

namespace
{
    typedef std::stringstream Stream;

    void printEnumList(const asIScriptEngine* engine, Stream& stream)
    {
        for (asUINT i = 0; i < engine->GetEnumCount(); i++)
        {
            const auto e = engine->GetEnumByIndex(i);
            if (!e) continue;
            const char* ns = e->GetNamespace();
            if (ns[0] != '\0') 
            {
                stream << "namespace " << ns << " {\n";
            }
            stream << "enum " << e->GetName() << " {\n";
            for (asUINT j = 0; j < e->GetEnumValueCount(); ++j)
            {
                int value;
                const char* name = e->GetEnumValueByIndex(j, &value);
                stream << "\t" << name << " = " << value;
                if (j < e->GetEnumValueCount() - 1) stream << ",";
                stream << "\n";
            }
            stream << "}\n";
            if (ns[0] != '\0') stream << "}\n";
        }
    }

    std::string FixString( const std::string& str )
    {
        std::string result = str;

        size_t pos = 0;
        while( ( pos = result.find( "\n", pos ) ) != std::string::npos )
        {
            result.replace( pos, 1, "\\n" );
            pos += 2;
        }

        return result;
    }

    void printClassTypeList(const asIScriptEngine* engine, Stream& stream)
    {
        for (asUINT i = 0; i < engine->GetObjectTypeCount(); i++)
        {
            const auto t = engine->GetObjectTypeByIndex(i);
            if (!t) continue;

            const char* ns = t->GetNamespace();
            if (ns[0] != '\0') 
            {
                stream << "namespace " << ns << " {\n";
            }

            stream << "class " << t->GetName();
            if (t->GetSubTypeCount() > 0)
            {
                stream << "<";
                for (asUINT sub = 0; sub < t->GetSubTypeCount(); ++sub)
                {
                    const auto st = t->GetSubType(sub);
                    stream << st->GetName();
                    if (sub < t->GetSubTypeCount() - 1) stream << ", ";
                }
                stream << ">";
            }

            stream << " {\n";
            for (asUINT j = 0; j < t->GetBehaviourCount(); ++j)
            {
                asEBehaviours behaviour;
                const auto f = t->GetBehaviourByIndex(j, &behaviour);
                if (behaviour == asBEHAVE_CONSTRUCT || behaviour == asBEHAVE_DESTRUCT) {
                    stream << "\t" << f->GetDeclaration(false, true, true) << ";\n";
                }
            }
            for (asUINT j = 0; j < t->GetMethodCount(); ++j)
            {
                const auto m = t->GetMethodByIndex(j);
                stream << "\t" << FixString( m->GetDeclaration(false, true, true)) << ";\n";
            }
            for (asUINT j = 0; j < t->GetPropertyCount(); ++j)
            {
                stream << "\t" << t->GetPropertyDeclaration(j, true) << ";\n";
            }
            for (asUINT j = 0; j < t->GetChildFuncdefCount(); ++j)
            {
                const auto f = t->GetChildFuncdef(j);
                stream << "\tfuncdef " << f->GetFuncdefSignature()->GetDeclaration(false) << ";\n";
            }
            stream << "}\n";
            if (ns[0] != '\0') stream << "}\n";
        }
    }

    void printGlobalFunctionList(const asIScriptEngine* engine, Stream& stream)
    {
        for (asUINT i = 0; i < engine->GetGlobalFunctionCount(); i++)
        {
            const auto f = engine->GetGlobalFunctionByIndex(i);
            if (!f) continue;
            const char* ns = f->GetNamespace();
            if (ns[0] != '\0') stream << "namespace " << ns << " { ";
            stream << f->GetDeclaration(false, false, true) << ";";
            if (ns[0] != '\0') stream << " }";
            stream << "\n";
        }
    }

    void printGlobalPropertyList(const asIScriptEngine* engine, Stream& stream)
    {
        for (asUINT i = 0; i < engine->GetGlobalPropertyCount(); i++)
        {
            const char* name;
            const char* ns;
            int typeId;
            engine->GetGlobalPropertyByIndex(i, &name, &ns, &typeId);

            std::string t = engine->GetTypeDeclaration(typeId, true);
            if (t.empty()) continue;

            if (ns && ns[0] != '\0') stream << "namespace " << ns << " { ";
            stream << t << " " << name << ";";
            if (ns && ns[0] != '\0') stream << " }";
            stream << "\n";
        }
    }

    void printGlobalTypedef(const asIScriptEngine* engine, Stream& stream)
    {
        for (asUINT i = 0; i < engine->GetTypedefCount(); ++i)
        {
            const auto type = engine->GetTypedefByIndex(i);
            if (!type) continue;
            const char* ns = type->GetNamespace();
            if (ns[0] != '\0') stream << "namespace " << ns << " {\n";
            stream << "typedef " << engine->GetTypeDeclaration(type->GetTypedefTypeId()) << " " << type->GetName() << ";\n";
            if (ns[0] != '\0') stream << "}\n";
        }
    }
}

void GenerateScriptPredefined(const asIScriptEngine* engine)
{
    static bool g_ASDocsGenerated = false;

    if( g_ASDocsGenerated )
    {
        ALERT( at_console, "AngelScript predefined file generated at scripts/aslp.predefined\n" );
        return;
    }

    if (!engine) 
    {
        ALERT(at_console, "[Error] Couldn't detect the AngelScript Engine.\n");
        return;
    }

    char szPredefinedFilename[256] = { 0 };
    GET_GAME_DIR(szPredefinedFilename);
    strcat(szPredefinedFilename, "/scripts");
    CreateDirectory(szPredefinedFilename, NULL);
    strcat(szPredefinedFilename, "/aslp.predefined");

    std::stringstream contentStream;
    printEnumList(engine, contentStream);
    printClassTypeList(engine, contentStream);
    printGlobalFunctionList(engine, contentStream);
    printGlobalPropertyList(engine, contentStream);
    printGlobalTypedef(engine, contentStream);
    std::string fileContent = contentStream.str();

    FILE* file = fopen(szPredefinedFilename, "w");
    if (!file)
    {
        ALERT(at_console, "[Error] Couldn't create file \"%s\"\n", szPredefinedFilename);
        return;
    }

    g_ASDocsGenerated = true;

    fwrite(fileContent.c_str(), 1, fileContent.length(), file);
    fclose(file);
    ALERT(at_console, "File \"%s\" Generated suscessfully.\n", szPredefinedFilename);
}