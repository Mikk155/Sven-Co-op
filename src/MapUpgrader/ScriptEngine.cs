using Python.Runtime;

public interface ILanguageEngine
{
    public string GetName();
    public void Shutdown();
    public UpgradeContext? Initialize( string script );
}

public class PythonLanguage() : ILanguageEngine
{
    public string GetName() => "Python";

    public void Shutdown()
    {
        try
        {
            PythonEngine.Shutdown();
            PythonEngine.InteropConfiguration = Python.Runtime.InteropConfiguration.MakeDefault();
        } // Runtime.Shutdown(); raises exception. find updates later or fork my own (If not embedable python is used later)
        catch {}
    }

    private string[]? PythonList( PyList list )
    {
        long Length = list.Length();

        if( Length <= 0 )
            return null;

        string[] SharpList = new string[ Length ];

        for( int i = 0; i < Length; i++ )
        {
            SharpList[i] = list[i].As<string>();
        }

        return SharpList;
    }

    public UpgradeContext? Initialize( string script )
    {
        ConfigContext config = new ConfigContext();

        config.Get( "python_dll", value =>
        {
            Runtime.PythonDLL = value;
            return true; // No exception raised. break the loop
        }, "Absolute path to your Python dll, it usually looks like \"C:\\Users\\Usuario\\AppData\\Local\\Programs\\Python\\Python311\\python311.dll\" You can drag and drop the dll too." );

        PythonEngine.Initialize();

        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" ) );
            sys.path.append( Path.Combine( Directory.GetCurrentDirectory(), "Upgrades", "netapi" ) );

            dynamic Script = Py.Import( Path.GetFileNameWithoutExtension( script ) );

            try
            {
                PyObject result = Script.context();

                PyList ListDownloadURLs = new PyList( result.GetAttr( "urls" ) );

#pragma warning disable CS8601 // Possible null reference assignment.
                UpgradeContext context = new UpgradeContext(){
                    Name = result.GetAttr( "Name" ).ToString(),
                    Description = result.GetAttr( "Description" ).ToString(),
                    Mod = result.GetAttr( "Mod" ).ToString(),
                    urls = PythonList( new PyList( result.GetAttr( "urls" ) ) ),
                    maps = PythonList( new PyList( result.GetAttr( "maps" ) ) )
                };
#pragma warning restore CS8601 // Possible null reference assignment.

                return context;
            }
            catch( Exception exception )
            {
                Console.WriteLine( $"[Python Engine] Exception thrown by the script \"{Path.GetFileName( script )}\"" );
                Console.WriteLine( $"Error: {exception.Message}" );

                if( exception.StackTrace is not null )
                {
                    Console.WriteLine( "Trace:" );
                    Console.WriteLine( exception.StackTrace );
                }
            }
            return null;
        }
    }
}

public class ScriptEngine
{
    public readonly Dictionary<string, ILanguageEngine> Languages = new Dictionary<string, ILanguageEngine>()
    {
        { ".py", new PythonLanguage() }
    };

    public Dictionary<string, List<string>> Scripts = new Dictionary<string, List<string>>();

    public ScriptEngine()
    {
        // Get all script files
        List<string> ScriptFiles = Directory.GetFiles(
                Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" )
            )
            .Where( file => this.Languages.ContainsKey( Path.GetExtension( file ) ) )
            .ToList();

        string[]? ScriptModule = null;

        foreach( string file in ScriptFiles )
        {
            string FileExtension = Path.GetExtension( file );

            List<string>? OrganizedScriptFiles;

            // Organize scripts to their languages
            if( Scripts.TryGetValue( FileExtension, out OrganizedScriptFiles ) && OrganizedScriptFiles is not null )
            {
                OrganizedScriptFiles.Add( file );
            }
            else
            {
                OrganizedScriptFiles = new List<string>(){ file };
                Scripts[ FileExtension ] = OrganizedScriptFiles;
            }

            // -TODO Add a contextual menu for the user to choose what to install
            // In the meanwhile use the last file found for testing
            ScriptModule = [ FileExtension, file ];
            break;
        }

        if( ScriptModule is not null )
        {
            ILanguageEngine lang = Languages[ ScriptModule[0] ];
            UpgradeContext? context = lang.Initialize( ScriptModule[1] );

            if( context is not null )
            {
                Console.WriteLine( $"Name {context.Name}" );
                Console.WriteLine( $"Description {context.Description}" );
                Console.WriteLine( $"Mod {context.Mod}" );
                Console.WriteLine( $"urls {string.Join( " ", context.urls )}" );
                if( context.maps is not null )
                    Console.WriteLine( $"maps {string.Join( " ", context.maps )}" );
            }

            lang.Shutdown();
        }
    }

    ~ScriptEngine()
    {
        Shutdown();
    }

    public void Shutdown()
    {
        foreach( KeyValuePair<string, ILanguageEngine> e in Languages )
        {
            if( e.Value is not null )
            {
                e.Value.Shutdown();
            }
        }
    }
}
