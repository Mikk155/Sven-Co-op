/// Run tests for json
#include "../v2"
#include "schema"
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

                    Expect( "json.Count total nested value counting", true,
                        Deserialize( "{\"0\":[1,2,[3,4,[5,6],{\"0\":7}]],\"1\":{\"1\":8}}", obj )
                        && obj.Count() == 8
                    );

                    //============================
                    // ======== schema test ========
                    //============================

                    Expect( "[Schema] unevaluated properties discard", true,
                        Deserialize( "{\"unevaluated\":1,\"evaluated\":1}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"unevaluatedProperties\":false}" )
                    );

                    Expect( "[Schema] type expect", true,
                        // array != object
                        Deserialize( "[]", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\"}" )
                        // object != array
                        && Deserialize( "{}", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\"}" )
                        // object == object && nested array == array
                        && Deserialize( "{\"a\":[]}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"nested\":{\"type\":\"array\"}}}" )
                    );

                    Expect( "[Schema] required key", true,
                        // required key undefined
                        Deserialize( "{}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"required\":[\"required\"]}" )
                        // required key defined
                        && Deserialize( "{\"required\":0}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"required\":[\"required\"]}" )
                    );
                }
            }
        }
    }
}
