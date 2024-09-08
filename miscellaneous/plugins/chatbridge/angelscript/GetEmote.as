string GetEmote( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        string emote = pJson.get( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + ":EMOTES" );
        return ( emote.IsEmpty() ? "" : emote + " " );
    }
    return "";
}