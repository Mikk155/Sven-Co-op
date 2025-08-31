class Program
{
    static readonly MapUpgrader Upgrader = new MapUpgrader();

    static void Main()
    {
        Upgrader.ScriptEngine.Shutdown();
    }
}
