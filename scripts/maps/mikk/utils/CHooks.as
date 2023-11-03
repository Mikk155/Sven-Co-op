funcdef HookReturnCode PlayerKeyInputHook( CBasePlayer@, In_Buttons, const bool );
array<PlayerKeyInputHook@> PlayerKeyInputHooks;

funcdef HookReturnCode PlayerFlashLightHook( CBasePlayer@, const bool, int&out, int&out );
array<PlayerFlashLightHook@> PlayerFlashLightHooks;

// Sin modificar
funcdef HookReturnCode PlayerJumpHook( CBasePlayer@ );
array<PlayerJumpHook@> PlayerJumpHooks;

funcdef HookReturnCode PlayerObserverModeHook( CBasePlayer@, ObserverMode );
array<PlayerObserverModeHook@> PlayerObserverModeHooks;

funcdef HookReturnCode MapChangedHook( const string& in );
array<MapChangedHook@> MapChangedHooks;
//fov
// when fully Duck

class CMKHooks
{
    private bool m_bPlayerPreThinkHook = false;

    bool RegisterHook( const int& in iHookID, ref @fn )
    {
        if( fn is null )
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] ref@ fn Null Pointer.\n' );
            return false;
        }

        bool m_bReturn = false;
        string m_iszDebug = '[CMKHooks] ';

        switch( iHookID )
        {
            case Hooks::Player::PlayerKeyInput:
            {
                PlayerKeyInputHook@ pFunction = cast<PlayerKeyInputHook@>( fn );

                if( pFunction is null )
                {
                    m_bReturn = false; m_iszDebug+= 'Could NOT';
                }
                else
                {
                    m_bReturn = true; m_iszDebug+='Has been';
                    PlayerKeyInputHooks.insertLast( @pFunction );
                }
                m_iszDebug+=' register hook Hooks::Player::PlayerKeyInputHook( CBasePlayer@, In_Buttons m_iButton, const bool m_bReleased )';
                break;
            }
            case Hooks::Player::PlayerFlashLight:
            {
                PlayerFlashLightHook@ pFunction = cast<PlayerFlashLightHook@>( fn );

                if( pFunction is null )
                {
                    m_bReturn = false; m_iszDebug+= 'Could NOT';
                }
                else
                {
                    m_bReturn = true; m_iszDebug+='Has been';
                    PlayerFlashLightHooks.insertLast( @pFunction );
                }
                m_iszDebug+=' register hook Hooks::Player::PlayerFlashLightHook( CBasePlayer@, In_Buttons m_iButton, const bool m_bReleased )';
                break;
            }
            case Hooks::Player::PlayerJump:
            {
                PlayerJumpHook@ pFunction = cast<PlayerJumpHook@>( fn );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not register Hooks::Player::PlayerJump.\n' );
                    return false;
                }
                else if( PlayerJumpHooks.findByRef( pFunction ) < 0 )
                {
                    PlayerJumpHooks.insertLast( @pFunction );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Registered hook Hooks::Player::PlayerJump.\n' );
                    return true;
                }
            }
            case Hooks::Player::PlayerObserverMode:
            {
                PlayerObserverModeHook@ pFunction = cast<PlayerObserverModeHook@>( fn );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not register Hooks::Player::PlayerObserverMode.\n' );
                    return false;
                }
                else if( PlayerObserverModeHooks.findByRef( pFunction ) < 0 )
                {
                    PlayerObserverModeHooks.insertLast( @pFunction );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Registered hook Hooks::Player::PlayerObserverMode.\n' );
                    return true;
                }
            }
            case Hooks::Game::MapChanged:
            {
                MapChangedHook@ pFunction = cast<MapChangedHook@>( fn );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not register Hooks::Player::MapChanged.\n' );
                    return false;
                }
                else if( MapChangedHooks.findByRef( pFunction ) < 0 )
                {
                    MapChangedHooks.insertLast( @pFunction );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Registered hook Hooks::Player::MapChanged.\n' );
                    return true;
                }
            }

            default:
            {
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
            }
        }

        g_Game.AlertMessage( at_console, m_iszDebug + '\n' );

        return m_bReturn;
    }

    void RemoveHook( const int& in iHookID, ref @function )
    {
        if( function is null )
        {
            return;
        }

        switch( iHookID )
        {
            case Hooks::Player::PlayerKeyInput:
            {
                PlayerKeyInputHook@ pFunction = cast<PlayerKeyInputHook@>( function );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerKeyInput.\n' );
                }
                else if( PlayerKeyInputHooks.findByRef( pFunction ) >= 0 )
                {
                    PlayerKeyInputHooks.removeAt( PlayerKeyInputHooks.findByRef( pFunction ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerKeyInput.\n' );
                }
                break;
            }
            case Hooks::Player::PlayerFlashLight:
            {
                PlayerFlashLightHook@ pFunction = cast<PlayerFlashLightHook@>( function );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerFlashLight.\n' );
                }
                else if( PlayerFlashLightHooks.findByRef( pFunction ) >= 0 )
                {
                    PlayerFlashLightHooks.removeAt( PlayerFlashLightHooks.findByRef( pFunction ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerFlashLight.\n' );
                }
                break;
            }
            case Hooks::Player::PlayerJump:
            {
                PlayerJumpHook@ pFunction = cast<PlayerJumpHook@>( function );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerJump.\n' );
                }
                else if( PlayerJumpHooks.findByRef( pFunction ) >= 0 )
                {
                    PlayerJumpHooks.removeAt( PlayerJumpHooks.findByRef( pFunction ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerJump.\n' );
                }
                break;
            }
            case Hooks::Player::PlayerObserverMode:
            {
                PlayerObserverModeHook@ pFunction = cast<PlayerObserverModeHook@>( function );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerObserverMode.\n' );
                }
                else if( PlayerObserverModeHooks.findByRef( pFunction ) >= 0 )
                {
                    PlayerObserverModeHooks.removeAt( PlayerObserverModeHooks.findByRef( pFunction ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerObserverMode.\n' );
                }
                break;
            }
            case Hooks::Game::MapChanged:
            {
                MapChangedHook@ pFunction = cast<MapChangedHook@>( function );

                if( pFunction is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::MapChanged.\n' );
                }
                else if( MapChangedHooks.findByRef( pFunction ) >= 0 )
                {
                    MapChangedHooks.removeAt( MapChangedHooks.findByRef( pFunction ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::MapChanged.\n' );
                }
                break;
            }

            default:
            {
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
                break;
            }
        }
    }

    void RemoveHook( const int& in iHookID )
    {
        switch( iHookID )
        {
            case Hooks::Player::PlayerKeyInput:
            {
                PlayerKeyInputHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerKeyInput.\n' );
                break;
            }
            case Hooks::Player::PlayerFlashLight:
            {
                PlayerFlashLightHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerFlashLight.\n' );
                break;
            }
            case Hooks::Player::PlayerJump:
            {
                PlayerJumpHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerJump.\n' );
                break;
            }
            case Hooks::Player::PlayerObserverMode:
            {
                PlayerObserverModeHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerObserverMode.\n' );
                break;
            }
            case Hooks::Game::MapChanged:
            {
                MapChangedHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Game::MapChanged.\n' );
                break;
            }

            default:
            {
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
                break;
            }
        }
    }
}

namespace Hooks
{
    namespace Player
    {
        enum Player_e
        {
            PlayerKeyInput = 0,
            PlayerFlashLight,
            PlayerJump,
            PlayerObserverMode,
            CONST
        }

        void PlayerJumpFunction( CBasePlayer@ pPlayer )
        {
            if( pPlayer is null || PlayerJumpHooks.length() < 0 )
                return;

            if( pPlayer.pev.button & IN_JUMP != 0 && pPlayer.pev.flags & FL_ONGROUND != 0 )
            {
                for( uint ui = 0; ui < PlayerJumpHooks.length(); ui++ )
                {
                    PlayerJumpHook@ pHook = cast<PlayerJumpHook@>( PlayerJumpHooks[ui] );

                    if( pHook is null )
                        continue;

                    if( pHook( pPlayer ) == HOOK_HANDLED )
                        break;
                }
            }
        }

        void PlayerFlashLightFunction( CBasePlayer@ pPlayer )
        {
            if( pPlayer is null || PlayerFlashLightHooks.length() < 0 )
                return;

            if( pPlayer.pev.impulse == 100 )
            {
                for( uint ui = 0; ui < PlayerFlashLightHooks.length(); ui++ )
                {
                    int m_iRechargeSpeed = 1;
                    int m_iConsumeSpeed = 1;

                    PlayerFlashLightHook@ pHook = cast<PlayerFlashLightHook@>( PlayerFlashLightHooks[ui] );

                    if( pHook is null )
                        continue;

                    HookReturnCode m_uiHook = pHook( pPlayer, !pPlayer.FlashlightIsOn(), m_iRechargeSpeed, m_iConsumeSpeed );

                    if( m_iRechargeSpeed != 1 )
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight', string( m_iRechargeSpeed ) );

                    if( m_iConsumeSpeed != 1 )
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consume', string( m_iConsumeSpeed ) );

                    if( m_uiHook == HOOK_HANDLED )
                        break;
                }
            }

            // This is somewhat stupid, this should have been a feature a long ago
            if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight' ) )
            {
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight', 1 );
            }

            int m_iRechargeSpeed = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight' ).GetInteger();

            if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_consume' ) )
            {
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consume', 1 );
            }

            int m_iConsumeSpeed = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_consume' ).GetInteger();

            if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_battery' ) )
            {
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
            }

            int m_iBattery = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_battery' ).GetInteger();

            if( pPlayer.pev.effects & EF_DIMLIGHT != 0 )
            {
                if( m_iConsumeSpeed != 1 )
                {
                    if( m_iBattery - 1 == pPlayer.m_iFlashBattery )
                    {
                        if( m_iConsumeSpeed > 1 )
                        {
                            pPlayer.m_iFlashBattery -= m_iConsumeSpeed;
                        }
                        else if( m_iConsumeSpeed == 0 )
                        {
                            pPlayer.m_iFlashBattery = m_iBattery;
                        }
                        else if( m_iConsumeSpeed < 0 )
                        {
                            if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_consumespeed' ) )
                            {
                                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consumespeed', m_iConsumeSpeed );
                            }

                            int m_iNextConsume = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_consumespeed' ).GetInteger();

                            if( m_iNextConsume == 0 )
                            {
                                pPlayer.m_iFlashBattery -= 1;
                                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consumespeed', m_iConsumeSpeed );
                            }
                            else
                            {
                                pPlayer.m_iFlashBattery = m_iBattery;
                                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consumespeed', m_iNextConsume + 1 );
                            }
                        }
                    }
                }
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
            }
            else if( m_iRechargeSpeed != 1 )
            {
                if( m_iBattery + 1 == pPlayer.m_iFlashBattery )
                {
                    pPlayer.m_iFlashBattery = m_iBattery;

                    if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_chargespeed' ) )
                    {
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_chargespeed', m_iRechargeSpeed );
                    }

                    int m_iNextRecharge = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_chargespeed' ).GetInteger();

                    if( m_iRechargeSpeed < 0 )
                    {
                        if( m_iNextRecharge == 0 )
                        {
                            if( pPlayer.m_iFlashBattery < 100 )
                            {
                                pPlayer.m_iFlashBattery += 1;
                                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_chargespeed', m_iRechargeSpeed );
                            }
                        }
                        else
                        {
                            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_chargespeed', m_iNextRecharge + 1 );
                        }
                    }
                    else if( m_iRechargeSpeed > 1 )
                    {
                        if( pPlayer.m_iFlashBattery < 100 )
                        {
                            pPlayer.m_iFlashBattery += m_iNextRecharge;
                            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                        }
                    }
                }
                else
                {
                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                }
            }

            int m_iFix = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_battery' ).GetInteger();

            if( pPlayer.m_iFlashBattery > 100 || m_iFix > 100 )
            {
                pPlayer.m_iFlashBattery = 100;
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
            }
            else if( pPlayer.m_iFlashBattery <= 1 || m_iFix <= 1 )
            {
                pPlayer.m_iFlashBattery = 1;
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
            }

            if( pPlayer.m_iFlashBattery <= 1 )
            {
                pPlayer.pev.impulse = 0;
            }
        }

        void PlayerKeyInputFunction( CBasePlayer@ pPlayer )
        {
            if( pPlayer is null || PlayerKeyInputHooks.length() < 0 )
                return;

            array<int> iBits =
            {
                1,      // IN_ATTACK
                2,      // IN_JUMP
                4,      // IN_DUCK
                8,      // IN_FORWARD
                16,     // IN_BACK
                32,     // IN_USE
                64,     // IN_CANCEL
                128,    // IN_LEFT
                256,    // IN_RIGHT
                512,    // IN_MOVELEFT
                1024,   // IN_MOVERIGHT
                2048,   // IN_ATTACK2
                4096,   // IN_RUN
                8192,   // IN_RELOAD
                16384,  // IN_ALT1
                32768   // IN_SCORE
            };

            for( uint uib = 0; uib < iBits.length(); uib++ )
            {
                int iOldButton = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_keyinput_' + iBits[ uib ] ).GetInteger();

                if( pPlayer.pev.button & In_Buttons( iBits[ uib ] ) != iOldButton )
                {
                    for( uint ui = 0; ui < PlayerKeyInputHooks.length(); ui++ )
                    {
                        PlayerKeyInputHook@ pHook = cast<PlayerKeyInputHook@>( PlayerKeyInputHooks[ui] );

                        if( pHook is null )
                            continue;

                        if( pHook( pPlayer, In_Buttons( iBits[ uib ] ), ( iOldButton == 0 ? false : true ) ) == HOOK_HANDLED )
                            break;
                    }
                }
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_keyinput_' + iBits[ uib ], string( pPlayer.pev.button & In_Buttons( iBits[ uib ] ) ) );
            }
        }

        void PlayerObserverModeFunction( CBasePlayer@ pPlayer )
        {
            if( pPlayer is null || PlayerKeyInputHooks.length() < 0 )
                return;

            int m_iUserData = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_observermode' ).GetInteger();

            if( pPlayer.pev.iuser1 != m_iUserData )
            {
                for( uint ui = 0; ui < PlayerObserverModeHooks.length(); ui++ )
                {
                    PlayerObserverModeHook@ pHook = cast<PlayerObserverModeHook@>( PlayerObserverModeHooks[ui] );

                    if( pHook is null )
                        continue;

                    if( pHook( pPlayer, ObserverMode( pPlayer.pev.iuser1 ) ) == HOOK_HANDLED )
                        break;
                }
            }
            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_observermode', string( pPlayer.pev.iuser1 ) );
        }
    }

    namespace Game
    {
        enum Game_e
        {
            MapChanged = Player::CONST
        }

        void MapChangedFunction()
        {
            if( MapChangedHooks.length() < 0 )
                return;

            string m_iszLatestMap = String::EMPTY_STRING;

            File@ pFileRead = g_FileSystem.OpenFile( 'scripts/maps/store/CHooks_MapChangedHook.txt', OpenFile::READ );

            if( pFileRead !is null && pFileRead.IsOpen() )
            {
                while( !pFileRead.EOFReached() )
                {
                    string line;
                    pFileRead.ReadLine( line );

                    if( !line.IsEmpty() )
                    {
                        m_iszLatestMap = line;
                    }
                }
                pFileRead.Close();
            }

            File@ pFileWrite = g_FileSystem.OpenFile( 'scripts/maps/store/CHooks_MapChangedHook.txt', OpenFile::WRITE );

            if( pFileWrite !is null && pFileWrite.IsOpen() )
            {
                pFileWrite.Write( string( g_Engine.mapname ) );
                pFileWrite.Close();
            }

            for( uint ui = 0; ui < MapChangedHooks.length(); ui++ )
            {
                MapChangedHook@ pHook = cast<MapChangedHook@>( MapChangedHooks[ui] );

                if( pHook is null )
                    continue;

                if( pHook( m_iszLatestMap ) == HOOK_HANDLED )
                    break;
            }
        }
    }

    void MapActivate()
    {
        Hooks::Game::MapChangedFunction();
    }

    void MapInit()
    {
        g_Hooks.RemoveHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
        g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
    }

    HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        if( pPlayer !is null )
        {
            Hooks::Player::PlayerJumpFunction( pPlayer );
            Hooks::Player::PlayerFlashLightFunction( pPlayer );
            Hooks::Player::PlayerKeyInputFunction( pPlayer );
            Hooks::Player::PlayerObserverModeFunction( pPlayer );
        }
        return HOOK_CONTINUE;
    }
}