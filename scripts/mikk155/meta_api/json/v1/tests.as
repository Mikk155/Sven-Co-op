/// Run tests for json
#include "../v1"
#include "fmt/core"
#include "utils/core"
#include "../tests"

namespace meta_api
{
    namespace json
    {
        namespace v1
        {
            class Test : meta_api::json::ITest
            {
                Test()
                {
                    meta_api::json::tests::Register(this);
                }

                const Version GetVersion() override
                {
                    return Version::V1;
                }

                private Logger m_Logger( "JSON V1" );

                const Logger@ get_Logger() const
                {
                    return this.m_Logger;
                }

                bool DeserializeGeneric( const string&in serialized ) override
                {
                    dictionary obj;
                    return Deserialize( serialized, obj );
                }

                bool DeserializeAllTypes( const string&in serialized ) override
                {
                    dictionary obj;
                    return Deserialize( serialized, obj );
                }

                void AdditionalTests() override
                {
                    dictionary obj;

                    Expect( "utils::IsMapListed current map in list", true,
                        Deserialize( "{\"map_blacklist\":[\"" + string( g_Engine.mapname ) + "\"]}", obj ) && utils::IsMapListed( obj )
                    );

                    array<string> arr;
                    Expect( "fmt::ToArray conversion", true,
                        fmt::ToArray( obj[ "map_blacklist" ], arr ) && arr.length() == 1
                    );
                }
            }
        }
    }
}
