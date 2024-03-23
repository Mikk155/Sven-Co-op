//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../../mikk/shared"
#include "../../../mikk/Reflection"

#include "CServer"
#include "CDiscord"
#include "ClientSay"
#include "MapStart"
#include "emotes"
#include "PlayerConnect"
#include "PlayerSpawn"
#include "ClientDisconnect"
#include "SurvivalEnabled"
#include "PlayerKilled"
#include "PlayersConnected"

// Until i get a idea of how to define "ASLP" look at this like a commentary.
// Change "ASLP" to "SERVER" and these will be enabled.
#if SERVER
#include "PlayerRevive"
#endif