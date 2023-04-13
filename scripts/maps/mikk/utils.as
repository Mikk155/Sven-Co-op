bool ShowDebugs = false;

CUtils g_Util;

final class CUtils
{
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
        if( ShowDebugs )
        {
            if( g_EngineFuncs.IsDedicatedServer() )
            {
                g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, szMessage + "\n" );
            }
            else
            {
                g_Game.AlertMessage( at_console, szMessage + "\n" );
            }
        }
    }

    string GetCKV( CBaseEntity@ pEntity, string szKey )
    {
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
        g_Util.Debug();

        if( pEntity is null or szKey.IsEmpty() or szValue.IsEmpty() )
        {
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
            g_Util.Debug( "[CUtils::SetCKV] '" + szKey + "' -> '" + szValue + "' for " + ( pEntity.IsPlayer() ? pEntity.pev.netname : pEntity.pev.classname ) );
        }
        g_Util.Debug();
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

    string RIPENTDebugger;

    bool LoadEntities( const string& in EntFileLoadText, const string& in szClassname = '' )
    {
        RIPENTDebugger = "";

        string line, key, value;
        bool match = false;
        dictionary g_KeyValues;

        File@ pFile = g_FileSystem.OpenFile( EntFileLoadText, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            RIPENTDebugger = RIPENTDebugger + "[CUtils::LoadEntities] Failed to open " + EntFileLoadText + " no entities initialised!\n";
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
                RIPENTDebugger = RIPENTDebugger + line + "\n";
                continue;
            }

            if( line == '"match"' )
            {
                match = true;
            }

            if( line[0] == '{' or line[0] == '}' )
            {
                RIPENTDebugger = RIPENTDebugger + string( line[0] ) + '\n';

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
                        RIPENTDebugger = RIPENTDebugger + "[CUtils::LoadEntities] Entity '" + Classname + "' initialised.\n";
                    }
                    else
                    {
                        RIPENTDebugger = RIPENTDebugger + "[CUtils::LoadEntities] A entity was not initialised.\n";
                    }

                    RIPENTDebugger = RIPENTDebugger + "[CUtils::LoadEntities] Clearing Dictionary...\n";
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
                        RIPENTDebugger = RIPENTDebugger + '[CUtils::LoadEntities] Matched and removed entity with key and value ';
                    }
                }
            }

            RIPENTDebugger = RIPENTDebugger + '"'+key+'" "'+value+'"\n';

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

    bool Reflection( const string& in szFunction )
    {
        Reflection::Function@ fNameFunction = Reflection::g_Reflection.Module.FindGlobalFunction( szFunction );

        if( fNameFunction is null )
        {
            return false;
        }
        fNameFunction.Call();
        return true;
    }

    bool CustomEntity( const string& in szClass = '', const string& in szClassname = '' )
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( szClassname ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( szClass, szClassname );
        }
        return g_CustomEntityFuncs.IsCustomEntity( szClassname );
    }

    Vector StringToVec( const string& in VectIn )
    {
        Vector VectOut;
        g_Utility.StringToVector( VectOut, VectIn );
        return VectOut;
    }
}

CClientCommand g_LoadEntities( "ripent", "Shows information of CUtils::LoadEntities", @LoadEntitiesInformation );

void LoadEntitiesInformation( const CCommand@ pArguments )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[LoadEntitiesInformation] Printed initialised entities info at your console.\n" );

    while( g_Util.RIPENTDebugger != '' )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  g_Util.RIPENTDebugger.SubString( 0, 68 ) );

        if( g_Util.RIPENTDebugger.Length() <= 68 ) g_Util.RIPENTDebugger = '';
        else g_Util.RIPENTDebugger = g_Util.RIPENTDebugger.SubString( 68, g_Util.RIPENTDebugger.Length() );
    }

    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "\n====================================\n\n" );
}

mixin class ScriptBaseLanguages
{
    private string_t message_spanish,
    message_portuguese, message_german,
    message_french, message_italian,
    message_esperanto, message_czech,
    message_dutch, message_spanish2,
    message_indonesian, message_romanian,
    message_turkish, message_albanian;

    bool Languages( const string& in szKey, const string& in szValue )
    {
        if( szKey == "message_spanish" )
        {
            message_spanish = szValue;
        }
        else if( szKey == "message_spanish2" )
        {
            message_spanish2 = szValue;
        }
        else if( szKey == "message_portuguese" )
        {
            message_portuguese = szValue;
        }
        else if( szKey == "message_german" )
        {
            message_german = szValue;
        }
        else if( szKey == "message_french" )
        {
            message_french = szValue;
        }
        else if( szKey == "message_italian" )
        {
            message_italian = szValue;
        }
        else if( szKey == "message_esperanto" )
        {
            message_esperanto = szValue;
        }
        else if( szKey == "message_czech" )
        {
            message_czech = szValue;
        }
        else if( szKey == "message_dutch" )
        {
            message_dutch = szValue;
        }
        else if( szKey == "message_indonesian" )
        {
            message_indonesian = szValue;
        }
        else if( szKey == "message_romanian" )
        {
            message_romanian = szValue;
        }
        else if( szKey == "message_turkish" )
        {
            message_turkish = szValue;
        }
        else if( szKey == "message_albanian" )
        {
            message_albanian = szValue;
        }
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }

        return true;
    }

    string_t ReadLanguages( CBasePlayer@ pPlayer )
    {
        string CurrentLanguage = g_Util.GetCKV( pPlayer, "$s_language" );

        dictionary Languages =
        {
            { "english", self.pev.message },
            { "spanish", message_spanish == '' ?message_spanish2 == '' ? self.pev.message : message_spanish2 : message_spanish },
            { "spanish spain", message_spanish2 == '' ? message_spanish == '' ? self.pev.message : message_spanish : message_spanish2 },
            { "portuguese", message_portuguese == '' ? self.pev.message : message_portuguese },
            { "german", message_german == '' ? self.pev.message : message_german },
            { "french", message_french == '' ? self.pev.message : message_french },
            { "italian", message_italian == '' ? self.pev.message : message_italian },
            { "esperanto", message_esperanto == '' ? self.pev.message : message_esperanto },
            { "czech", message_czech == '' ? self.pev.message : message_czech },
            { "dutch", message_dutch == '' ? self.pev.message : message_dutch },
            { "indonesian", message_indonesian == '' ? self.pev.message : message_indonesian },
            { "romanian", message_romanian == '' ? self.pev.message : message_romanian },
            { "turkish", message_turkish == '' ? self.pev.message : message_turkish },
            { "albanian", message_albanian == '' ? self.pev.message : message_albanian }
        };
        
        if( CurrentLanguage == "" || CurrentLanguage.IsEmpty() )
        {
            return string_t( self.pev.message );
        }

        return string_t( Languages[ CurrentLanguage ] );
    }
}

mixin class ScriptBaseCustomEntity
{
    private float delay = 0.0f;
    private float wait = 0.0f;
    private Vector minhullsize();
    private Vector maxhullsize();
    private string m_iszMaster();
    private int m_integer;
    private float m_float;
    private string m_string;

    bool ExtraKeyValues( const string& in szKey, const string& in szValue )
    {
        if( szKey == "delay" )
        {
            delay = atof(szValue);
        }
        else if( szKey == "wait" )
        {
            wait = atof(szValue);
        }
        else if ( szKey == "master" )
        {
            this.m_iszMaster = szValue;
        }
        else if( szKey == "minhullsize" ) 
        {
            g_Utility.StringToVector( minhullsize, szValue );
        }
        else if( szKey == "maxhullsize" ) 
        {
            g_Utility.StringToVector( maxhullsize, szValue );
        }
        else if( szKey == "m_integer" ) 
        {
            m_integer = atoi(szValue);
        }
        else if( szKey == "m_float" ) 
        {
            m_float = atof(szValue);
        }
        else if( szKey == "m_string" ) 
        {
            m_string = szValue;
        }
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }
        return true;
    }

    bool IsLockedByMaster()
    {
        if( !m_iszMaster.IsEmpty()
        and !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
        {
            return true;
        }
        return false;
    }

    bool spawnflag( const int& in iFlagSet )
    {
        if( iFlagSet <= 0 && self.pev.spawnflags == 0 )
        {
            return true;
        }
        else if( self.pev.SpawnFlagBitSet( iFlagSet ) )
        {
            return true;
        }
        return false;
    }
    
    void CustomModelSet( const string&in iszmodel = 'models/error.mdl' )
    {
        g_EntityFuncs.SetModel( self, ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) ) );
    }
    
    void CustomModelPrecache( const string&in iszmodel = 'models/error.mdl' )
    {
        g_Game.PrecacheModel( ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) ) );
        g_Game.PrecacheGeneric( ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) ) );
    }

    bool SetBoundaries()
    {
        g_Util.Debug();
        g_Util.Debug( "ScriptBaseCustomEntity::SetBoundaries:" );
        if( string( self.pev.model ).StartsWith( "*" ) && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, string( self.pev.model ) );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
            g_Util.Debug( "Set size of entity '" + string( self.pev.classname ) + "'" );
            g_Util.Debug( "model '"+ string( self.pev.model ) +"'" );
            g_Util.Debug( "origin '" + self.pev.origin.ToString() + "'" );
            g_Util.Debug();
            return true;
        }
        else if( minhullsize != g_vecZero && maxhullsize != g_vecZero )
        {
            g_Util.Debug( "Set size of entity '" + string( self.pev.classname ) + "'" );
            if( self.pev.origin != g_vecZero )
            {
                g_EntityFuncs.SetOrigin( self, self.pev.origin );
                g_Util.Debug( "Origin: '" + self.pev.origin.ToString() + "'" );
            }
            else
            {
                g_Util.Debug( "Max BBox (world size): '" + maxhullsize.ToString() + "'" );
                g_Util.Debug( "Min BBox (world size): '" + minhullsize.ToString() + "'" );
            }

            g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
            g_Util.Debug( "Max BBox: '" + maxhullsize.ToString() + "'" );
            g_Util.Debug( "Min BBox: '" + minhullsize.ToString() + "'" );
            g_Util.Debug();
            return true;
        }
        g_Util.Debug( "Can not set size. not model /n/or/ hullsizes set!" );
        g_Util.Debug( "For entity '" + string( self.pev.classname ) + "'" );
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        g_Util.Debug( "Origin: '" + self.pev.origin.ToString() + "'" );
        g_Util.Debug();
        return false;
    }
}

namespace utils
{
    void script_random_value( CBaseEntity@ self )
    {
        g_Util.SetCKV( self, "$i_random", string( Math.RandomLong( int( self.pev.health ), int( self.pev.max_health ) ) ) );
        g_Util.SetCKV( self, "$f_random", string( Math.RandomFloat( self.pev.health , self.pev.max_health ) ) );
        self.Use( null, null, USE_OFF, 0.0f );
    }

    void script_survival_mode( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flDelay )
    {
        if( !g_SurvivalMode.MapSupportEnabled() ) { return; }
        if( useType == USE_ON ) { g_SurvivalMode.Enable( true ); }
        else if( useType == USE_OFF ) { g_SurvivalMode.Disable(); }
        else { g_SurvivalMode.Toggle(); }
    }

    void script_alien_teleport( CBaseEntity@ self )
    {
        int[] iPlayer( g_Engine.maxClients + 1 );

        int iPlayerCount = 0;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

            if( pPlayer is null || !pPlayer.IsAlive() || !pPlayer.IsConnected() || (pPlayer.pev.flags & FL_FROZEN) != 0 )
            {
                continue;
            }

            iPlayer[iPlayerCount] = i;
            iPlayerCount++;
        }

        int iPlayerIndex = ( iPlayerCount == 0 ) ? -1 : iPlayer[ Math.RandomLong( 0, iPlayerCount-1 ) ];

        if( iPlayerIndex == -1 )
        {
            return;
        }

        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );
        Vector vecSrc = pPlayer.pev.origin;
        Vector vecEnd = vecSrc + Vector(Math.RandomLong(-512,512), Math.RandomLong(-512,512), 0);
        float flDir = Math.RandomLong(-360,360);

        vecEnd = vecEnd + g_Engine.v_right * flDir;

        TraceResult tr;
        g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

        if( tr.flFraction >= 1.0 )
        {
            HULL_NUMBER hullCheck = human_hull;

            hullCheck = head_hull;

            g_Utility.TraceHull( vecEnd, vecEnd, dont_ignore_monsters, hullCheck, pPlayer.edict(), tr );

            if( tr.fAllSolid == 1 || tr.fStartSolid == 1 || tr.fInOpen == 0 )
            {
                g_Util.Trigger( self.pev.noise, pPlayer, self, USE_TOGGLE, 0.0f );
                return;
            }
            else
            {
                CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( self.pev.netname ), null, true );

                if( pEntity !is null )
                {
                    g_EntityFuncs.SetOrigin( pEntity, vecEnd );
                    Vector vecAngles = Math.VecToAngles( pPlayer.pev.origin - pEntity.pev.origin );
                    pEntity.pev.angles.y = vecAngles.y;

                    CBaseEntity@ pXenMaker = g_EntityFuncs.FindEntityByTargetname( pXenMaker, ( self.pev.target ) );
                    
                    if( pXenMaker !is null )
                    {
                        Vector VecOld = pXenMaker.pev.origin;

                        pXenMaker.pev.origin = pEntity.pev.origin + Vector( 0, 40, 0 );
                        pXenMaker.Use( self, self, USE_TOGGLE, 0.0f );

                        pXenMaker.pev.origin = VecOld;
                    }
                    g_Util.Trigger( self.pev.message, pPlayer, pEntity, USE_TOGGLE, 0.0f );
                }
            }
        }
    }
}

CEffects g_Effect;
final class CEffects
{
    void beamfollow(
    CBaseEntity@ pEntity,
    string iszModel,
    int ifadetime,
    int iscale,
    Vector VecColor,
    int irenderamt
    ){
        int iEntityIndex = g_EntityFuncs.EntIndex( pEntity.edict() );
        NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            message.WriteByte( TE_BEAMFOLLOW );
            message.WriteShort( iEntityIndex );
            message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            message.WriteByte( ifadetime );
            message.WriteByte( iscale );
            message.WriteByte( int( VecColor.x ) );
            message.WriteByte( int( VecColor.y ) );
            message.WriteByte( int( VecColor.z ) );
            message.WriteByte( irenderamt );
        message.End();
    }

    void spritefield(
    Vector VecStart,
    string iszModel,
    uint16 radius = 128,
    uint8 count = 128, 
    uint8 flags = 30,
    uint8 life = 5
    ){
        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            m.WriteByte( TE_FIREFIELD );
            m.WriteCoord( VecStart.x );
            m.WriteCoord( VecStart.y );
            m.WriteCoord( VecStart.z );
            m.WriteShort( radius );
            m.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            m.WriteByte( count );
            m.WriteByte( flags );
            m.WriteByte( life );
        m.End();
    }

    void dlight
    (
        Vector VecStart,
        Vector VecColor,
        uint8 i8radius = 32,
        uint8 i8life = 255, 
        uint8 i8noise = 255
    ){
        NetworkMessage dlight( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            dlight.WriteByte( TE_DLIGHT );

            dlight.WriteCoord( VecStart.x );
            dlight.WriteCoord( VecStart.y );
            dlight.WriteCoord( VecStart.z );

            dlight.WriteByte( i8radius );
            dlight.WriteByte( int( VecColor.x ) );
            dlight.WriteByte( int( VecColor.y ) );
            dlight.WriteByte( int( VecColor.z ) );
            dlight.WriteByte( i8life );
            dlight.WriteByte( i8noise );
        dlight.End();
    }

    void toxic
    (
        Vector VecStart
    ){
        NetworkMessage message( MSG_PVS, NetworkMessages::ToxicCloud );
        message.WriteCoord( VecStart.x );
        message.WriteCoord( VecStart.y );
        message.WriteCoord( VecStart.z );
        message.End();
    }

    void disk
    (
        Vector VecStart,
        string iszModel,
        uint8 iRadius,
        Vector VecColor,
        int renderamt,
        uint8 startFrame,
        uint8 HoldTime
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte(TE_BEAMDISK);
            Message.WriteCoord( VecStart.x);
            Message.WriteCoord( VecStart.y);
            Message.WriteCoord( VecStart.z);
            Message.WriteCoord( VecStart.x);
            Message.WriteCoord( VecStart.y);
            Message.WriteCoord( VecStart.z + iRadius );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( startFrame );
            Message.WriteByte( 16 );
            Message.WriteByte( HoldTime );
            Message.WriteByte(1);
            Message.WriteByte(0);
            Message.WriteByte( atoui( VecColor.x ) );
            Message.WriteByte( atoui( VecColor.y ) );
            Message.WriteByte( atoui( VecColor.z ) );
            Message.WriteByte( renderamt );
            Message.WriteByte( 0 );
        Message.End();
    }

    void splash
    (
        Vector VecStart,
        Vector VecVelocity,
        uint uiColor,
        uint uiSpeed,
        uint uiNoise,
        uint uiCount

    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_STREAK_SPLASH );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecVelocity.x );
            Message.WriteCoord( VecVelocity.y );
            Message.WriteCoord( VecVelocity.z );
            Message.WriteByte( uiColor );
            Message.WriteShort( uiCount );
            Message.WriteShort( uiSpeed );
            Message.WriteShort( uiNoise );
        Message.End();
    }

    void tracer
    (
        Vector VecStart,
        Vector VecVelocity,
        uint uiHoldtime,
        uint uiLength,
        uint uiColor

    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_USERTRACER );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecVelocity.x  );
            Message.WriteCoord( VecVelocity.y  );
            Message.WriteCoord( VecVelocity.z  );
            Message.WriteByte( uiHoldtime );
            Message.WriteByte( uiColor );
            Message.WriteByte( uiLength );
        Message.End();
    }

    void spriteshooter
    (
        Vector VecStart,
        string iszModel,
        int iCount,
        int iLife,
        int iScale,
        int iNoise
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_SPRITETRAIL );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( iCount );
            Message.WriteByte( iLife );
            Message.WriteByte( iScale );
            Message.WriteByte( iNoise );
            Message.WriteByte( 16 );
        Message.End();
    }

    void quake
    (
        Vector VecStart,
        int iFlags
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( ( iFlags == 0 ) ? TE_TAREXPLOSION : TE_TELEPORT  );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
        Message.End();
    }

    void implosion
    (
        Vector VecStart,
        uint8 i8Radius,
        uint8 i8Count,
        uint8 i8Life
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_IMPLOSION );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteByte( i8Radius );
            Message.WriteByte( i8Count );
            Message.WriteByte( i8Life );
        Message.End();
    }

    void cylinder
    (
        Vector VecStart,
        string iszModel,
        uint8 iRadius,
        int iFlags,
        Vector VecColor,
        int renderamt,
        uint8 scrollSpeed,
        uint8 startFrame,
        uint8 frameRate,
        uint8 life
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( ( iFlags == 0 ) ? TE_BEAMCYLINDER : TE_BEAMTORUS );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z + iRadius );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( startFrame );
            Message.WriteByte( frameRate );
            Message.WriteByte( life );
            Message.WriteByte( 8 );
            Message.WriteByte( 0 );
            Message.WriteByte( atoui( VecColor.x ) );
            Message.WriteByte( atoui( VecColor.y ) );
            Message.WriteByte( atoui( VecColor.z ) );
            Message.WriteByte( renderamt );
            Message.WriteByte( scrollSpeed );
        Message.End();
    }

    void smoke
    (
        Vector VecStart,
        string iszModel,
        int iscale,
        int iframerate
    ){
        NetworkMessage Message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            Message.WriteByte( TE_SMOKE );
            Message.WriteCoord( VecStart.x );
            Message.WriteCoord( VecStart.y );
            Message.WriteCoord( VecStart.z );
            Message.WriteShort( g_EngineFuncs.ModelIndex( iszModel ) );
            Message.WriteByte( iscale );
            Message.WriteByte( iframerate );
        Message.End();
    }
}