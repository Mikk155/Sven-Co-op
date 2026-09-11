// Callback for when a option is selected from a menu.
funcdef void MenuOptionSelect( CBasePlayer@ player, const MenuOption@ option );

class MenuOption : TextMenu::ASMenuTextHolder
{
    // Any constructor
    MenuOption() {}

    private
        Menu@ m_Owner;

    // Get menu owning this option.
    const Menu@ GetMenu() const
    {
        return this.m_Owner;
    }

    private
        uint m_Id;

    const uint get_Id() const
    {
        return this.m_Id;
    }

    private
        MenuOptionSelect@ m_Callback = null;

    MenuOption@ SetCallback( MenuOptionSelect@ callback )
    {
        @this.m_Callback = callback;
        return this;
    }

    MenuOptionSelect@ GetCallback() const
    {
        return this.m_Callback;
    }

    MenuOption( Menu@ owner )
    {
        @this.m_Owner = owner;
        this.m_Id = owner.Length();
    }
}
