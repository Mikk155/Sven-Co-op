CUtils g_Util;

final class CUtils
{
    bool DebugEnable = true;

    void Trigger( string iszTarget, CBaseEntity@&in pActivator = null, CBaseEntity@&in pCaller = null, USE_TYPE& in useType = USE_TOGGLE, float&in flDelay = 0.0f )
    {
        if( iszTarget.IsEmpty() || iszTarget == '' )
        {
            return;
        }

        g_Util.Debug();
        CBaseEntity@ pFind = g_EntityFuncs.FindEntityByTargetname( pFind, iszTarget );

        if( pFind is null )
        {
            g_Util.Debug( "[CUtils::Trigger] No entity found with targetname '" + iszTarget + "'" );
            return;
        }

        string iUseType = ( useType == USE_OFF ) ? '0 [OFF]': ( useType == USE_ON ) ? '1 [ON]' : ( useType == USE_KILL ) ? '2 [KILL]' : ( useType == USE_SET ) ? '4 [SET]' : '3 [TOGGLE]';

        CBaseEntity@ pKillEnt = null;

        if( iUseType[0] == 2 ){
            while( ( @pKillEnt = g_EntityFuncs.FindEntityByTargetname( pKillEnt, iszTarget ) ) !is null ){
                g_EntityFuncs.Remove( pKillEnt );
            }
        }
        else{
            g_Scheduler.SetTimeout( @this, "DelayedTrigger", flDelay, iszTarget, @pActivator, @pCaller, atoi( iUseType[0] ) );
        }

        g_Util.Debug( "[CUtils::Trigger] Fired entity '" + iszTarget + "'" );
        if( pActivator !is null ) g_Util.Debug( "[CUtils::Trigger] !activator '"+ string( pActivator.pev.classname ) + "' " + string( pActivator.pev.netname ) );
        if( pCaller !is null ) g_Util.Debug( "[CUtils::Trigger] !caller '" + pCaller.pev.classname + "'" );
        g_Util.Debug( "[CUtils::Trigger] USE_TYPE " + iUseType );
        if( flDelay > 0.0 ) g_Util.Debug( "[CUtils::Trigger] Delay '" + flDelay + "'" );
        g_Util.Debug();
    }

    void DelayedTrigger( string iszTarget, CBaseEntity@ pActivator, CBaseEntity@ pCaller, int ut )
    {
        g_EntityFuncs.FireTargets( iszTarget, pActivator, pCaller, ( ut == 0 ) ? USE_OFF : ( ut == 1 ) ? USE_ON : ( ut == 4 ) ? USE_SET : USE_TOGGLE, 0.0f );
    }

    string StringReplace( string_t FullSentence, dictionary@ pArgs )
    {
        string OutString = string( FullSentence );
        array<string> Arguments = pArgs.getKeys();

        g_Util.Debug();
        for (uint i = 0; i < Arguments.length(); i++)
        {
            string Value = string( pArgs[ Arguments[i] ] );
            if( Value != '' )
            {
                OutString.Replace( Arguments[i], Value );
                g_Util.Debug( "[CUtils::StringReplace] Replaced string '" + Arguments[i] + "' -> '" + Value + "'");
            }
        }
        g_Util.Debug();
        return OutString;
    }

    void ShowMOTD( EHandle hPlayer, const string& in szTitle, const string& in szMessage )
    {
        if(!hPlayer)
        {
            return;
        }

        CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

        if(pPlayer is null)
        {
            return;
        }

        NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        title.WriteString( szTitle );
        title.End();

        uint iChars = 0;
        string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

        for( uint uChars = 0; uChars < szMessage.Length(); uChars++ )
        {
            szSplitMsg.SetCharAt( iChars, char( szMessage[ uChars ] ) );
            iChars++;
            if( iChars == 32 )
            {
                NetworkMessage message( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                message.WriteByte( 0 );
                message.WriteString( szSplitMsg );
                message.End();
                
                iChars = 0;
            }
        }

        if( iChars > 0 )
        {
            szSplitMsg.Truncate( iChars );
            NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
            fix.WriteByte( 0 );
            fix.WriteString( szSplitMsg );
            fix.End();
        }

        NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
        endMOTD.WriteByte( 1 );
        endMOTD.WriteString( "\n" );
        endMOTD.End();

        NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
        restore.End();
    }

    void Debug( const string& in szMessage = '================================' )
    {
        if( DebugEnable )
        {
            if( g_EngineFuncs.IsDedicatedServer() )
            {
                g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, szMessage + "\n" );
            }
            else
            {
                if( g_PlayerFuncs.GetNumPlayers() > 1 )
                {
                    g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, szMessage + "\n" );
                }
                else
                {
                    g_Game.AlertMessage( at_console, szMessage + "\n" );
                }
            }
        }
    }

    string GetCKV( CBaseEntity@ pEntity, string szKey )
    {
        // -TODO Return invalid index if !has keyvalue
        if( pEntity is null or szKey.IsEmpty() )
        {
            g_Util.Debug();
            g_Util.Debug( "[CUtils::GetCKV] Null entity n/or key!" );
            g_Util.Debug();
            return String::INVALID_INDEX;
        }

        return pEntity.GetCustomKeyvalues().GetKeyvalue( szKey ).GetString();
    }

    void SetCKV( CBaseEntity@ pEntity, string szKey, string szValue )
    {
        if( pEntity is null or szKey.IsEmpty() or szValue.IsEmpty() )
        {
            g_Util.Debug();
            g_Util.Debug( "[CUtils::SetCKV] Null entity n/or key/value!" );
            g_Util.Debug();
            return;
        }

        dictionary g_keyvalues =
        {
            { "target", "!activator" },
            { "m_iszValueName", szKey },
            { "m_iszNewValue", szValue },
            { "targetname", pEntity.GetTargetname() + "_ckv" }
        };
        CBaseEntity@ pChangeValue = g_EntityFuncs.CreateEntity( "trigger_changevalue", g_keyvalues );

        if( pChangeValue !is null )
        {
            pChangeValue.Use( pEntity, null, USE_ON, 0.0f );
            g_EntityFuncs.Remove( pChangeValue );
            // g_Util.Debug( "[CUtils::SetCKV] '" + szKey + "' -> '" + szValue + "' for " + ( pEntity.IsPlayer() ? pEntity.pev.netname : pEntity.pev.classname ) );
        }
    }

    bool IsStringInFile( const string& in szPath, string& in szComparator )
    {
        g_Util.Debug();
        File@ pFile = g_FileSystem.OpenFile( szPath, OpenFile::READ );

        if( pFile is null || !pFile.IsOpen() )
        {
            g_Util.Debug( "[CUtils::IsStringInFile] Can NOT open file '" + szPath + "'" );
            g_Util.Debug();
            return false;
        }
        g_Util.Debug( "[CUtils::IsStringInFile] Opened file '" + szPath + "' for matching string '" + szComparator + "'" );

        string strMap = szComparator;
        strMap.ToLowercase();

        string line;

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );
            line.Trim();

            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
                continue;

            line.ToLowercase();

            if( strMap == line )
            {
                pFile.Close();
                g_Util.Debug( "[CUtils::IsStringInFile] Match '" + line + "'" );
                g_Util.Debug();
                return true;
            }

            if( line.EndsWith( "*", String::CaseInsensitive ) )
            {
                line = line.SubString( 0, line.Length()-1 );

                if( strMap.Find( line ) != Math.SIZE_MAX )
                {
                    pFile.Close();
                    g_Util.Debug( "[CUtils::IsStringInFile] Match '" + line + "' with a prefix [*]" );
                    g_Util.Debug();
                    return true;
                }
            }
        }

        pFile.Close();
        g_Util.Debug( "[CUtils::IsStringInFile] Nothing matched in the file." );
        g_Util.Debug();

        return false;
    }

    bool IsPluginInstalled( const string& in szPluginName )
    {
        g_Util.Debug();
        array<string> pluginList = g_PluginManager.GetPluginList();

        if( pluginList.find( szPluginName ) >= 0 )
        {
            g_Util.Debug( "[CUtils::IsPluginInstalled] Plugin '" + szPluginName + "' is installed." );
            g_Util.Debug();
            return true;
        }
        g_Util.Debug( "[CUtils::IsPluginInstalled] Plugin '" + szPluginName + "' is NOT installed." );
        g_Util.Debug();
        return false;
    }

    string LoadEntitiesDebugger;

    bool LoadEntities( const string& in EntFileLoadText, const string& in szClassname = '' )
    {
        LoadEntitiesDebugger = "";

        string line, key, value;
        bool match = false;
        dictionary g_KeyValues;

        File@ pFile = g_FileSystem.OpenFile( EntFileLoadText, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            LoadEntitiesDebugger = LoadEntitiesDebugger + "[CUtils::LoadEntities] Failed to open " + EntFileLoadText + " no entities initialised!\n";
            return false;
        }

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 )
            {
                continue;
            }

            if( line[0] == '/' and line[1] == '/' )
            {
                LoadEntitiesDebugger = LoadEntitiesDebugger + line + "\n";
                continue;
            }

            if( line == '"match"' )
            {
                match = true;
            }

            if( line[0] == '{' or line[0] == '}' )
            {
                LoadEntitiesDebugger = LoadEntitiesDebugger + string( line[0] ) + '\n';

                if( line[0] == '}' )
                {
                    if( match )
                    {
                        match = false;
                        continue;
                    }

                    string g_Classname = string( g_KeyValues[ "classname" ] );
                    string Classname = ( g_Classname.IsEmpty() || g_Classname.Length() < 2 ? szClassname : g_Classname );

                    CBaseEntity@ pInitialized = g_EntityFuncs.CreateEntity( Classname, g_KeyValues, true );

                    if( pInitialized !is null )
                    {
                        LoadEntitiesDebugger = LoadEntitiesDebugger + "[CUtils::LoadEntities] Entity '" + Classname + "' initialised.\n";
                    }
                    else
                    {
                        LoadEntitiesDebugger = LoadEntitiesDebugger + "[CUtils::LoadEntities] A entity was not initialised.\n";
                    }

                    LoadEntitiesDebugger = LoadEntitiesDebugger + "[CUtils::LoadEntities] Clearing Dictionary...\n";
                    g_KeyValues.deleteAll();
                }
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            if( match )
            {
                CBaseEntity@ pMatch = null;

                while( ( @pMatch = g_EntityFuncs.FindEntityByString( pMatch, key, value ) ) !is null )
                {
                    if( !pMatch.GetCustomKeyvalues().HasKeyvalue( "$i_ripent" ) )
                    {
                        g_EntityFuncs.Remove( pMatch );
                        LoadEntitiesDebugger = LoadEntitiesDebugger + '[CUtils::LoadEntities] Matched and removed entity with key and value ';
                    }
                }
            }

            LoadEntitiesDebugger = LoadEntitiesDebugger + '"'+key+'" "'+value+'"\n';

            g_KeyValues[ key ] = value;
        }
        pFile.Close();

        return true;
    }

    int GetNumberOfEntities( const string& in szClassname, bool TargetName = false )
    {
        g_Util.Debug();
        int NumberOfEntities = 0;

        CBaseEntity@ pEntity = null;

        if( TargetName )
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, szClassname ) ) !is null ){
                ++NumberOfEntities;
            }
        }
        else
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, szClassname ) ) !is null ){
                ++NumberOfEntities;
            }
        }

        g_Util.Debug( "[CUtils::GetNumberOfEntities] Found '" + string( NumberOfEntities ) + "' Entities" );
        g_Util.Debug();
        return NumberOfEntities;
    }

    Vector StringToVec( const string& in VectIn )
    {
        Vector VectOut;
        g_Utility.StringToVector( VectOut, VectIn );
        return VectOut;
    }

    void ExecPlayerCommand( CBasePlayer@ pPlayer, const string command )
    {
        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString( command );
        msg.End();
    }

    dictionary GetKeyAndValue( const string iszFileLoad, dictionary g_KeyValues, const bool blReplaceDict = false )
    {
        string line, key, value;

        File@ pFile = g_FileSystem.OpenFile( /* 'scripts/maps/' + */ iszFileLoad, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            return g_KeyValues;
        }

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 || line[0] == '/' and line[1] == '/' )
            {
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            if( blReplaceDict )
            {
                g_KeyValues[ key ] = value;
            }
            else if( string( g_KeyValues[ key ] ).IsEmpty() )
            {
                g_KeyValues[ key ] = value;
            }
        }
        pFile.Close();

        return g_KeyValues;
    }
}

CClientCommand g_LoadEntities( "entitydata", "Shows information of CUtils::LoadEntities", @LoadEntitiesInformation );

void LoadEntitiesInformation( const CCommand@ pArguments )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    string gLoadedEnts = g_Util.LoadEntitiesDebugger;

    if( gLoadedEnts != '' )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[LoadEntitiesInformation] Printed initialised entities info at your console.\n" );
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "\n====================================\n" );

        while( gLoadedEnts != '' )
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  gLoadedEnts.SubString( 0, 68 ) );

            if( gLoadedEnts.Length() <= 68 ) gLoadedEnts = '';
            else gLoadedEnts = gLoadedEnts.SubString( 68, gLoadedEnts.Length() );
        }

        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "\n====================================\n\n" );
    }
    else
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[LoadEntitiesInformation] No entities has been loaded yet.\n" );
    }
}