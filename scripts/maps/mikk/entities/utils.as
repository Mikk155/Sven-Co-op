/*
	See our scripts reference or check the wiki for more information
	https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/utils.md
*/
namespace UTILS
{
    bool InsideZone( CBaseEntity@ pInsider, CBaseEntity@ pCornerZone )
    {
        bool blInside = true;
        blInside = blInside && pInsider.pev.origin.x + pInsider.pev.maxs.x >= pCornerZone.pev.origin.x + pCornerZone.pev.mins.x;
        blInside = blInside && pInsider.pev.origin.y + pInsider.pev.maxs.y >= pCornerZone.pev.origin.y + pCornerZone.pev.mins.y;
        blInside = blInside && pInsider.pev.origin.z + pInsider.pev.maxs.z >= pCornerZone.pev.origin.z + pCornerZone.pev.mins.z;
        blInside = blInside && pInsider.pev.origin.x + pInsider.pev.mins.x <= pCornerZone.pev.origin.x + pCornerZone.pev.maxs.x;
        blInside = blInside && pInsider.pev.origin.y + pInsider.pev.mins.y <= pCornerZone.pev.origin.y + pCornerZone.pev.maxs.y;
        blInside = blInside && pInsider.pev.origin.z + pInsider.pev.mins.z <= pCornerZone.pev.origin.z + pCornerZone.pev.maxs.z;

        return blInside;
    }

    void SetSize( CBaseEntity@ pMaxMin )
    {
        if( pMaxMin.GetClassname() == string(pMaxMin.pev.classname) && string( pMaxMin.pev.model )[0] == "*" && pMaxMin.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( pMaxMin, pMaxMin.pev.model );
            g_EntityFuncs.SetSize( pMaxMin.pev, pMaxMin.pev.mins, pMaxMin.pev.maxs );
        }
        else
        {
            g_EntityFuncs.SetSize( pMaxMin.pev, pMaxMin.pev.vuser1, pMaxMin.pev.vuser2 );		
        }
    }

    void TriggerMode( string key, CBaseEntity@ pActivator )
    {
        string ReadTarget = MLAN::Replace(key,{
            { "#0", "" },
            { "#1", "" },
            { "#2", "" }
        });

        if( string( key ).EndsWith( "#0" ) )
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pActivator, USE_OFF );
        }
        else if( string( key ).EndsWith( "#1" ) )
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pActivator, USE_ON );
        }
        else if( string( key ).EndsWith( "#2" ) )
        {
            do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, ReadTarget ) );
            while( g_EntityFuncs.FindEntityByTargetname( null, ReadTarget ) !is null );
        }
        else
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pActivator, USE_TOGGLE );
        }
    }

    void ShowMOTD(EHandle hPlayer, const string& in szTitle, const string& in szMessage)
    {
        if(!hPlayer){return;}
        CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
        if(pPlayer is null){return;}
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
        // If we reached the end, send the last letters of the message
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
}
// End of namespace

namespace NETWORKMSG
{
    void SVC_INTERMISSION()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION );
        message.End();
    }

    void ViewMode( int imode, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ViewMode, pPlayer.edict() );
            message.WriteByte(imode);
        message.End();
    }

    void Concuss( int yall, int pitch, int roll, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::Concuss, pPlayer.edict() );
            message.WriteFloat(yall);
            message.WriteFloat(pitch);
            message.WriteFloat(roll);
        message.End();
    }

    void GameTitle()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::GameTitle );
        message.WriteByte(1);
        message.End();
    }

    void ScoreInfo(int frags, int death, int health, int armor, int team, int icon, int server, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ScoreInfo, pPlayer.edict() );
            message.WriteByte(1);
            message.WriteFloat(frags);
            message.WriteLong(death);
            message.WriteFloat(health);
            message.WriteFloat(armor);
            message.WriteByte(team);
            message.WriteShort(icon);
            message.WriteShort(server);
        message.End();
    }

    void ServerName( const string StrTitle)
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::ServerName );
            message.WriteString(StrTitle);
        message.End();
    }
}
// End of namespace

namespace MLAN
{
    mixin class MoreKeyValues
    {
        private string_t message_spanish, message_portuguese, message_german, message_french, message_italian, message_esperanto;

        bool SexKeyValues( const string& in szKey, const string& in szValue )
        {
            if(szKey == "message_spanish")
            {
                message_spanish = szValue;
            }
            else if(szKey == "message_portuguese")
            {
                message_portuguese = szValue;
            }
            else if(szKey == "message_german")
            {
                message_german = szValue;
            }
            else if(szKey == "message_french")
            {
                message_french = szValue;
            }
            else if(szKey == "message_italian")
            {
                message_italian = szValue;
            }
            else if(szKey == "message_esperanto")
            {
                message_esperanto = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }

            return true;
        }

        string_t ReadLanguages( int iLanguage )
        {
            dictionary Languages =
            {
                {"0", self.pev.message},
                {"1", string(message_spanish).IsEmpty() ? self.pev.message : message_spanish},
                {"2", string(message_portuguese).IsEmpty() ? self.pev.message : message_portuguese},
                {"3", string(message_german).IsEmpty() ? self.pev.message : message_portuguese},
                {"4", string(message_french).IsEmpty() ? self.pev.message : message_french},
                {"5", string(message_italian).IsEmpty() ? self.pev.message : message_italian},
                {"6", string(message_esperanto).IsEmpty() ? self.pev.message : message_esperanto}
            };

            return string_t(Languages[ iLanguage ]);
        }
    }

    int GetCKV(CBasePlayer@ pPlayer, string valuename)
    {
        CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
        return int(ckvSpawns.GetKeyvalue(valuename).GetFloat());
    }

    string Replace( string_t FullSentence, dictionary@ pArgs )
    {
        string str = string(FullSentence);
        array<string> args = pArgs.getKeys();

        for (uint i = 0; i < args.length(); i++)
        {
            str.Replace(args[i], string(pArgs[args[i]]));
        }

        return str;
    }
}
// End of namespace