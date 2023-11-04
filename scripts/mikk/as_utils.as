#include 'CUtility'
#include 'CPlayerFuncs'
#include 'CEntityFuncs'
#include 'CMap'
#include 'CHooks'
#include 'CFileManager'
#include 'ScriptBaseCustomEntity'

CMKUtils mk;

class CMKUtils
{
    string GetDiscord(){ return 'https://discord.gg/VsNnE3A7j8';}

    CMKPlayerFuncs PlayerFuncs;
    CMKEntityFuncs EntityFuncs;
    CMKFileManager FileManager;
    CMKHooks Hooks;
    CMKMap Map;

    CMKUtils()
    {
        PlayerFuncs = CMKPlayerFuncs();
        EntityFuncs = CMKEntityFuncs();
        FileManager = CMKFileManager();
        Hooks = CMKHooks();
        Map = CMKMap();
    }
}