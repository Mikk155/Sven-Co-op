namespace MapChange
{
    void PluginInit()
    {
        g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange::MapChange );
    }

    // <@717989732684005387> < This guy's fault >:[
    HookReturnCode MapChange( const string& in szNextMap )
    {
        restarts++;
        return HOOK_CONTINUE;
    }
}