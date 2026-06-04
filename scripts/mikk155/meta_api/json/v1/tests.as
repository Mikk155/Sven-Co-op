/// Run tests for json
#include "../v1"
#include "fmt/core"
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

                bool DeserializeSingleLineCommentary( const string&in serialized ) override
                {
                    int i;
                    dictionary obj, arr;
                    return ( Deserialize( serialized, obj ) && obj.getSize() > 0
                        && obj.get( "first", i ) && i == 1
                        && obj.get( "second", arr ) && arr.getSize() > 0 && int(arr["0"]) == 1 && int(arr["1"]) == 2
                        && obj.get( "third", i ) && i == 2
                    );
                }

                bool DeserializeMultiLineCommentary( const string&in serialized ) override
                {
                    int i;
                    dictionary obj, arr;
                    return ( Deserialize( serialized, obj ) && obj.getSize() > 0
                        && obj.get( "first", i ) && i == 1
                        && obj.get( "second", arr ) && arr.getSize() > 0 && int(arr["0"]) == 1 && int(arr["1"]) == 2
                        && obj.get( "third", i ) && i == 2
                    );
                }

                void Tests() override
                {
                }
            }
        }
    }
}
