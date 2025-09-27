/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

/**
*   Register:
*   Call StartupGameMode through MapInit

void MapInit()
{
    int gamemodes = ( CS16::GameMode::BombDefuse | CS16::GameMode::HostageRescue );

    CS16::ConfigContext context = CS16::ConfigContext( gamemodes );

    // -- Configure context here --

    CS16::StartupGameMode( context );
}
**/

namespace CS16
{
    // These are bit values so you could actually set multiples at once but be aware of compatibility.
    enum GameMode
    {
        // Not compatible with BombDefuse | HostageRescue
        DeathMatch = ( 1 << 0 ),
        // Not compatible with DeathMatch
        BombDefuse = ( 1 << 1 ),
        // Not compatible with DeathMatch
        HostageRescue = ( 1 << 2 ),
//         DefuseHostageRescue = ( GameMode.HostageRescue | GameMode.BombDefuse ),

/* Tags taken from gamebanana. not all of them will be implemented.
        FightYard,
        AWPWar,
        ZombieMod,
        JailBreak,
        Assassination,
        SoccerJam,
        DeathRun,
        BaseBuilder,
        HideAndSeek,
        FunType,
        AimTraining,
        GrenadeWar,
        PaintBall,
        Surf,
        KnifeArena,
        GunGame,
        ClimbKreedz,
        VolleyBall,
        BunnyHop,
        ShotgunsOnly,
        ZombieEscape,
        MiniGame,
        Escape,
        VehicleWar,
        P35HP,
        CTF,
        Slide,
        DeathRace,
        P1HP,
        TowerDefense,
        Scout,
        Speedrun,
        TTT,
        PistolsOnly,
        P1V1,
        ZombiePanic
*/
    };

    class ConfigContext
    {
        ConfigContext( GameMode gamemode )
        {
        }
    }

    void StartupGameMode( ConfigContext gamemode )
    {
    }
}
