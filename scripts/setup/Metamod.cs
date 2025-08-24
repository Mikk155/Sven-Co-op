using System.Runtime.InteropServices;

public class Metamod : IProject
{
    public string GetName() {
        return "metamod";
    }

    public string GetHeader() {
        return "Do you want to contribute to the metamod's plugin?";
    }

    public void Setup()
    {
        string MetaDir = Path.Combine( IProject.cache[ "svencoop" ], "svencoop", "addons", "metamod" );

        List<string> Submodules = new List<string>(){
            "fmt",
            "json",
            "metamod"
        };

        Console.WriteLine( "Installing submodules..." );

        foreach( string submodule in Submodules )
        {
            Console.WriteLine( $"Fetching {submodule}..." );

            IProject.RunCommand(
                "git",
                $"submodule update --init --remote external/{submodule}",
                Path.Combine( Directory.GetCurrentDirectory(), "..", ".." )
            );
        }

        Console.WriteLine( "Generating CMakeLists project..." );

        string BuildFolder = Path.Combine( Directory.GetCurrentDirectory(), "..", "..", "build", "aslp" );
        string ProjectFolder = Path.Combine( Directory.GetCurrentDirectory(), "..", "..", "src", "aslp" );

        if( !Directory.Exists( BuildFolder ) )
        {
            Directory.CreateDirectory( BuildFolder );
        }

        string MSVC = RuntimeInformation.IsOSPlatform( OSPlatform.Windows ) ? $"-A Win32 " : "";

        string BinDir = Path.Combine( MetaDir, "dlls" );

        if( !Directory.Exists( BinDir ) )
        {
            Directory.CreateDirectory( BinDir );
        }

        IProject.RunCommand(
            "cmake",
            $"{MSVC} -S \"{ProjectFolder}\" -B \"{BuildFolder}\" -DCMAKE_INSTALL_PREFIX=\"{BinDir}\"",
            BuildFolder
        );

        Console.WriteLine( "Test building ASLP project..." );

        IProject.RunCommand(
            "cmake",
            $"--build \"{BuildFolder}\" --config Debug --clean-first --target install",
            BuildFolder
        );

        Console.WriteLine( "Updating plugins.ini." );

        string PluginsIni = Path.Combine( MetaDir, "plugins.ini" );

        if( !File.Exists( PluginsIni ) )
        {
            System.Text.StringBuilder Content = new System.Text.StringBuilder();
            Content.AppendLine( "win32 addons/metamod/dlls/aslp.dll" );
            Content.AppendLine( "linux addons/metamod/dlls/aslp.so" );
            File.WriteAllText( PluginsIni, Content.ToString() );
        }
        else
        {
            string[] Content = File.ReadAllLines( PluginsIni );

            if( Content.FirstOrDefault( a => a.Contains( "aslp" ) ) is null )
            {
                List<string> Lines = Content.ToList();
                Lines.Add( "win32 addons/metamod/dlls/aslp.dll" );
                Lines.Add( "linux addons/metamod/dlls/aslp.so" );
                File.WriteAllLines( PluginsIni, Lines );
            }
        }

        Console.WriteLine( "Generated build/aslp/build.bat for fast compile." );
        File.WriteAllText( Path.Combine( BuildFolder, "build.bat" ), """
@echo off
cmake --build . --config Debug --clean-first --target install
if %ERRORLEVEL% NEQ 0 (
    pause
    exit /b %ERRORLEVEL%
)
""" );
    }
}
