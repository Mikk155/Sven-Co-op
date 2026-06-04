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

                void Tests() override
                {
                }
            }
        }
    }
}
