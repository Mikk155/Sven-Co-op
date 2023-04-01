#include "../maps/mikk/env_bloodpuddle"
void MapInit()
{
    env_bloodpuddle::model( 'models/mikk/misc/bloodpuddle.mdl' );
    env_bloodpuddle::fade = false;
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor('Gaftherman');
    g_Module.ScriptInfo.SetContactInfo('https://discord.gg/VsNnE3A7j8');
}