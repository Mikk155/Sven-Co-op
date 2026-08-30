// Callback for when a option is selected from a menu.
funcdef void MenuOptionSelect( CBasePlayer@ player, MenuOption@ option, Menu@ menu );

class MenuOption : TextMenu::ASMenuTextHolder
{
    // Any constructor
    MenuOption() {}

    private
        Menu@ m_Owner;

    private
        uint m_Id;

    const uint get_Id() const
    {
        return this.m_Id;
    }

    private
        MenuOptionSelect@ m_Callback = null;

    MenuOption( Menu@ owner )
    {
        @this.m_Owner = owner;
        this.m_Id = owner.Length();
    }
}
