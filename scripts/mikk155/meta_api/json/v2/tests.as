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

                private Logger m_Logger( "JSON V2" );

                const Logger@ get_Logger() const
                {
                    return this.m_Logger;
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
                        && obj.is_object()
                        // object != array
                        && Deserialize( "{}", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\"}" )
                        && obj.is_array()
                        // object == object && nested array == array
                        && Deserialize( "{\"a\":[]}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"nested\":{\"type\":\"array\"}}}" )
                        && obj.is_object() && obj[ "a" ].is_array()
                        // object == object && nested array != array
                        && Deserialize( "{\"a\":{}}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"nested\":{\"type\":\"array\"}}}" )
                        && obj.is_object() && obj[ "a" ].is_object()
                    );

                    Expect( "[Schema] required key", true,
                        // required key undefined
                        Deserialize( "{}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"required\":[\"required\"]}" )
                        // required key defined
                        && Deserialize( "{\"required\":0}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"required\":[\"required\"]}" )
                    );

                    Expect( "[Schema] minimum items", true,
                        // 1 != 2
                        Deserialize( "[0]", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\",\"minItems\":2}" )
                        // 2 == 2
                        && Deserialize( "[0,1]", obj )
                        && schema::Validate( obj, "{\"type\":\"array\",\"minItems\":2}" )
                    );

                    Expect( "[Schema] maximum items", true,
                        // 3 != 2
                        Deserialize( "[0,1,2]", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\",\"maxItems\":2}" )
                        // 2 == 2
                        && Deserialize( "[0,1]", obj )
                        && schema::Validate( obj, "{\"type\":\"array\",\"maxItems\":2}" )
                    );

                    Expect( "[Schema] minimum value", true,
                        // 1 != 2
                        Deserialize( "{\"int\":1}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"minimum\":2}}}" )
                        // 2 == 2
                        && Deserialize( "{\"int\":2}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"minimum\":2}}}" )
                    );

                    Expect( "[Schema] maximum value", true,
                        // 3 != 2
                        Deserialize( "{\"int\":3}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"maximum\":2}}}" )
                        // 2 == 2
                        && Deserialize( "{\"int\":2}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"maximum\":2}}}" )
                    );
                }
            }
        }
    }
}
