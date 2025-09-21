using Mikk.Cache;
using Mikk.Logger;
using Newtonsoft.Json;

public static class App
{
    public static class Github
    {
        public const string User = "Mikk155";
        public const string Repository = "Sven-Co-op";
        public static string Url => $"https://github.com/{App.Github.User}/{App.Github.Repository}";
        public static string GitDirectory => Path.Combine( Directory.GetCurrentDirectory(), App.Github.Repository );
    }

    private static List<IProject> Projects = new List<IProject>()
    {
        new CloneRepository()
    };

    public static void Main()
    {
        Console.Title = "Sven Co-op projects setup";

        foreach( IProject proj in Projects )
        {
            if( proj.Exists() )
                continue;

            string name = proj.GetName();

            Logger log = new Logger( name );

            if( proj.Required() )
            {
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.Write( "Setting up " );
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine( name );
                Console.ResetColor();

                proj.Initialize( log );
            }
            else if( UserAccept( proj.GetHeader() ) )
            {
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.Write( "Setting up " );
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine( name );
                Console.ResetColor();

                proj.Initialize( log );
            }
        }
    }

    private static bool UserAccept( string Title )
    {
        Console.WriteLine( Title );

        Console.WriteLine( " 1: Yes" );
        Console.WriteLine( " 2: No" );

        string? input;
        int option = 0;

        (int left, int right) = Console.GetCursorPosition();

        while( option != 1 && option != 2 )
        {
            input = Console.ReadLine();

            Console.SetCursorPosition( left, right );

            if( string.IsNullOrEmpty( input ) )
                continue;

            if( int.TryParse( input, out option ) )
            {
                if( option == 2 )
                {
                    return false;
                }
                if( option == 1 )
                {
                    return true;
                }
            }
        }
        return false;
    }
}
