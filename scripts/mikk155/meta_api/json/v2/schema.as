#include "../v2"

namespace meta_api
{
    namespace json
    {
        namespace v2
        {
            namespace schema
            {
                class Validator
                {
                    private
                        bool m_Strict = true;

                    const bool get_strict() const {
                        return this.m_Strict;
                    }

                    void print( bool fmt ) {
                        print::__print__( "Schema Error", cout, Version::V2 );
                    }

                    void print( const string fmt ) {
                        print::__print__( "Schema Error", fmt, Version::V2 );
                    }

                    Validator( bool strict )
                    {
                        this.m_Strict = strict;
                    }

                    Validator() {}

                    private
                        uint m_Fails = 0;

                    private
                        // Add error count. return false
                        bool get_error() {
                            m_Fails++;
                            return false;
                        }

                    // Return whatever the given obj is of type of the given string.
                    bool is_type( json@ obj, json@ schema, const string&in name )
                    {
                        if( !schema.Contains( "type" ) )
                        {
                            print( snprintf( cout, "%1 expected \"type\" at schema but is undefined!", name ) );
                            return this.error;
                        }

                        string expectedTypeString = string( schema[ "type" ] );
                        Type expectedType = Type::FromString( expectedTypeString );
                        bool isType = false;

                        if( expectedTypeString.IsEmpty() )
                        {
                            print( "Unexpected empty type at schema!" );
                            return this.error;
                        }

                        switch( expectedType )
                        {
                            case Type::Object:
                                isType = obj.is_object();
                            break;
                            case Type::Array:
                                isType = obj.is_array();
                            break;
                            case Type::String:
                                isType = obj.is_string();
                            break;
                            case Type::Integer:
                                isType = obj.is_number_integer();
                            break;
                            case Type::Float:
                                isType = obj.is_number();
                            break;
                            case Type::Boolean:
                                isType = obj.is_boolean();
                            break;
                            case Type::Null:
                                isType = obj.is_null();
                            break;
                            default:
                                print( snprintf( cout, "schema unknown \"type\" %2", expectedTypeString ) );
                                if( !this.error )
                                    return false;
                            break;
                        }

                        if( isType )
                            return true;

                        print( snprintf( cout, "%1 Expected %2 got %3", name, expectedTypeString, Type::ToString(obj.Type) ) );

                        if( !this.strict )
                        {
                            obj.Clear();
                            obj.SetType( expectedType );

                            if( schema.Contains( "default" ) )
                                obj.opAssign( schema[ "default" ] );
                        }

                        return this.error;
                    }

                    private bool Validate( json@ obj, json@ schema, const string&in name )
                    {
                        if( !this.is_type( obj, schema, name ) && this.strict )
                            return false;

                        switch( obj.Type )
                        {
                            case Type::Object:
                            case Type::Array:
                            {
                                json@ schemaProperties = schema.ValueOrDefault( ( obj.is_object() ? "properties" : "items" ) );

                                // Array specific validations
                                if( obj.is_array() )
                                {
                                    uint uiTemp;

                                    if( schema.Get( "minItems", uiTemp ) && obj.Length() < uiTemp )
                                    {
                                        print( snprintf( cout, "%1 array has less items than minimum expected %2 or more. got %3", name, uiTemp, obj.Length() ) );
                                        this.error;
                                        if( this.strict )
                                            return false;
                                    }

                                    if( schema.Get( "maxItems", uiTemp ) && obj.Length() > uiTemp )
                                    {
                                        print( snprintf( cout, "%1 array has more items than maximum expected %2 or less. got %3", name, uiTemp, obj.Length() ) );
                                        this.error;
                                        if( this.strict )
                                            return false;
                                    }
                                }
                                else
                                {
                                    // Whatever non-defined properties in schema are allowed in obj
                                    if( schema.ValueOrDefault( "unevaluatedProperties", true ) == false )
                                    {
                                        uint length = obj.Length();

                                        for( uint ui = 0; ui < length; ui++ )
                                        {
                                            json@ pair = obj[ui];

                                            if( !schemaProperties.Contains( pair.Name ) )
                                            {
                                                print( snprintf( cout, "%1 got unevaluated property \"%2\" which is not allowed!", name, pair.Name ) );
                                                this.error;

                                                if( this.strict )
                                                    return false;
                                            }
                                        }
                                    }

                                    // Whatever required properties in schema are defined in obj
                                    if( schema.Contains( "required" ) )
                                    {
                                        json@ required = schema.ValueOrDefault( "required" );

                                        uint length = required.Length();

                                        for( uint ui = 0; ui < length; ui++ )
                                        {
                                            string key = string( required[ui] );

                                            if( !obj.Contains( key ) )
                                            {
                                                print( snprintf( cout, "%1 missing required key \"%2\"", name, key ) );
                                                this.error;

                                                if( this.strict )
                                                    return false;
                                            }
                                        }
                                    }
                                }

                                // validate all properties
                                uint length = schemaProperties.Length();

                                for( uint ui = 0; ui < length; ui++ )
                                {
                                    json@ pair = schemaProperties[ui];

                                    json@ childObj = obj[ pair.Name ];

                                    if( childObj is null )
                                        continue;

                                    string childName;
                                    snprintf( childName, "%1->%2", name, pair.Name );

                                    bool result = this.Validate( childObj, pair, childName );

                                    if( this.strict && result == false )
                                        return false;
                                }

                                break;
                            }
                            case Type::Integer:
                            case Type::Float:
                            {
                                float fTemp;
                                float fValue;

                                if( schema.Get( "minimum", fTemp, false ) && obj.Get( fValue, false ) && fValue < fTemp )
                                {
                                    print( snprintf( cout, "%1 value is lesser than minimum expected %2 or more. got %3", name, fTemp, fValue ) );
                                    this.error;
                                    if( this.strict )
                                        return false;
                                }

                                if( schema.Get( "maximum", fTemp, false ) && obj.Get( fValue, false ) && fValue > fTemp )
                                {
                                    print( snprintf( cout, "%1 value is higher than maximum expected %2 or less. got %3", name, fTemp, fValue ) );
                                    this.error;
                                    if( this.strict )
                                        return false;
                                }
                                break;
                            }
                        }

                        return ( this.m_Fails == 0 );
                    }

                    bool Validate( json@ obj, json@ schema )
                    {
                        // Pop schema key
                        if( obj.is_object() )
                            obj.Remove( "$schema" );

                        // We don't support multi versioning yet. probably will never though.
                        schema.Remove( "$schema" );

                        return this.Validate( obj, schema, "<root>" );
                    }
                }

                /// Validate obj against schema
                /// strict: if true the method will return false right away stoping the validation.
                /// Otherwise the validation will keep going removing invalid values, attempting to set defaults if provided by the schema.
                bool Validate( json@ obj, json@ schema, bool strict = false )
                {
                    Validator validator( strict );
                    return validator.Validate( obj, schema );
                }

                /// Validate obj against schema
                /// strict: if true the method will return false right away stoping the validation.
                /// Otherwise the validation will keep going removing invalid values, attempting to set defaults if provided by the schema.
                bool Validate( json@ obj, const string&in schema, bool strict = false )
                {
                    json@ schemaObject;
                    return Deserialize( schema, schemaObject ) && Validate( obj, schemaObject, strict );
                }
            } // schema
        } // v2
    } // json
} // meta_api
