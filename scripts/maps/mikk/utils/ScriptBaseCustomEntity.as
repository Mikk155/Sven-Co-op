
enum ScriptBaseCustomEntity_SetBounds
{
    SetBounds_NONE = 0,
    SetBounds_BSP = 1,
    SetBounds_ORIGIN = 2,
    SetBounds_WORLD = 3,
}

mixin class ScriptBaseCustomEntity
{
    private float m_fDelay = 0.0f;
    private CMKEntityFuncs_enum m_iAffectedPlayer = CMKEntityFuncs_ACTIVATOR_ONLY;
    private string m_iszMaster();
    private string m_iszFilterTargetName;
    private int m_iFilterTargetName = 0;
    private string m_iszNewTargetName;
    private Vector minhullsize();
    private Vector maxhullsize();
    private USE_TYPE m_UTLatest = USE_TOGGLE, m_iUseType = USE_TOGGLE;

    bool ExtraKeyValues( const string& in szKey, const string& in szValue )
    {
        if( szKey == "m_fDelay" || szKey == "delay" )
        {
            m_fDelay = atof( szValue );
        }
        else if( szKey == "m_iAffectedPlayer" )
        {
            m_iAffectedPlayer = CMKEntityFuncs_enum( atoi( szValue ) );
        }
        else if( szKey == "m_iUseType" )
        {
            m_iUseType = itout( atoi( szValue ) );
        }
        else if( szKey == "master" )
        {
            this.m_iszMaster = szValue;
        }
        else if( szKey == "minhullsize" ) 
        {
            minhullsize = atov( szValue );
        }
        else if( szKey == "maxhullsize" ) 
        {
            maxhullsize = atov( szValue );
        }
        else if( szKey == "m_iszFilterTargetName" ) 
        {
            m_iszFilterTargetName = szValue;
        }
        else if( szKey == "m_iFilterTargetName" ) 
        {
            m_iFilterTargetName = atoi( szValue );
        }
        else if( szKey == "m_iszNewTargetName" )
        {
            m_iszNewTargetName = szValue;
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

    bool IsLockedByMaster()
    {
        if( !m_iszMaster.IsEmpty() && !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
        {
            if( self.GetCustomKeyvalues().HasKeyvalue( '$s_TriggerOnMaster' ) )
            {
                string iszTarget = self.GetCustomKeyvalues().GetKeyvalue( '$s_TriggerOnMaster' ).GetString();

                if( iszTarget != '' )
                {
                    mk.EntityFuncs.Trigger( iszTarget, GetMasterEntity(), self, USE_TOGGLE, 0.0f );
                }
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

    bool m_bSelfPrecached = false;

    void CustomModelSet( const string&in iszmodel = 'models/error.mdl' )
    {
        if( !m_bSelfPrecached )
        {
            g_EntityFuncs.Remove( self );
            return;
        }
        string newmodel = ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) );
        g_EntityFuncs.SetModel( self, newmodel );
    }

    void CustomModelPrecache( const string&in iszmodel = 'models/error.mdl' )
    {
        string newmodel = ( string( self.pev.model ).IsEmpty() ? iszmodel : string( self.pev.model ) );
        g_Game.PrecacheModel( newmodel );
        g_Game.PrecacheGeneric( newmodel );
        m_bSelfPrecached = true;
    }

    uint SetBBOX()
    {
        if( string( self.pev.model ).StartsWith( "*" ) && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, string( self.pev.model ) );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
            return SetBounds_BSP;
        }
        else if( minhullsize != g_vecZero && maxhullsize != g_vecZero )
        {
            if( self.pev.origin != g_vecZero )
            {
                g_EntityFuncs.SetOrigin( self, self.pev.origin );
                g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
                return SetBounds_ORIGIN;
            }
            g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
            return SetBounds_WORLD;
        }
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        return SetBounds_NONE;
    }

    bool IsFilteredByName( CBaseEntity@ pEntity )
    {
        if( pEntity !is null && !m_iszFilterTargetName.IsEmpty() )
        {
            array<string> m_aFiltered = m_iszFilterTargetName.Split( ";" );

            if(m_iFilterTargetName == 0 && m_aFiltered.find( string( pEntity.pev.targetname ) ) > 0
            or m_iFilterTargetName == 1 && m_aFiltered.find( string( pEntity.pev.targetname ) ) < 0 )
            {
                return true;
            }
        }
        return false;
    }
}

namespace ScriptBaseCustomEntity
{
    void MapInit()
    {
        g_Game.PrecacheModel( 'models/error.mdl' );
        g_Game.PrecacheGeneric( 'models/error.mdl' );
    }
}