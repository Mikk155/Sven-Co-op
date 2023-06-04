CUtils g_Util;

enum WhoAffected_enum
{
    AP_ACTIVATOR_ONLY = 0,
    AP_ALL_PLAYERS = 1,
    AP_ALL_BUT_ACTIVATOR = 2,
    AP_ALL_ALIVE_PLAYER = 3,
    AP_ALL_DEAD_PLAYER = 4
}

final class CUtils
{
    bool Debugs = true;

    void CustomEntity( string m_iszName )
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( m_iszName ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( m_iszName + '::' + m_iszName, m_iszName );
        }
    }

    int uttoi( USE_TYPE UseTypex )
    {
        return UseTypex == USE_OFF ? 0 : UseTypex == USE_ON ? 1 : UseTypex == USE_KILL ? 2 : UseTypex == USE_SET ? 4 : 3;
    }

    USE_TYPE itout( int iUseTypex, USE_TYPE&in UseTypex = USE_TOGGLE )
    {
        if( iUseTypex == 0 )
        {
            return USE_OFF;
        }
        else if( iUseTypex == 1 )
        {
            return USE_ON;
        }
        else if( iUseTypex == 2 )
        {
            return USE_KILL;
        }
        else if( iUseTypex == 3 )
        {
            return USE_TOGGLE;
        }
        else if( iUseTypex == 4 )
        {
            return USE_SET;
        }
        else if( iUseTypex == 5 )
        {
            return UseTypex;
        }
        else if( iUseTypex == 6 )
        {
            return ( UseTypex == USE_OFF ? USE_ON : UseTypex == USE_ON ? USE_OFF : USE_TOGGLE );
        }
        return USE_TOGGLE;
    }

    Vector atov( string VectIn )
    {
        Vector VectOut;
        g_Utility.StringToVector( VectOut, VectIn );
        return VectOut;
    }

    RGBA atoc( string RgbaIn )
    {
        array<string> splitColor = { "", "", "", "" };
        splitColor = RgbaIn.Split( " " );
        array<uint8>result = {0,0,0,0};
        result[0] = atoi(splitColor[0]);
        result[1] = atoi(splitColor[1]);
        result[2] = atoi(splitColor[2]);
        result[3] = atoi(splitColor[3]);
        if( result[0] > 255) result[0] = 255;
        if( result[1] > 255) result[1] = 255;
        if( result[2] > 255) result[2] = 255;
        if( result[3] > 255) result[3] = 255;
        return RGBA( result[0], result[1], result[2], result[3] );
    }

    void Trigger( string iszTarget, CBaseEntity@&in pActivator = null, CBaseEntity@&in pCaller = null, USE_TYPE& in UseTypex = USE_TOGGLE, float&in flDelay = 0.0f )
    {
        if( iszTarget.IsEmpty() || iszTarget == '' )
        {
            return;
        }

        g_Util.Debug();

        CBaseEntity@ pFind = g_EntityFuncs.FindEntityByTargetname( g_EntityFuncs.Instance( 0 ), iszTarget );

        if( pFind is null )
        {
            g_Util.Debug( "[CUtils::Trigger] No entity found with targetname '" + iszTarget + "'" );
            return;
        }

        CBaseEntity@ pKillEnt = null;

        if( UseTypex == USE_KILL )
        {
            while( ( @pKillEnt = g_EntityFuncs.FindEntityByTargetname( g_EntityFuncs.Instance( 0 ), iszTarget ) ) !is null )
            {
                g_EntityFuncs.Remove( pKillEnt );
            }
        }
        else
        {
            g_Scheduler.SetTimeout( @this, "DelayedTrigger", flDelay, iszTarget, @pActivator, @pCaller, g_Util.uttoi( UseTypex ) );
        }

        g_Util.Debug( "[CUtils::Trigger] Fired entity '" + iszTarget + "'" );
        if( pActivator !is null ) g_Util.Debug( "[CUtils::Trigger] !activator '"+ string( pActivator.pev.classname ) + "' " + string( pActivator.pev.netname ) );
        if( pCaller !is null ) g_Util.Debug( "[CUtils::Trigger] !caller '" + pCaller.pev.classname + "'" );
        g_Util.Debug( "[CUtils::Trigger] USE_TYPE " + string( g_Util.uttoi( UseTypex ) ) );
        if( flDelay > 0.0 ) g_Util.Debug( "[CUtils::Trigger] Delay '" + flDelay + "'" );
        g_Util.Debug();
    }

    void DelayedTrigger( string iszTarget, CBaseEntity@ pActivator, CBaseEntity@ pCaller, int UseTypex )
    {
        g_EntityFuncs.FireTargets( iszTarget, pActivator, pCaller, g_Util.itout( UseTypex ), 0.0f );
    }

    string StringReplace( string FullSentence, dictionary@ pArgs )
    {
        array<string> Arguments = pArgs.getKeys();

        g_Util.Debug();
        for (uint i = 0; i < Arguments.length(); i++)
        {
            string Value = string( pArgs[ Arguments[i] ] );
            if( Value != '' )
            {
                FullSentence.Replace( Arguments[i], Value );
                g_Util.Debug( "[CUtils::StringReplace] Replaced string '" + Arguments[i] + "' -> '" + Value + "'");
            }
        }
        g_Util.Debug();
        return FullSentence;
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
        if( Debugs )
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

    string CKV( CBaseEntity@ pEntity, string szKey, string&in iszValue = String::INVALID_INDEX )
    {
        if( pEntity is null )
        {
            g_Util.Debug();
            g_Util.Debug( "[CUtils::CKV] Null entity!" );
            g_Util.Debug();
            return String::INVALID_INDEX;
        }

        if( iszValue != String::INVALID_INDEX )
        {
            dictionary g_keyvalues =
            {
                { "target", "!activator" },
                { "m_iszValueName", szKey },
                { "m_iszNewValue", iszValue },
                { "targetname", pEntity.GetTargetname() + "_ckv" }
            };
            CBaseEntity@ pChangeValue = g_EntityFuncs.CreateEntity( "trigger_changevalue", g_keyvalues );

            if( pChangeValue !is null )
            {
                pChangeValue.Use( pEntity, null, USE_ON, 0.0f );
                g_EntityFuncs.Remove( pChangeValue );
                g_Util.Debug( "[CUtils::SetCKV] '" + szKey + "' -> '" + iszValue + "' for " + ( pEntity.IsPlayer() ? pEntity.pev.netname : pEntity.pev.classname ) );
            }
        }
        return pEntity.GetCustomKeyvalues().GetKeyvalue( szKey ).GetString();
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
                    g_Util.Debug( "[CUtils::IsStringInFile] Match '" + line + "' with a wildcard [*]" );
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

    bool IsPluginInstalled( string szPluginName )
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

    CBaseEntity@ CreateEntity( dictionary@ g_Keyvalues )
    {
        CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( g_Keyvalues[ 'classname' ] ), g_Keyvalues, true );
        if( pEntity !is null && string( g_Keyvalues[ 'origin' ] ) != '' )
        {
            g_EntityFuncs.SetOrigin( pEntity, g_Util.atov( string( g_Keyvalues[ 'origin' ] ) ) );
        }
        return pEntity;
    }

    bool LoadEntities( const string iszFileLoad, string &in iszClassname = String::INVALID_INDEX )
    {
        string line, key, value;
        dictionary g_Keyvalues;

        File@ pFile = g_FileSystem.OpenFile( iszFileLoad, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Util.Debug();
            g_Util.Debug( "[CUtils::LoadEntities] Can not open '" + iszFileLoad + "' entities not initialised!" );
            g_Util.Debug();
            return false;
        }

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' || line[0] == '{' )
            {
                continue;
            }

            if( line[0] == '}' )
            {
                if( iszClassname != String::INVALID_INDEX )
                {
                    g_Keyvalues[ 'classname' ] = iszClassname;
                }

                g_Util.CreateEntity( g_Keyvalues );
                g_Keyvalues.deleteAll();
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            g_Keyvalues[ key ] = value;
        }
        pFile.Close();

        return true;
    }

    int GetNumberOfEntities( string szMatch, bool TargetName = false )
    {
        g_Util.Debug();
        int NumberOfEntities = 0;

        CBaseEntity@ pEntity = null;

        if( TargetName )
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( g_EntityFuncs.Instance( 0 ), szMatch ) ) !is null ){
                ++NumberOfEntities;
            }
        }
        else
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( g_EntityFuncs.Instance( 0 ), szMatch ) ) !is null ){
                ++NumberOfEntities;
            }
        }

        g_Util.Debug( "[CUtils::GetNumberOfEntities] Found '" + string( NumberOfEntities ) + "' Entities" );
        g_Util.Debug();
        return NumberOfEntities;
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

    // Wiki para abajo
    bool WhoAffected( CBasePlayer@ pPlayer, int &in m_iszAffectedPlayer = AP_ACTIVATOR_ONLY, CBaseEntity@ &in pActivator = null )
    {
        if( m_iszAffectedPlayer == AP_ACTIVATOR_ONLY && pPlayer == pActivator
        or m_iszAffectedPlayer == AP_ALL_PLAYERS
        or m_iszAffectedPlayer == AP_ALL_BUT_ACTIVATOR && pPlayer != pActivator
        or m_iszAffectedPlayer == AP_ALL_ALIVE_PLAYER && pPlayer.IsAlive()
        or m_iszAffectedPlayer == AP_ALL_DEAD_PLAYER && !pPlayer.IsAlive() )
        {
            if( pPlayer !is null )
            {
                return true;
            }
        }
        return false;
    }

    CBaseEntity@ GetRandomEntity( string iszTargetname )
    {
        array<CBaseEntity@>EntityArray;

        CBaseEntity@ FindEnt = null;

        while( ( @FindEnt = g_EntityFuncs.FindEntityByTargetname( g_EntityFuncs.Instance( 0 ), iszTargetname ) ) !is null )
        {
            EntityArray.insertLast( @FindEnt );
        }
        return EntityArray[ Math.RandomLong( 0, EntityArray.length() -1 ) ];
    }

    CBaseEntity@ GetRandomEntity( string_t iszClassname )
    {
        array<CBaseEntity@>EntityArray;

        CBaseEntity@ FindEnt = null;

        while( ( @FindEnt = g_EntityFuncs.FindEntityByClassname( g_EntityFuncs.Instance( 0 ), string( iszClassname ) ) ) !is null )
        {
            EntityArray.insertLast( @FindEnt );
        }
        return EntityArray[ Math.RandomLong( 0, EntityArray.length() -1 ) ];
    }

    CBaseEntity@ GetRandomEntity( string iszKey, string iszValue )
    {
        array<CBaseEntity@>EntityArray;

        CBaseEntity@ FindEnt = null;

        while( ( @FindEnt = g_EntityFuncs.FindEntityByString( g_EntityFuncs.Instance( 0 ), iszKey, iszValue ) ) !is null )
        {
            EntityArray.insertLast( @FindEnt );
        }
        return EntityArray[ Math.RandomLong( 0, EntityArray.length() -1 ) ];
    }

    CBaseEntity@ GetRandomEntity( array<CBaseEntity@>EntityArray )
    {
        return EntityArray[ Math.RandomLong( 0, EntityArray.length() -1 ) ];
    }

    void GetPattern( string &out OutPattern, string &in InPattern )
    {
        dictionary enum_Patterns =
        {
            { 'a', '-12' },
            { 'b', '-11' },
            { 'c', '-10' },
            { 'd', '-9' },
            { 'e', '-8' },
            { 'f', '-7' },
            { 'g', '-6' },
            { 'h', '-5' },
            { 'i', '-4' },
            { 'j', '-3' },
            { 'k', '-2' },
            { 'l', '-1' },
            { 'm', '0' },
            { 'n', '1' },
            { 'o', '2' },
            { 'p', '3' },
            { 'q', '4' },
            { 'r', '5' },
            { 's', '6' },
            { 't', '7' },
            { 'u', '8' },
            { 'v', '9' },
            { 'w', '10' },
            { 'x', '11' },
            { 'y', '12' },
            { 'z', '13' }
        };

        const array<string> Kz = enum_Patterns.getKeys();

        if( g_Utility.IsStringInt( InPattern ) )
        {
            for( uint i = 0; i < Kz.length(); i++ )
            {
                if( Kz[i] == InPattern )
                {
                    OutPattern = Kz[i];
                    break;
                }
            }
        }
        else
        {
            OutPattern = string( enum_Patterns[ InPattern ] );
        }
    }
}