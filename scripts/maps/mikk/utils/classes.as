#include '../utils'
namespace classes
{
    array<string> ConfigFiles();

    void InitClass( string iszMonster, string&in iszConfigFile = 'mikk/config/', string&in iszFormat = '.mkconfig' )
    {
        ConfigFiles.insertLast( iszConfigFile + iszMonster + iszFormat );
        g_CustomEntityFuncs.RegisterCustomEntity( "classes::CBaseClasses", iszMonster );
    }

    class CBaseClasses : ScriptBaseEntity
    {
        dictionary g_KeyValues;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            g_KeyValues[ szKey ] = szValue;
            return true;
        }

        void Spawn( void )
        {
            string line, key, value;

            for (uint i = 0; i < ConfigFiles.length(); i++)
            {
                if( ConfigFiles[i].Find( self.GetClassname() ) != String::INVALID_INDEX )
                {
                    File@ pFile = g_FileSystem.OpenFile( 'scripts/maps/' + ConfigFiles[i], OpenFile::READ );

                    if( pFile is null or !pFile.IsOpen() )
                    {
                        return;
                    }

                    while( !pFile.EOFReached() )
                    {
                        pFile.ReadLine( line );

                        if( line.Length() > 0 && !line.StartsWith( '//' ) )
                        {
                            key = line.SubString( 0, line.Find( '" "') );
                            key.Replace( '"', '' );

                            value = line.SubString( line.Find( '" "'), line.Length() );
                            value.Replace( '" "', '' );
                            value.Replace( '"', '' );

                            if( string( g_KeyValues[ key ] ).IsEmpty() )
                            {
                                g_KeyValues[ key ] = value;
                            }
                        }
                    }
                    pFile.Close();
                    
                    string iszClassname = string( g_KeyValues[ 'classname' ] );

                    if( !iszClassname.IsEmpty() )
                    {
                        CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( iszClassname, g_KeyValues, true );

                        if( pEntity !is null )
                        {
                            pEntity.pev.body = pev.body;
                            pEntity.pev.skin = pev.skin;
                            pEntity.pev.angles = pev.angles;
                            pEntity.pev.origin = pev.origin;
                            pEntity.pev.health = pev.health;
                            pEntity.pev.target = pev.target;
                            pEntity.pev.renderfx = pev.renderfx;
                            pEntity.pev.renderamt = pev.renderamt;
                            pEntity.pev.max_health = pev.max_health;
                            pEntity.pev.targetname = pev.targetname;
                            pEntity.pev.rendermode = pev.rendermode;
                            pEntity.pev.rendercolor = pev.rendercolor;

                            if( CDictionary( 'spawnflags' ) != '' )
                            {
                                pEntity.pev.spawnflags = pev.spawnflags;
                            }
                            if( CDictionary( 'model' ) != '' )
                            {
                                pEntity.pev.model = pev.model;
                            }
                            if( CDictionary( 'message' ) != '' )
                            {
                                pEntity.pev.message = pev.message;
                            }
                            if( CDictionary( 'netname' ) != '' )
                            {
                                pEntity.pev.netname = pev.netname;
                            }
                            if( pEntity.IsMonster() )
                            {
                                CBaseMonster@ pMonster = cast<CBaseMonster@>( pEntity );
                                CBaseMonster@ pSelf = cast<CBaseMonster@>( self );

                                if( pMonster !is null && pSelf !is null )
                                {
                                    if( CDictionary( 'displayname' ) != '' )
                                    {
                                        pMonster.m_FormattedName = pSelf.m_FormattedName;
                                    }
                                    if( CDictionary( 'TriggerTarget' ) != '' )
                                    {
                                        pMonster.m_iszTriggerTarget = pSelf.m_iszTriggerTarget;
                                    }
                                    if( CDictionary( 'TriggerCondition' ) != '' )
                                    {
                                        pMonster.m_iTriggerCondition = pSelf.m_iTriggerCondition;
                                    }
                                    if( CDictionary( 'bloodcolor' ) != '' )
                                    {
                                        pMonster.m_bloodColor = pSelf.m_bloodColor;
                                    }
                                    if( CDictionary( 'weapons' ) != '' )
                                    {
                                        pMonster.pev.weapons = pSelf.pev.weapons;
                                    }
                                }
                            }
                        }
                        g_EntityFuncs.Remove( self );
                    }
                    break;
                }
            }
        }

        string CDictionary( string&in iszkey )
        {
            return string( g_KeyValues[ iszkey ] );
        }
    }
}