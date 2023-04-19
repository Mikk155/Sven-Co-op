#include "utils"

namespace entitymaker
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'entitymaker::entitymaker','entitymaker' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'entitymaker' ) +
            g_ScriptInfo.Description( 'When fired, Creates a entity with its same keyvalues' ) +
            g_ScriptInfo.Wiki( 'entitymaker' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    class entitymaker : ScriptBaseEntity
    {
        dictionary g_KeyValues;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            g_KeyValues[ szKey ] = szValue;
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_KeyValues.getKeys(); }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( !string( g_KeyValues[ "child_classname" ] ).IsEmpty() )
            {
                CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( g_KeyValues[ "child_classname" ] ), g_KeyValues, true );
                
                if( pEntity !is null )
                {
                    if( !string( g_KeyValues[ "child_targetname" ] ).IsEmpty() )
                    {
                        pEntity.pev.targetname = string( g_KeyValues[ "child_targetname" ] );
                    }
                    g_EntityFuncs.SetOrigin( pEntity, self.pev.origin );
                }
            }
        }

        void Precache()
        {
            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( g_KeyValues[ Key ] );

                if( Value.StartsWith( 'models/' ) )
                {
                    g_Game.PrecacheModel( Value );
                    g_Game.PrecacheGeneric( Value );
                }
                if( !string( g_KeyValues[ "child_classname" ] ).IsEmpty() )
                {
                    g_Game.PrecacheOther( Value );
                }
            }
        }
    }
}