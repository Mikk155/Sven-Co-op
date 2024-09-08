namespace HOOK_HANDLED
{
    HookReturnCode ClientSayHook( SayParameters@ pParams ) { return HOOK_HANDLED; }
    void ClientSay( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float delay )
    {
        if( UseType == USE_OFF ) g_Hooks.RemoveHook( Hooks::Player::ClientSay, @HOOK_HANDLED::ClientSayHook );
        else g_Hooks.RegisterHook( Hooks::Player::ClientSay, @HOOK_HANDLED::ClientSayHook );
    }
}