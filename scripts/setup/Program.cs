class Setup
{
    private static readonly List<IProject> Projects = new List<IProject>(){
    };

    public static void Main()
    {
        Console.Title = "Setup";
        Console.BackgroundColor = ConsoleColor.Black;
        Console.ForegroundColor = ConsoleColor.Cyan;

        IProject.Config( "svencoop", value =>
        {
            if( !Directory.Exists( Path.Combine( value, "svencoop" ) ) )
            {
                throw new FileNotFoundException( $"Couldn't find the game's content at \"{value}\" Note the last directory must be outside of the \"svencoop\" folder" );
            }
            return true;
        }, $"Input the absolute path to sven coop installation" );

        foreach( IProject project in Projects )
        {
            project.Initialize();
        }

        Console.ResetColor();
    }
}
