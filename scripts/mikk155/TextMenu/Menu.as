/**
    -TODO

    callback al no elegir nada.

    custom callbacks

    guardar tiempo de menu en jugador y limpiar al llamar callbacks para prevenir-
        el abrir nuevos menus si ya hay uno abierto a no ser que haya una opcion-
        para hacer override a menus abiertos
**/
#include "utils"
#include "MenuText"
#include "MenuOption"

class Menu : TextMenu::ASMenuTextHolder
{
    private
        array<CTextMenu@> m_Menus;

    private
        array<MenuOption@> m_Options;

    const array<MenuOption@>@ get_Options() const
    {
        return @this.m_Options;
    }

    Menu()
    {
        this.m_Menus.resize(g_Engine.maxClients);
    }

    ~Menu()
    {
        uint length = this.m_Menus.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            CTextMenu@ menu = this.m_Menus[ui];

            if( menu !is null )
            {
                if( menu.IsRegistered() )
                {
                    menu.Unregister();
                }
                @this.m_Menus[ ui ] = null;
            }
        }
    }

    uint Length() const
    {
        return this.m_Options.length();
    }

    // Get the number of pages.
    uint get_Pages() const
    {
        return ( this.m_Options.length() + 6 ) / 7;
    }

    // Add a menu option.
    MenuOption@ AddOption()
    {
        MenuOption@ option = MenuOption( this );
        this.m_Options.insertLast( option );
        return option;
    }

    // Add a set count of menu options.
    uint AddOptions( uint options )
    {
        uint index = this.Length();

        for( uint ui = 0; ui < options; ui++ )
        {
            this.AddOption();
        }

        return index;
    }

    private
        void InternalCallback( CTextMenu@ menu, CBasePlayer@ player, int slot, const CTextMenuItem@ item )
        {
            if( item !is null )
            {
                MenuOption@ option;

                if( item.m_pUserData !is null )
                {
                    if( item.m_pUserData.retrieve( @option ) )
                    {
                        // -TODO Callback to menu option member
                    }
                }
            }
            // -TODO callback here (Maybe useful when no item selected.)
        }

    // Open menu for a target player
    void Open( CBasePlayer@ player, uint displayTime = 10, uint page = 0 )
    {
        if( player is null )
            return;

        uint index = player.entindex() - 1;

        CTextMenu@ menu = this.m_Menus[ index ];

        if( menu !is null )
        {
            if( menu.IsRegistered() )
            {
                menu.Unregister();
            }
        }

        @menu = CTextMenu( @TextMenuPlayerSlotCallback( this.InternalCallback ) );

        menu.SetTitle( this.Text.String );

        uint length = this.m_Options.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            MenuOption@ option = this.m_Options[ui];
            menu.AddItem( option.Text.String, any(option) );
        }

        menu.Register();

        menu.Open( displayTime, page, player );

        @this.m_Menus[ index ] = menu;
    }

    // Open menu for all players
    void Open( uint displayTime = 10, uint page = 0 )
    {
        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            this.Open( g_PlayerFuncs.FindPlayerByIndex(i), displayTime, page );
        }
    }
}
