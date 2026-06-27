/**
*   Class representing a Semantic version: https://semver.org/
**/
class SemanticVersion
{
    private
        uint m_Major;

    void SetMajor( uint major )
    {
        this.m_Major = major;
    }

    private
        uint m_Minor;

    void SetMinor( uint minor )
    {
        this.m_Minor = minor;
    }

    private
        uint m_Patch;

    void SetPatch( uint patch )
    {
        this.m_Patch = patch;
    }

    SemanticVersion( uint major, uint minor, uint patch )
    {
        this.SetMajor( major );
        this.SetMinor( minor );
        this.SetPatch( patch );
    }

    const uint get_Major() const
    {
        return this.m_Major;
    }

    const uint get_Minor() const
    {
        return this.m_Minor;
    }

    const uint get_Patch() const
    {
        return this.m_Patch;
    }

    bool opEquals( const SemanticVersion &in other ) const
    {
        return this.m_Major == other.m_Major &&
            this.m_Minor == other.m_Minor &&
                this.m_Patch == other.m_Patch;
    }

    int opCmp( const SemanticVersion &in other ) const
    {
        if( this.m_Major != other.m_Major )
            return( this.m_Major < other.m_Major ) ? -1 : 1;

        if( this.m_Minor != other.m_Minor )
            return( this.m_Minor < other.m_Minor ) ? -1 : 1;

        if( this.m_Patch != other.m_Patch )
            return( this.m_Patch < other.m_Patch ) ? -1 : 1;

        return 0;
    }

    array<uint> opConv() const
    {
        return { this.m_Major, this.m_Minor, this.m_Patch };
    }

    array<int> opConv() const
    {
        return { int( this.m_Major ), int( this.m_Minor ), int( this.m_Patch ) };
    }

    string ToString( const string &in separator = "." ) const
    {
        string buffer;
        snprintf( buffer, "%1%2%3%2%4", this.m_Major, separator, this.m_Minor, this.m_Patch );
        return buffer;
    }
}

/// Create a SemanticVersion instance from the given unsigned integers
SemanticVersion@ SemVer( uint major = 1, uint minor = 0, uint patch = 0 )
{
    return SemanticVersion( major, minor, patch );
}

/// Create a SemanticVersion instance from the given array
/// Return null if arr is not a valid semantic version
/// fill: if true fill missing numbers with zeros
SemanticVersion@ SemVer( const array<uint> &in arr, bool fill = false )
{
    if( arr.length() != 3 )
    {
        if( fill )
            return SemVer( arr.length() > 0 ? arr[0] : 0, arr.length() > 1 ? arr[1] : 0, arr.length() > 2 ? arr[2] : 0 );

        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got array<uint> with size of %2 expected 3 numbers!\n", g_Module.GetModuleName(), arr.length() );
        return null;
    }
    return SemVer( arr[0], arr[1], arr[2] );
}

/// Create a SemanticVersion instance from the given integers
SemanticVersion@ SemVer( int major = 1, int minor = 0, int patch = 0 )
{
    if( major < 0 || minor < 0 || patch < 0 )
    {
        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got a negative value! \"%2\"\n", g_Module.GetModuleName(), major < 0 ? major : minor < 0 ? minor : patch );
        return null;
    }

    return SemVer( uint( major ), uint( minor ), uint( patch ) );
}

/// Create a SemanticVersion instance from the given array
/// Return null if arr is not a valid semantic version
/// fill: if true fill missing numbers with zeros
SemanticVersion@ SemVer( const array<string> &in arr, bool fill = false )
{
    array<int> verList(3);

    if( arr.length() != 3 && !fill )
    {
        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got array<string> with size of %2 expected 3 numbers!\n", g_Module.GetModuleName(), arr.length() );
        return null;
    }

    for( uint ui = 0; ui < arr.length(); ui++ )
    {
        if( !g_Utility.IsStringInt( arr[ui] ) )
        {
            g_Game.AlertMessage( at_console, "[%1] SemanticVersion: array<string> value at index %2 is not a integer!\n", g_Module.GetModuleName(), arr.length() );
            return null;
        }
        verList[ui] = atoi( arr[ui] );
    }

    return SemVer( verList[0], verList[1], verList[2] );
}

/// Create a SemanticVersion instance from the given string using the given separator.
/// Return null if str is not a valid semantic version
/// fill: if true fill missing numbers with zeros
SemanticVersion@ SemVer( const string &in str, bool fill = false, const string &in separator = "." )
{
    array<string> arr = str.Split( separator );

    if( arr.length() != 3 && !fill )
    {
        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got string with size of %2 expected 3. missing \"%3\" separators!\n", g_Module.GetModuleName(), arr.length(), separator );
        return null;
    }

    return SemVer( arr, fill );
}

/// Create a SemanticVersion instance from the given array
/// Return null if arr is not a valid semantic version
/// fill: if true fill missing numbers with zeros
SemanticVersion@ SemVer( const array<int> &in arr, bool fill = false )
{
    if( arr.length() != 3 )
    {
        if( fill )
            return SemVer( arr.length() > 0 ? arr[0] : 0, arr.length() > 1 ? arr[1] : 0, arr.length() > 2 ? arr[2] : 0 );

        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got array<int> with size of %2 expected 3 numbers!\n", g_Module.GetModuleName(), arr.length() );
        return null;
    }

    return SemVer( arr[0] , arr[1], arr[2] );
}
