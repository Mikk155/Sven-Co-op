public class AngelScript : IProject
{
    public string GetName() {
        return "angelscript";
    }

    public string GetHeader() {
        return "Do you want to contribute to angelscript?";
    }

    public void Setup()
    {
        Console.WriteLine( "Updating default_plugins..." );

        string MKExtensionHeader = """
    "plugin"
    {
        "name" "MKExtension"
        "script" "MKExtension/main"
        "concommandns" "mke"
    }

""";
        string DefaultPlugins = Path.Combine( IProject.cache[ "svencoop" ], "svencoop_addon", "default_plugins.txt" );

        string Content;

        if( !File.Exists( DefaultPlugins ) )
        {
            System.Text.StringBuilder CBuilder = new System.Text.StringBuilder();
            CBuilder.AppendLine( "\"plugins\"" );
            CBuilder.AppendLine( "{" );
            CBuilder.AppendLine( "}" );
            Content = CBuilder.ToString();
            File.WriteAllText( DefaultPlugins, Content );
        }
        else
        {
            Content = File.ReadAllText( DefaultPlugins );
        }

        if( !Content.Contains( "MKExtension" ) )
        {
            int IndexEnd = Content.LastIndexOf( '}' );
            File.WriteAllText( DefaultPlugins, Content.Substring( 0, IndexEnd - 1 ) + MKExtensionHeader + Content.Substring( IndexEnd ) );
        }

        Console.WriteLine( "Setting up AngelScript code-runner..." );

        IProject.RunCommand(
            "dotnet",
            $"dotnet build code-runner.sln",
            Path.Combine( Directory.GetCurrentDirectory(), "..", "code-runner" )
        );
    }
}
