using Python.Runtime;

class PyEngine
{
    public PyEngine( string PythonDLL )
    {
        Runtime.PythonDLL = PythonDLL;

        PythonEngine.Initialize();
    }

    ~PyEngine()
    {
        Shutdown();
    }

    public void Shutdown()
    {
        try
        {
            PythonEngine.Shutdown();
            PythonEngine.InteropConfiguration = Python.Runtime.InteropConfiguration.MakeDefault();
        } // Runtime.Shutdown(); raises exception. find updates later or fork my own
        catch {}
    }

    public void Run( string file, string mapname, string? folder = null )
    {
        string ScriptPath = "Upgrades";

        if( folder is not null )
        {
            ScriptPath = Path.Combine( ScriptPath, folder );
        }

        Console.WriteLine( $"[CSharp] Loading module {ScriptPath}.py" );

        MapContext context = new MapContext( mapname );

        foreach( var e in context.Entities ) // debug
            Console.WriteLine( $"[CSharp] {e}" );

        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, Path.Combine( Directory.GetCurrentDirectory(), ScriptPath ) );

            dynamic Script = Py.Import( file );
            PyObject result = Script.main( context.Name, context.Entities );

            Console.WriteLine( $"[CSharp] {result}" ); // debug
            foreach( var e in context.Entities )
                Console.WriteLine( $"[CSharp] {e}" );
        }
    }
}
