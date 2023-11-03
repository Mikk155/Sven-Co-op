#include 'utils/CUtility'
#include 'utils/CPlayerFuncs'
#include 'utils/CEntityFuncs'
#include 'utils/CMap'
#include 'utils/CHooks'
#include 'utils/CFileManager'
#include 'utils/ScriptBaseCustomEntity'

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