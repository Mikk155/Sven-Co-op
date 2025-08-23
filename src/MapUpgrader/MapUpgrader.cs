class MapUpgrader
{
    public ScriptEngine ScriptEngine = null!;

    public MapUpgrader()
    {
#if DEBUG // Generate docs for python Type hints
        PyExportAPI PyAPI = new PyExportAPI();

        PyAPI.Generate( typeof(Entity), "Entity" );
#endif

        ConfigContext config = new ConfigContext();

        config.Get( "python_dll", value =>
        {
            this.ScriptEngine = new ScriptEngine( value );
            return true; // No exception raised. break the loop
        }, "Absolute path to your Python dll, it usually looks like \"C:\\Users\\Usuario\\AppData\\Local\\Programs\\Python\\Python311\\python311.dll\" You can drag and drop the dll too." );

        this.ScriptEngine.Run( "rp_c00", "rp_c00" );
    }

    ~MapUpgrader()
    {
        this.ScriptEngine.Shutdown();
    }
}

class Program
{
    static readonly MapUpgrader Upgrader = new MapUpgrader();

    static void Main()
    {
        Upgrader.ScriptEngine.Shutdown();
    }
}
