public class MapUpgrader
{
    public readonly ScriptEngine ScriptEngine = new ScriptEngine()!;

    public MapUpgrader()
    {
#if DEBUG // Generate docs for python Type hints
        PyExportAPI PyAPI = new PyExportAPI();

        PyAPI.Generate( typeof(Entity), "Entity" );
        PyAPI.Generate( typeof(Vector), "Vector" );
        PyAPI.Generate( typeof(UpgradeContext), "UpgradeContext" );
#endif
    }

    ~MapUpgrader()
    {
        this.Shutdown();
    }

    public void Shutdown()
    {
        this.ScriptEngine.Shutdown();
    }
}
