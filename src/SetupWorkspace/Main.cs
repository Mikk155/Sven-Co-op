using Mikk.Cache;
using Mikk.Logger;
using Newtonsoft.Json;

public static class App
{
    private static List<IProject> Projects = new List<IProject>()
    {
        new AngelScript()
    };

    public static void Main()
    {
        Console.Title = "Sven Co-op projects setup";

        foreach( IProject proj in Projects )
        {
            string name = proj.GetName();

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.Write( "Setting up " );
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine( name );
            Console.ResetColor();

            Logger log = new Logger( name );

            if( proj.Required() )
            {
                proj.Initialize( log );
            }
            else
            {
                proj.Initialize( log );
            }

            proj.Shutdown( log );
        }
    }
}
