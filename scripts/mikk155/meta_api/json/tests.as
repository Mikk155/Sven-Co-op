/// Json tests interface
#include "../json"

namespace meta_api
{
namespace json
{
final class Expect
{
    string title;
    bool Failed;

    Expect( string title, bool expected, bool condition )
    {
        this.title = title;

        if( condition != expected )
        {
            Failed = true;
            print::error( snprintf( cout, "FAIL: %1", title ), tests::__CurrentVersion__ );
        }
        else
        {
            print::info( snprintf( cout, "PASS: %1", title ), tests::__CurrentVersion__ );
        }

        tests::__Results__.insertLast(this);
    }
}

// Implement the interface and call meta_api::json::tests::Register(this); to register your implementation.
interface ITest
{
    /// Json version
    const Version GetVersion();
    // serialized = { "first": 1, "second": [ 1, 2 ], "third": 2 }
    bool DeserializeSingleLineCommentary( const string&in serialized );
    // serialized = { "first": 1, "second": [ 1, 2 ], "third": 2 }
    bool DeserializeMultiLineCommentary( const string&in serialized );
    // serialized = [ 1, 2.5, true, "string", { "string": "string" }, null ]
    bool DeserializeArrayObject( const string&in seialized );
    bool DeserializeInvalidLastComma( const string&in seialized );
    // Tests is called at the end of all the tests. you can initialize Expect class handles there to run your own specific tests
    void Tests();
}

namespace tests
{
Version __CurrentVersion__;
array<ITest@> __Tests__(0);

// Register a test class
void Register( ITest@ test )
{
if( test is null )
{
    print::error( "Null test passed on meta_api::json::tests::Register( ITest@ )" );
    return;
}
__Tests__.insertLast( test );
} // void Register

array<Expect@> __Results__(0);

void __RunTests__( ITest@ test, bool metamod )
{
__Results__.resize(0);
__CurrentVersion__ = test.GetVersion();
print::info( snprintf( meta_api::json::cout, "===== Running json tests for %1 =====", ( metamod ? "METAMOD" : "VANILLA" ) ), __CurrentVersion__ );

Expect( "Single line comments", true, test.DeserializeSingleLineCommentary(
"""// Comment before object
{// Comment after token in object
    "first": 1, // Comment after comma
    "second": [
        1, // Comment inside array after value with comma
        2 // Comment inside array after value with no comma
    ],
    "third": 2 // Comment after value with no comma
}// Comment at end of object"""
) );

Expect( "Multi line comments", true, test.DeserializeMultiLineCommentary(
"""/* Comment before object */
{/* Comment after token in object
    */
    "first": 1,/*something*/
    "second":/*idk other something*/[
        1,/*something*/
        2
    ]/*why would you want to place a comment here?*/,
    "third"/*This is worse.*/: 2/*end*/
}/* Comment at end of object*/"""
) );

Expect( "Array main object", true, test.DeserializeArrayObject( "[1,2.5,true,\"string\",{\"string\":\"string\"},null]" ) );

Expect( "reject trailing comma in object", false, test.DeserializeInvalidLastComma( "{\"1\":1,}" ) );

// Gather results
test.Tests();
uint length = __Results__.length();
array<Expect@> fails(0);
array<Expect@> pass(0);
for( uint ui = 0; ui < length; ui++ )
{
    auto result = __Results__[ui];
    if( result.Failed )
        fails.insertLast(result);
    else
        pass.insertLast(result);
}
if( fails.length() == 0 )
{
    print::info( snprintf( cout, "===== All %1 tests passed =====", pass.length() ), __CurrentVersion__ );
}
else if( pass.length() == 0 )
{
    print::error( snprintf( cout, "===== All %1 tests failed =====", fails.length() ), __CurrentVersion__ );
}
else
{
    print::info( snprintf( meta_api::json::cout, "===== Passed: %1 =====", pass.length() ), __CurrentVersion__ );
    print::error( snprintf( meta_api::json::cout, "===== Failed: %1 =====", fails.length() ), __CurrentVersion__ );
}

meta_api::json::print::info( "===== All done! =====\n==================", __CurrentVersion__ );
__Results__.resize(0);
}

void Start( ITest@ test )
{
if( test is null ) {
    print::error( "Null test passed on meta_api::json::tests::Start( ITest@ )", test.GetVersion() );
    return;
}
bool __META_INSTALLED__ = false;
#if METAMOD_PLUGIN_ASLP
__RunTests__( test, true );
__META_INSTALLED__ = true;
#endif
if( !__META_INSTALLED__ ) {
    print::info( "===== Skiping json tests for METAMOD as is not installed =====", test.GetVersion() );
}
// If metamod is installed disable the support momentarly to test vanilla behaviour
#if METAMOD_PLUGIN_ASLP
meta_api::json::__METAMOD__ = false;
#endif
__RunTests__( test, false );
#if METAMOD_PLUGIN_ASLP
meta_api::json::__METAMOD__ = true;
#endif
} // void Start

void StartAll()
{
for( uint ui = 0; ui < __Tests__.length(); ui++ )
{
    auto ptr = __Tests__[ui];

    if( ptr !is null )
    {
        Start( ptr );
    }
}
} // void StartAll

void Start( const Version&in version )
{
for( uint ui = 0; ui < __Tests__.length(); ui++ )
{
    auto ptr = __Tests__[ui];

    if( ptr !is null && ptr.GetVersion() == version )
    {
        Start( ptr );
        return;
    }
}
print::error( snprintf( cout, "Couldn't find a registered test interface for version %1", version ) );
} // void Start
} // namespace tests
} // namespace json
} // namespace meta_api
