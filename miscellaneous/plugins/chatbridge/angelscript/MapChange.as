namespace MapChange
{
    void PluginInit()
    {
        g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange::MapChange );
    }

    HookReturnCode MapChange()
    {
        restarts++;
        return HOOK_CONTINUE;
    }
}