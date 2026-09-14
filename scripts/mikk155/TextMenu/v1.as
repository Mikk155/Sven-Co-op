/**
	-TODO

	callback al no elegir nada.

	custom callbacks

	guardar tiempo de menu en jugador y limpiar al llamar callbacks para prevenir-
		el abrir nuevos menus si ya hay uno abierto a no ser que haya una opcion-
		para hacer override a menus abiertos
**/

namespace TextMenu
{
	namespace v1
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

		// const string[][] MenuColors = {
		const dictionary MenuColors = {
			{ "white", "w" },
			{ "gray", "d" },
			{ "yellow", "y" },
			{ "red", "r" },
			{ "magenta", "m" },
			{ "green", "g" },
			{ "orange", "o" },
			{ "cyan", "c" }
		};

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

			MenuText@ Write( string&in text )
			{
				const array<string>@ keys = MenuColors.getKeys();
				uint length = keys.length();

				for( uint ui = 0; ui < length; ui++ )
				{
					string colorName = keys[ui];
					string color = string( MenuColors[ colorName ] );
					string colorMatch = "<" + colorName + ">";

					if( text.Find( colorMatch ) != String::INVALID_INDEX )
					{
						text.Replace( colorMatch, "\\" + color );
					}

					colorMatch = "<" + color + ">";

					if( text.Find( colorMatch ) != String::INVALID_INDEX )
					{
						text.Replace( colorMatch, "\\" + color );
					}
				}

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

			MenuText@ Clear()
			{
				this.m_Content = String::EMPTY_STRING;
				return this;
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

		class Menu : TextMenu::ASMenuTextHolder
		{
			private
				array<CTextMenu@> m_Menus;

			private
				array<MenuOption@> m_Options;

			array<MenuOption@>@ get_Options()
			{
				return @this.m_Options;
			}

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
								MenuOptionSelect@ callback = option.GetCallback();

								if( callback !is null )
								{
									callback( player, option );
								}
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
	}
}