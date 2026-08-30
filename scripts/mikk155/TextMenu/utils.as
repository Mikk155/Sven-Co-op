namespace TextMenu
{
    abstract class ASMenuTextHolder
    {
        protected
            MenuText m_Content();

        // Get string content.
        const string& get_Content() const
        {
            return this.m_Content.String;
        }

        // Get a handler this class content string builder.
        MenuText@ get_Text()
        {
            return @this.m_Content;
        }
    }
}
