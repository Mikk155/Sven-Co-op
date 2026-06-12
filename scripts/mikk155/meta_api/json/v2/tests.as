/// Run tests for json
#include "../v2"
#include "fmt/core"
#include "../tests"

namespace meta_api
{
    namespace json
    {
        namespace v2
        {
            class Test : meta_api::json::ITest
            {
                Test()
                {
                    meta_api::json::tests::Register(this);
                }

                const Version GetVersion() override
                {
                    return Version::V2;
                }

                bool DeserializeGeneric( const string&in serialized ) override
                {
                    json@ obj;
                    return Deserialize( serialized, obj );
                }

                bool DeserializeAllTypes( const string&in serialized ) override
                {
                    json@ obj;
                    return Deserialize( serialized, obj );
                }

                void AdditionalTests() override
                {
                    json@ obj;

                    array<string> arr;
                    Expect( "fmt::ToArray conversion", true,
                        Deserialize( "{\"some_array\":[\"string\"]}", obj )
                        && fmt::ToArray( obj[ "some_array" ], arr ) && arr.length() == 1
                    );

                    Expect( "json.Count value counting", true,
                        Deserialize( "{\"0\":[1,2,[3,4,[5,6],{\"0\":7}]],\"1\":{\"1\":8}}", obj )
                        && obj.Count() == 8
                    );
                }
            }
        }
    }
}
