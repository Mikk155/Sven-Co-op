#include <string>
#include <unordered_set>

#pragma once

class CStringPool final
{
    using string = std::string;
    using string_view = std::string_view;

    private:
        std::unordered_set<string> Pool;

    public:
        explicit CStringPool()
        {
            Pool.reserve(1024);
        }

        /**
         * @brief Get a pointer to the string if it exists. else returns nullptr.
         */
        const char* GetNullable( const char* str )
        {
            if( auto it = Pool.find(str); it != Pool.end() )
                return it->c_str();
            return nullptr;
        }

        /**
         * @brief Get a pointer to the string if it exists. else returns nullptr.
         */
        const string* GetNullable( string_view str )
        {
            if( auto it = Pool.find( string(str) ); it != Pool.end() )
                return &(*it);
            return nullptr;
        }

        /**
         * @brief Get a pointer to the string if it exists. else returns nullptr.
         */
        const string* GetNullable( string str )
        {
            if( auto it = Pool.find( str ); it != Pool.end() )
                return &(*it);
            return nullptr;
        }

        /**
         * @brief Gets a valid pointer to the string. if it doesn't exists the method will create it.
         */
        const char* Get( const char* str )
        {
            auto [ pStr, inserted ] = Pool.emplace( str );
            return pStr->c_str();
        }

        /**
         * @brief Gets a valid reference to the string. if it doesn't exists the method will create it.
         */
        const string& Get( string_view str )
        {
            auto [ pStr, inserted ] = Pool.emplace( str );
            return *pStr;
        }

        void Clear()
        {
            Pool.clear();
        }
};

inline CStringPool g_StringPool;
