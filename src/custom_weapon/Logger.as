class CSetLogLevel
{
	private bool WARN = false;
	private bool DEBUG = false;
	private bool ERROR = false;

	void warn( bool Enable ){ WARN = Enable; }
	void debug( bool Enable ){ DEBUG = Enable; }
	void error( bool Enable ){ ERROR = Enable; }
}

class CLogger
{
    CSetLogLevel SetLogLevel;

    CLogger()
    {
        SetLogLevel = CSetLogLevel();
    }

	private void print( string message, array<string> szFormatting )
	{
		if( szFormatting.length() != 0 )
			for( uint ui = 0, ui < szFormatting.length(); ui++ )
				if( message.Find( '{}' ) )
					message = message.SubString( 0, message.Find( '{' ) - 1 ) + szFormatting[ui] + message.SubString( message.Find( '}' ) );
		g_EngineFuncs.ServerPrint( '[custom_weapons ' message + '\n' );
	}

	void error( string message, array<string> szFormatting = {} ) { if( ERROR_DEBUG ) { print( 'ERROR] ' +message, szFormatting ); } }
	void debug( string message, array<string> szFormatting = {} ) { if( ERROR_DEBUG ) { print( 'DEBUG] ' +message, szFormatting ); } }
	void warn( string message, array<string> szFormatting = {} ) { if( WARNING_DEBUG ) { print( 'WARNING] ' + message, szFormatting ); } }
}
