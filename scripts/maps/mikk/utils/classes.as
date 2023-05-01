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

                        PassEntvars( pEntity, self, g_KeyValues );
                        g_EntityFuncs.Remove( self );
                    }
                    break;
                }
            }
        }
    }

    string CDictionary( string&in iszkey, dictionary g_dictionary )
    {
        return string( g_dictionary[ iszkey ] );
    }
    
    void PassEntvars( CBaseEntity@ pNewEnt, CBaseEntity@ pOldent, dictionary d = null )
    {
        if( pNewEnt !is null && pOldent !is null )
        {
            pNewEnt.pev.body = pOldent.pev.body;
            pNewEnt.pev.skin = pOldent.pev.skin;
            pNewEnt.pev.angles = pOldent.pev.angles;
            pNewEnt.pev.origin = pOldent.pev.origin;
            pNewEnt.pev.health = pOldent.pev.health;
            pNewEnt.pev.target = pOldent.pev.target;
            pNewEnt.pev.renderfx = pOldent.pev.renderfx;
            pNewEnt.pev.renderamt = pOldent.pev.renderamt;
            pNewEnt.pev.max_health = pOldent.pev.max_health;
            pNewEnt.pev.targetname = pOldent.pev.targetname;
            pNewEnt.pev.rendermode = pOldent.pev.rendermode;
            pNewEnt.pev.rendercolor = pOldent.pev.rendercolor;

            if( CDictionary( 'spawnflags', d ) != '' )
            {
                pNewEnt.pev.spawnflags = pOldent.pev.spawnflags;
            }
            if( CDictionary( 'model', d ) != '' )
            {
                pNewEnt.pev.model = pOldent.pev.model;
            }
            if( CDictionary( 'message', d ) != '' )
            {
                pNewEnt.pev.message = pOldent.pev.message;
            }
            if( CDictionary( 'netname', d ) != '' )
            {
                pNewEnt.pev.netname = pOldent.pev.netname;
            }
            if( pNewEnt.IsMonster() )
            {
                CBaseMonster@ pNewMonster = cast<CBaseMonster@>( pNewEnt );
                CBaseMonster@ pOldMonster = cast<CBaseMonster@>( pOldent );

                if( pNewMonster !is null && pOldMonster !is null )
                {
                    if( CDictionary( 'displayname', d ) != '' )
                    {
                        pNewMonster.m_FormattedName = pOldMonster.m_FormattedName;
                    }
                    if( CDictionary( 'TriggerTarget', d ) != '' )
                    {
                        pNewMonster.m_iszTriggerTarget = pOldMonster.m_iszTriggerTarget;
                    }
                    if( CDictionary( 'TriggerCondition', d ) != '' )
                    {
                        pNewMonster.m_iTriggerCondition = pOldMonster.m_iTriggerCondition;
                    }
                    if( CDictionary( 'bloodcolor', d ) != '' )
                    {
                        pNewMonster.m_bloodColor = pOldMonster.m_bloodColor;
                    }
                    if( CDictionary( 'weapons', d ) != '' )
                    {
                        pNewMonster.pev.weapons = pOldMonster.pev.weapons;
                    }
                }
            }
        }
    }
}