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
            g_Logger.error( snprintf( cout, "FAIL: %1", title ) );
        }
        else
        {
            g_Logger.info( snprintf( cout, "PASS: %1", title ) );
        }

        tests::__Results__.insertLast(this);
    }
}

// Implement the interface and call meta_api::json::tests::Register(this); to register your implementation.
interface ITest
{
    /// Json version
    const Version GetVersion();
    const Logger@ get_Logger() const;
    /**
        If any data of the following object is missing from your deserialization then assume the test failed and return false.
{
    "null": null,
    "integer": 1,
    "float": 1.5,
    "bool": true,
    "string": "string",
    "object":
    {
    },
    "array":
    [
        null,
        1,
        1.5,
        true,
        false,
        "string",
        {},
        []
    ]
}
    */
    bool DeserializeAllTypes( const string&in serialized );
    // serialized could be anything invalid, this method is called for all the invalidation tests and should only return the object deserialization result
    bool DeserializeGeneric( const string&in serialized );
    // For your own tests initialize an Expect class passing up a title, the expected result and the conditional that should be equal to the expected
    void AdditionalTests();
}

namespace tests
{
uint __AllTestsTotal__ = 0;
uint __AllTestsPassed__ = 0;
uint __AllTestsFailed__ = 0;
uint __AllTests__ = 0;

array<ITest@> __Tests__(0);

// Register a test class
void Register( ITest@ test )
{
if( test is null )
{
    g_Logger.error( "Null test passed on meta_api::json::tests::Register( ITest@ )" );
    return;
}
__Tests__.insertLast( test );
} // void Register

array<Expect@> __Results__(0);

void __RunTests__( ITest@ test, bool metamod )
{
__AllTests__++;
__Results__.resize(0);
test.Logger.info( snprintf( meta_api::json::cout, "===== Running json tests for %1 =====", ( metamod ? "METAMOD" : "VANILLA" ) ) );

Expect( "Deserialization and types", true, test.DeserializeAllTypes( "{\"null\": null,\"integer\": 1,\"float\": 1.5,\"bool\": true,\"string\": \"string\",\"object\":{},\"array\":[null,1,1.5,true,false,\"string\",{},[]]}" ) );
Expect( "Single line comments", true, test.DeserializeGeneric( "// Comment before object\n{// Comment after token in object\n\"first\": 1, // Comment after comma\n\"second\": [\n1, // Comment inside array after value with comma\n2 // Comment inside array after value with no comma\n],\n\"third\": 2 // Comment after value with no comma\n}// Comment at end of object" ) );
Expect( "Multi line comments", true, test.DeserializeGeneric( "/**/{\n/*\n*/\n\"first\": 1,/**/\n\"second\":/**/[\n1,/**/\n2\n]/*?*/,\n\"third\"/*x[.*/: 2/**/}\n/**/" ) );
Expect( "Valid literals", true, test.DeserializeGeneric( "[true,false,null,\"\"]" ) );
Expect( "Valid literals", true, test.DeserializeGeneric( "[true,false,null,\"\"]" ) );
Expect( "Invalid pairs with no coma separator", false, test.DeserializeGeneric( "{\"0\":0\n\"1\":1}" ) );
Expect( "Invalid literal", false, test.DeserializeGeneric( "{\"value\":tru}" ) || test.DeserializeGeneric( "[tru]" ) );
Expect( "Invalid missing coma in array", false, test.DeserializeGeneric( "[1 2]" ) || test.DeserializeGeneric( "[1\t2]" ) || test.DeserializeGeneric( "[1\n2]" ) );
Expect( "Invalid root data outside of object", false, test.DeserializeGeneric( "{} something" ) );
Expect( "Invalid object exit token", false, test.DeserializeGeneric( "{]" ) );
Expect( "Invalid array exit token", false, test.DeserializeGeneric( "[}" ) );
Expect( "Invalid unterminated object", false, test.DeserializeGeneric( "[" ) || test.DeserializeGeneric( "{" ) );
Expect( "Valid empty main array/object", true, test.DeserializeGeneric( "[]" ) && test.DeserializeGeneric( "{}" ) );
// This seemed to be valid in metamod maybe we're missing some option there.
Expect( "Invalid trailing comma in object/array", false, test.DeserializeGeneric( "{\"1\":1,}" ) || test.DeserializeGeneric( "[1,]" ) );
Expect( "Unterminated string", false, test.DeserializeGeneric( "{\"a\":\"test}" ) );
Expect( "Weird whitespace", true, test.DeserializeGeneric( "{\n\t \"a\" : \r\n 1 \t }" ) );
Expect( "Non-string key", false, test.DeserializeGeneric( "{1: \"a\"}" ) );
Expect( "Missing colon", false, test.DeserializeGeneric( "{\"a\" 1}" ) );
Expect( "Trailing object/array", false, test.DeserializeGeneric( "{}{}" ) || test.DeserializeGeneric( "[][]" ) );
Expect( "Trailing whitespace OK", true, test.DeserializeGeneric( "{}   \n\t" ) );
Expect( "Empty input", false, test.DeserializeGeneric( "" ) );
Expect( "Only whitespace", false, test.DeserializeGeneric( "   \n\t" ) );
Expect( "garbage root", false, test.DeserializeGeneric( "some garbage not a json" ) );
Expect( "Duplicate keys", false, test.DeserializeGeneric( "{\"a\":1,\"a\":2}") );
Expect( "Escaped quotes", true, test.DeserializeGeneric( "[\"\\\"\"]" ) );
Expect( "Escaped line break", true, test.DeserializeGeneric( "[\"line\\nbreak\"]" ) );
Expect( "Escaped tab", true, test.DeserializeGeneric( "[\"\\ttab\"]" ) );
Expect( "Escaped back slash", true, test.DeserializeGeneric( "[\"\\\\slash\"]" ) );
Expect( "Escaped slash", true, test.DeserializeGeneric( "[\"\\/\"]" ) );
Expect( "Escaped back space", true, test.DeserializeGeneric( "[\"\\b\"]" ) );
Expect( "Escaped form feed", true, test.DeserializeGeneric( "[\"\\f\"]" ) );
Expect( "Escaped Unicode automatically for limitations", true, test.DeserializeGeneric( "{\"a\":\"\\u0041\"}" ) ); // 'A'
Expect( "Invalid escape", false, test.DeserializeGeneric( "{\"a\":\"\\x\"}" ) );
Expect( "UTF-8 BOM", true, test.DeserializeGeneric( "\xEF\xBB\xBF[]" ) );
Expect( "Deep array nesting", true, test.DeserializeGeneric( "[1,[2,[3,[[{\"epic\":true},5],4]]]]" ) );
Expect( "Deep nesting", true, test.DeserializeGeneric( "[{\"1\":[{\"2\":[{\"3\":[null]}]}]}]" ) );
test.AdditionalTests();
// Gather results
uint length = __Results__.length();
array<Expect@> fails(0);
array<Expect@> pass(0);
for( uint ui = 0; ui < length; ui++ )
{
    auto result = __Results__[ui];
    if( result.Failed )
    {
        __AllTestsFailed__++;
        fails.insertLast(result);
    }
    else
    {
        __AllTestsPassed__++;
        pass.insertLast(result);
    }
    __AllTestsTotal__++;
}
if( fails.length() == 0 )
{
    test.Logger.info( snprintf( cout, "===== All %1 tests passed =====", pass.length() ) );
}
else if( pass.length() == 0 )
{
    test.Logger.error( snprintf( cout, "===== All %1 tests failed =====", fails.length() ) );
}
else
{
    test.Logger.info( snprintf( meta_api::json::cout, "===== Passed: %1 =====", pass.length() ) );
    test.Logger.error( snprintf( meta_api::json::cout, "===== Failed: %1 =====", fails.length() ) );
}

test.Logger.info( "===== All done! =====\n==================" );
__Results__.resize(0);
}

void Start( ITest@ test )
{
if( test is null ) {
    g_Logger.error( "Null test passed on meta_api::json::tests::Start( ITest@ )" );
    return;
}
/*
bool __META_INSTALLED__ = false;
#if METAMOD_PLUGIN_ASLP
__RunTests__( test, true );
__META_INSTALLED__ = true;
#endif
if( !__META_INSTALLED__ ) {
    g_Logger.info( "===== Skiping json tests for METAMOD as is not installed =====", test.GetVersion() );
}
*/
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
string buffer;
snprintf(buffer, """
========== TEST SUMMARY ==========
Runs: %1
Pass: %2 (%3%%)
Fail: %4 (%5%%)
All : %6
=================================
""",
__AllTests__,
__AllTestsPassed__, ( __AllTestsTotal__ > 0 ? int( 100.0f * __AllTestsPassed__ / __AllTestsTotal__ ) : 0 ),
__AllTestsFailed__, ( __AllTestsTotal__ > 0 ? int( 100.0f * __AllTestsFailed__ / __AllTestsTotal__ ) : 0 ),
__AllTestsTotal__
);
g_EngineFuncs.ServerPrint(buffer);
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
g_Logger.error( snprintf( cout, "Couldn't find a registered test interface for version %1", version ) );
} // void Start
} // namespace tests
} // namespace json
} // namespace meta_api
