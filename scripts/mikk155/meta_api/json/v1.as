#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 1 of Json. conversion to/from dictionary.
        /// Array items are converted into a dictionary object where the key names are the item indexing.
        namespace v1
        {
            /**
            *   @brief Deserializes str into obj,
            *   If validator's serialized ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If validator's serialized is a file and is pointing to store/ and the file couldn't be opened it will be writed and return {}
            **/
            bool Deserialize( dictionary&out obj, Validator@ validator )
            {
                validator.SetVersion( Version::V1 ).Ok;
                return validator.Deserialize( obj );
            }

            /**
            *   @brief Deserializes str into obj,
            *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return {}
            **/
            bool Deserialize( const string&in str, dictionary&out obj )
            {
                return Deserialize( obj, Validator( str ) );
            }

            /**
            *   @brief Serializes obj.
            *   indents: -1 = single line, >= 0 = base tabs for root
            **/
            string Serialize( dictionary@ obj, int indents = -1 )
            {
                return Serialize( obj, indents, 0 );
            }

            /**
            *   @brief Serializes obj.
            *   indents: -1 = single line, >= 0 = base tabs for root
            *   filename: a file name to write in "scripts/<module type>/store/<filename>.json"
            *   Return whatever the content was written
            **/
            bool Serialize( dictionary@ obj, string filename, int indents = -1 )
            {
                snprintf( filename, "scripts/%1/store/%2.json", ( g_Module.GetModuleName() == "MapModule" ? "maps" : "plugins" ), filename );

                auto file = g_FileSystem.OpenFile( filename, OpenFile::WRITE );

                if( file !is null && file.IsOpen() )
                {
                    file.Write( Serialize( obj, indents ) );
                    file.Close();
                    return true;
                }
                g_Game.AlertMessage( at_console, "[JSON] ERROR: Couldn't serialize content to \"%1\"\n", filename );
                return false;
            }

            string SerializeObject( dictionary@ obj, int indents, int depth )
            {
                if( obj is null )
                    return "{}";

                array<string>@ keys = obj.getKeys();
                
                if( keys.length() == 0 )
                {
                    return "{}";
                }

                bool is_array = true;
                for( uint i = 0; i < keys.length(); i++ )
                {
                    if( !obj.exists( string( i ) ) )
                    {
                        is_array = false;
                        break;
                    }
                }

                string newline = ( indents >= 0 ) ? "\n" : "";
                
                string indent_str = String::EMPTY_STRING;
                string indent_inner = String::EMPTY_STRING;

                if( indents > 0 )
                {
                    int inner_tabs = depth > 0 ? indents * depth : indents;
                    for( int i = 1; i <= inner_tabs; i++ )
                    {
                        indent_str += " ";
                    }

                    indent_inner = indent_str;
                    for( int i = 1; i <= indents; i++ )
                    {
                        indent_inner += " ";
                    }
                }

                string buffer = ( depth > 0 ? newline + indent_str : '' ) + ( is_array ? "[" : "{" ) + newline;

                for( uint ui = 0; ui < keys.length(); ui++ )
                {
                    string key = is_array ? string( ui ) : keys[ui];

                    buffer += ( depth > 0 ? indent_inner : indent_str );

                    if( !is_array )
                    {
                        string escaped_key = key;
                        escaped_key.Replace( "\\", "\\\\" );
                        escaped_key.Replace( "\"", "\\\"" );
                        escaped_key.Replace( "\n", "\\n" );
                        escaped_key.Replace( "\r", "\\r" );
                        escaped_key.Replace( "\t", "\\t" );
                        
                        buffer += "\"" + escaped_key + "\": ";
                    }

                    string strValue;
                    dictionary@ objValue = null; 
                    int iValue;
                    float fValue;

                    if( obj.get( key, strValue ) )
                    {
                        if( strValue == "__null__" )
                        {
                            buffer += "null";
                        }
                        else if( strValue == "false" )
                        {
                            buffer += "false";
                        }
                        else if( strValue == "true" )
                        {
                            buffer += "true";
                        }
                        else
                        {
                            strValue.Replace( "\\", "\\\\" );
                            strValue.Replace( "\"", "\\\"" );
                            strValue.Replace( "\n", "\\n" );
                            strValue.Replace( "\r", "\\r" );
                            strValue.Replace( "\t", "\\t" );
                            
                            buffer += "\"" + strValue + "\"";
                        }
                    }
                    else if( obj.get( key, @objValue ) )
                    {
                        buffer += SerializeObject( objValue, indents, depth + 1 );
                    }
                    else if( obj.get( key, fValue ) )
                    {
                        buffer += string( fValue );
                    }
                    else if( obj.get( key, iValue ) )
                    {
                        buffer += string( iValue );
                    }
                    else
                    {
                        buffer += "null";
                    }

                    if( ui < keys.length() - 1 )
                    {
                        buffer += "," + newline;
                    }
                    else
                    {
                        buffer += newline;
                    }
                }

                buffer += ( depth > 0 ? indent_str : '' ) + ( is_array ? "]" : "}" );

                return buffer;
            }

            /**
            *   @brief Return whatever the given obj has an object at key containing the current map name in it.
            **/
            bool IsMapListed( dictionary@ obj, const string&in key = "map_blacklist" )
            {
                dictionary map_blacklist;
                if( obj.get( key, map_blacklist ) )
                {
                    string mapname = string( g_Engine.mapname );

                    for( uint ui = 0; ui < map_blacklist.getSize(); ui++ )
                    {
                        if( mapname == string( map_blacklist[ ui ] ) )
                        {
                            return true;
                        }
                    }
                }
                return false;
            }

            /**
            *   @brief converts the given obj to a list of string.
            *   NOTE: Any type that is not a string will be skipped.
            **/
            array<string> ToArray( dictionary@ obj )
            {
                uint size = obj.getSize();

                array<string> List( size );

                for( uint ui = 0; ui < size; ui++ )
                {
                    string value;
                    if( !obj.get( string( ui ), value ) )
                        return {};
                    List[ ui ] = value;
                }

                return List;
            }

            /**
            *   @brief converts the given obj to a list of string.
            *   NOTE: Any type that is not a string will be skipped.
            **/
            array<string> ToArray( dictionaryValue&in obj )
            {
                return ToArray( cast<dictionary>( obj ) );
            }

            /**
            *   @brief converts the given obj to a list of dictionaryValue
            **/
            array<dictionaryValue> ToAnyArray( dictionary@ obj )
            {
                uint size = obj.getSize();

                array<dictionaryValue> List( size );

                for( uint ui = 0; ui < size; ui++ )
                {
                    dictionaryValue value;
                    if( !obj.get( string( ui ), value ) )
                        return {};
                    List[ ui ] = value;
                }

                return List;
            }
        }
    }
}
