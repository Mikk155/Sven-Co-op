public class MapUpgrader
{
    public static class Folders
    {
        /// <summary>
        /// Current directory of the executable
        /// </summary>
        public static string Workspace =>
            Directory.GetCurrentDirectory();

        /// <summary>
        /// Directory containing Python upgrade scripts
        /// </summary>
        public static string Upgrades =>
            Path.Combine( Workspace, "Upgrades" );

        /// <summary>
        /// Directory where the Python API is generated
        /// </summary>
        public static string PythonAPI =>
            Path.Combine( Workspace, "Upgrades", "netapi" );
    }
}

class Program
{
#pragma warning disable CS8618
    static PyEngine PyEn;
#pragma warning restore CS8618

    static void Main()
    {
#if DEBUG // Generate docs for python Type hints
        PyExportAPI PyAPI = new PyExportAPI();
//        PyAPI.Generate( typeof(MapContext), "MapContext" );
        PyAPI.Generate( typeof(Entity), "Entity" );
#endif

        ConfigContext config = new ConfigContext();

        config.Get( "python_dll", value =>
        {
            PyEn = new PyEngine( value );
            return true; // No exception raised. break the loop
        }, "Absolute path to your Python dll, it usually looks like \"C:\\Users\Usuario\\AppData\\Local\\Programs\\Python\\Python311\\python311.dll\" You can drag and drop the dll too." );

        PyEn.Run( "rp_c00", "rp_c00" );
        PyEn.Shutdown();
        Console.WriteLine( $"[CSharp] All done" );
    }
}