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

                    // Return whatever the given obj is of type of the given string.
                    bool is_type( json@ obj, json@ schema, const string&in name )
                    {
                        if( !schema.Contains( "type" ) )
                        {
                            print( snprintf( cout, "%1 expected \"type\" but is undefined!", name ) );
                            return false;
                        }

                        string type = string( schema[ "type" ] );
                        string actualType;

                        if( type.IsEmpty() )
                        {
                            print( "Unexpected empty type!" );
                            return false;
                        }

                        switch( obj.Type )
                        {
                            case Type::Object:
                                actualType = "object";
                            break;
                            case Type::Array:
                                actualType = "array";
                            break;
                            case Type::String:
                                actualType = "string";
                            break;
                            case Type::Integer:
                            case Type::Float:
                                actualType = "number";
                            break;
                            case Type::Boolean:
                                actualType = "boolean";
                            break;
                            case Type::Null:
                                actualType = "null";
                            break;
                        }

                        if( actualType.IsEmpty() )
                        {
                            print( snprintf( cout, "%1 unknown type %2", name, type ) );
                            return true;
                        }

                        if( actualType == type )
                            return true;

                        print( snprintf( cout, "%1 Expected %2 got %3", name, type, actualType ) );

                        if( this.strict )
                        {
                            obj.Clear();

                            if( schema.Contains( "default" ) )
                                obj.opAssign( schema[ "default" ] );
                        }

                        return false;
                    }

                    private bool Validate( json@ obj, json@ schema, const string&in name )
                    {
                        string expectType = schema.ValueOrDefault( "type", "object" );

                        if( !this.is_type( obj, schema, name ) )
                            return false;

                        json@ schemaProperties = schema.ValueOrDefault( "properties" );

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
                                    return false;
                                }
                            }
                        }
                        return true;
                    }

                    bool Validate( json@ obj, json@ schema )
                    {
                        // Pop schema key
                        obj.Remove( "$schema" );

                        // We don't support multi versioning yet. probably will never though.
                        schema.Remove( "$schema" );

                        return this.Validate( obj, schema, "<root>" );
                    }
                }

                /// Validate obj against schema
                /// strict: if false the schema wont modify the obj, if true it will remove invalid pairs and attempt to use default values if provided.
                bool Validate( json@ obj, json@ schema, bool strict = true )
                {
                    Validator validator( strict );
                    return validator.Validate( obj, schema );
                }

                /// Validate obj against schema
                /// strict: if false the schema wont modify the obj, if true it will remove invalid pairs and attempt to use default values if provided.
                bool Validate( json@ obj, const string&in schema, bool strict = true )
                {
                    json@ schemaObject;
                    return Deserialize( schema, schemaObject ) && Validate( obj, schemaObject, strict );
                }
            } // schema
        } // v2
    } // json
} // meta_api
