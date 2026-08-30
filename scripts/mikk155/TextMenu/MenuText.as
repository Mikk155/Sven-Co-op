// Represents a CTextMenu option or title for ease of color setting using builder-patterns
final class MenuText
{
    MenuText() {}

    private
        string m_Content;

    const string& get_String() const
    {
        return this.m_Content;
    }

    string& get_String()
    {
        return this.m_Content;
    }

    MenuText@ Write( const string&in text )
    {
        this.m_Content.opAddAssign( text );
        return this;
    }

    MenuText@ Color( const string&in color )
    {
        this.m_Content.opAddAssign( color );
        return this;
    }

    MenuText@ ColorWhite()
    {
        return this.Color( "\\w" );
    }

    MenuText@ ResetColor()
    {
        return this.ColorWhite();
    }

    MenuText@ ColorGray()
    {
        return this.Color( "\\d" );
    }

    MenuText@ ColorYellow()
    {
        return this.Color( "\\y" );
    }

    MenuText@ ColorRed()
    {
        return this.Color( "\\r" );
    }

    MenuText@ ColorMagenta()
    {
        return this.Color( "\\m" );
    }

    MenuText@ ColorGreen()
    {
        return this.Color( "\\g" );
    }

    MenuText@ ColorOrange()
    {
        return this.Color( "\\o" );
    }

    MenuText@ ColorCyan()
    {
        return this.Color( "\\c" );
    }
}
