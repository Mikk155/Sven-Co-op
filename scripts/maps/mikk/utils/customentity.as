#include 'information'
#include 'reflection'
#include 'utility'
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

    bool IsLockedByMaster( CBaseEntity@ &in pActivator = null )
    {
        if( !m_iszMaster.IsEmpty()
        and !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
        {
            string iszTarget = g_Util.GetCKV( self, '$s_TriggerOnMaster' );
            if( iszTarget != '' )
            {
                if( pActivator is null )
                {
                    CBaseEntity@ multisource = g_EntityFuncs.FindEntityByTargetname( multisource, m_iszMaster );
                    
                    if( multisource !is null && multisource.pev.classname == 'multisource' )
                    {
                        @pActivator = multisource;
                    }
                }
                g_Util.Trigger( iszTarget, ( pActivator !is null ) ? pActivator : null, self, USE_TOGGLE, 0.0f );
            }
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
                g_Util.Debug( "Max BBox: '" + maxhullsize.ToString() + "'" );
                g_Util.Debug( "Min BBox: '" + minhullsize.ToString() + "'" );
                g_Util.Debug( "Origin: '" + self.pev.origin.ToString() + "'" );
            }
            else
            {
                g_Util.Debug( "Max BBox (world size): '" + maxhullsize.ToString() + "'" );
                g_Util.Debug( "Min BBox (world size): '" + minhullsize.ToString() + "'" );
            }

            g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
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