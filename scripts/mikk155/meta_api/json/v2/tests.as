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

                bool DeserializeSingleLineCommentary( const string&in serialized ) override
                {
                    json@ obj = json(), arr;
                    return ( obj.Load(serialized) && obj.Length() > 0
                        && obj.Contains( "first" ) && int(obj[ "first" ]) == 1
                        && obj.Contains( "second" ) && obj.Get( "second", @arr ) && int(arr[0]) == 1 && int(arr[1]) == 2
                        && obj.Contains( "third" ) && int(obj[ "third" ]) == 2
                    );
                }

                bool DeserializeMultiLineCommentary( const string&in serialized ) override
                {
                    json@ obj = json(), arr;
                    return ( obj.Load(serialized) && obj.Length() > 0
                        && obj.Contains( "first" ) && int(obj[ "first" ]) == 1
                        && obj.Contains( "second" ) && obj.Get( "second", @arr ) && int(arr[0]) == 1 && int(arr[1]) == 2
                        && obj.Contains( "third" ) && int(obj[ "third" ]) == 2
                    );
                }

                bool DeserializeArrayObject( const string&in serialized ) override
                {
                    json@ obj = json();
                    json@ obj2;
                    return ( obj.Load( serialized ) && obj.Length() > 0 && obj.is_array()
                        && int( obj[0] ) == 1
                        && float( obj[1] ) == 2.5
                        && bool( obj[2] )
                        && string( obj[3] ) == "string"
                        && ( @obj2 = obj[4] ) !is null && obj2.is_object() && obj2.Contains( "string" ) && string( obj2[ "string" ] ) == "string"
                        && obj[5].is_null()
                    );
                }

                bool DeserializeInvalidLastComma( const string&in serialized ) override
                {
                    json@ obj;
                    return ( Deserialize( serialized, obj ) && int( obj[ "1" ] ) == 1 );
                }

                void Tests() override
                {
                    json@ obj;

                    array<string> arr;
                    Expect( "fmt::ToArray conversion", true,
                        Deserialize( "{\"some_array\":[\"string\"]}", obj )
                        && fmt::ToArray( obj[ "some_array" ], arr ) && arr.length() == 1
                    );
                }
            }
        }
    }
}
