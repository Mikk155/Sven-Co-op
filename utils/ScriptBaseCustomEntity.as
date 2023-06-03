mixin class ScriptBaseCustomEntity
{
    private float m_fDelay = 0.0f;
    private int m_iUseType = 3;
    private int m_iAffectedPlayer = 0;
    private string m_iszMaster();
    private string m_iszTargetnameFilter;
    private Vector minhullsize();
    private Vector maxhullsize();
    private USE_TYPE m_UTLatest = USE_TOGGLE;

    bool ExtraKeyValues( const string& in szKey, const string& in szValue )
    {
        if( szKey == "m_fDelay" || szKey == "delay" )
        {
            m_fDelay = atof( szValue );
        }
        else if( szKey == "m_iAffectedPlayer" )
        {
            m_iAffectedPlayer = atoi( szValue );
        }
        else if( szKey == "m_iUseType" )
        {
            m_iUseType = atoi( szValue );
        }
        else if( szKey == "master" )
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
        else if( szKey == "m_iszTargetnameFilter" ) 
        {
            m_iszTargetnameFilter = szValue;
        }
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }
        return true;
    }

    CBaseEntity@ GetMasterEntity()
    {
        if( !m_iszMaster.IsEmpty() )
        {
            CBaseEntity@ multisource = g_EntityFuncs.FindEntityByTargetname( multisource, m_iszMaster );

            if( multisource !is null && multisource.pev.ClassNameIs( 'multisource' ) )
            {
                return multisource;
            }
        }
        return null;
    }

    bool FilteredTargetname( CBaseEntity@ pEntity )
    {
        if( !m_iszTargetnameFilter.IsEmpty() && pEntity.GetTargetname() == m_iszTargetnameFilter )
        {
            return !m_iszTargetnameFilter.IsEmpty() && pEntity.GetTargetname() == m_iszTargetnameFilter;
        }
        return false;
    }
    bool IsLockedByMaster()
    {
        if( !m_iszMaster.IsEmpty() && !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
        {
            string iszTarget = g_Util.CKV( self, '$s_TriggerOnMaster' );

            if( iszTarget != '' )
            {
                g_Util.Trigger( iszTarget, GetMasterEntity(), self, USE_TOGGLE, 0.0f );
            }
            return true;
        }
        return false;
    }

    bool spawnflag( const int iflag )
    {
        if( iflag <= 0 && self.pev.spawnflags == 0 )
        {
            return true;
        }
        return self.pev.SpawnFlagBitSet( iflag );
    }

    void CustomModelSet( const string&in iszmodel = 'models/error.mdl' )
    {
        string newmodel = ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) );
        g_EntityFuncs.SetModel( self, newmodel );
        g_Util.Debug();
        g_Util.Debug( "ScriptBaseCustomEntity::CustomModelSet:" );
        g_Util.Debug( "Precached model '" +newmodel+ "'" );
        g_Util.Debug();
    }

    void CustomModelPrecache( const string&in iszmodel = 'models/error.mdl' )
    {
        string newmodel = ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) );
        g_Game.PrecacheModel( newmodel );
        g_Game.PrecacheGeneric( newmodel );
        g_Util.Debug();
        g_Util.Debug( "ScriptBaseCustomEntity::CustomModelSet:" );
        g_Util.Debug( "Precached model '" +newmodel+ "'" );
        g_Util.Debug();
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