/*
    This entity 

INSTALL:

#include "mikk/entities/multiple_paths"

void MapInit()
{
    RegisterCBaseMultiplePaths();
}
*/

void RegisterCBaseMultiplePaths() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "multiple_path_set", "multiple_path_set" );
}

enum trigger_checkpoint_flags
{
    SF_MUPATH_CONTROLL = 1 << 0
}

class multiple_path_set : ScriptBaseEntity
{
    void Spawn()
    {
        if( self.pev.health <= 0 )
            self.pev.health = 80;

        BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
    {
        if( string( self.pev.target ) != "!activator" && pActivator !is null && pActivator.IsPlayer() )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

            SetSpawn( pPlayer );
        }
        else
        {
            for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null )
                {
                    SetSpawn( pPlayer );
                }
            }
        }
    }

    void Spawn()
    {
        self.pev.solid = SOLID_NOT;
        self.pev.effects |= EF_NODRAW;
        self.pev.movetype = MOVETYPE_NONE;
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
        BaseClass.Spawn();
    }

    void Touch( CBaseEntity@ pOther )
    {
        if( pOther !is null and pOther.IsPlayer() )
            SetSpawn( pOther );
    }
    
    void SetSpawn()
    {
    
        if( self.pev.SpawnFlagBitSet( SF_MUPATH_CONTROLL ) )
            SetThink( ThinkFunction( this.TriggerThink ) );
    }

    void TriggerThink()
    {
        if( self.pev.health == 0 )
        {
            // Cambiar nivel g_Engine.mapname
        }
        self.pev.nextthink = g_Engine.time + 1.0f;
    }
}




//Diccionario donde se guarda los SteamID's + el nombre del camino elegido
dictionary dicPlayersPaths;
//Array dodne se guardan todos los trigger_different_paths que tengan el spawnflag en 1
array<EHandle> hDPSpawns;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "SEXO? | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://xvideos.com | https://github.com/Gaftherman" ); //(Sexo github)n't

    g_Hooks.RegisterHook( Hooks::Player::GetPlayerSpawnSpot, @GetPlayerSpawnSpot );
}

void MapInit()
{
    RegisterTriggerDifferentPaths();
}

void MapActivate()
{
    hDPSpawns.resize(0);

    CBaseEntity@ pDPFind = null;
    while( ( @pDPFind = g_EntityFuncs.FindEntityByClassname( pDPFind, "trigger_different_paths" ) ) !is null )
    {
        if( pDPFind.pev.SpawnFlagBitSet(1) )
        {
            hDPSpawns.insertLast( pDPFind );
        }
    }
}

HookReturnCode GetPlayerSpawnSpot( CBasePlayer@ pPlayer, CBaseEntity@& out ppEntSpawnSpot ) 
{
    if( pPlayer is null || hDPSpawns.length() <= 0 )
        return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    string Saved; dicPlayersPaths.get(SteamID, Saved);

    if( Saved.IsEmpty() || !dicPlayersPaths.exists( SteamID ) )
    {
        g_Game.AlertMessage( at_console, "No tienes ningun spawn asigado; has sido asigando a uno aleatoriamente.\n" );
        CBaseEntity@ pDPRandom = hDPSpawns[uint(Math.RandomLong(0, hDPSpawns.length()-1))].GetEntity();
        CBaseEntity@ pDPOwner = g_EntityFuncs.Instance( pDPRandom.pev.owner );
        @ppEntSpawnSpot = @pDPOwner;

        dicPlayersPaths.set(SteamID, string(pDPRandom.pev.targetname));
        g_Game.AlertMessage( at_console, "Tu spawn es "+string(pDPRandom.pev.targetname)+"\n" );

        return HOOK_HANDLED;
    }
    else
    {
        g_Game.AlertMessage( at_console, "Mi target es "+Saved+"\n" );

        for( uint ui = 0; ui < hDPSpawns.length(); ++ui ) 
        {
            if( hDPSpawns[ui].GetEntity().pev.targetname == Saved )
            {
                @ppEntSpawnSpot = @g_EntityFuncs.Instance( hDPSpawns[ui].GetEntity().pev.owner );
                return HOOK_HANDLED;
            }
        }

        g_Game.AlertMessage( at_console, "El camino previamente seleccionado no ha sido encontrado.\n" );
        g_Game.AlertMessage( at_console, "Se le asignara uno aleatorio...\n" );

        CBaseEntity@ pDPRandom = hDPSpawns[uint(Math.RandomLong(0, hDPSpawns.length()-1))].GetEntity();
        CBaseEntity@ pDPOwner = g_EntityFuncs.Instance( pDPRandom.pev.owner );
        @ppEntSpawnSpot = @pDPOwner;

        dicPlayersPaths.set(SteamID, string(pDPRandom.pev.targetname));
        g_Game.AlertMessage( at_console, "Tu spawn es "+string(pDPRandom.pev.targetname)+"\n" );

        return HOOK_HANDLED;
    }
}

class trigger_different_paths : ScriptBaseEntity
{
    private CBaseEntity@ pMyOwner
    {
        get const { return g_EntityFuncs.Instance( self.pev.owner ); }
    }
    
    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        if( szKey == "minhullsize" )
        {
            g_Utility.StringToVector( self.pev.vuser1, szValue );
            return true;
        }
        else if( szKey == "maxhullsize" )
        {
            g_Utility.StringToVector( self.pev.vuser2, szValue );
            return true;
        }

        return BaseClass.KeyValue( szKey, szValue );
    }

    void Spawn()
    {
        self.pev.movetype     = MOVETYPE_NONE;
        self.pev.solid         = SOLID_NOT;
        self.pev.effects    = EF_NODRAW;

        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
        g_EntityFuncs.SetModel( self, self.pev.model );

        if( self.pev.SpawnFlagBitSet(1) )
        {
            CreateSpawnPoint();
        }
        else if( self.pev.SpawnFlagBitSet(3) )
        {
            dicPlayersPaths.deleteAll();
        }
        else
        {
            SetUse(UseFunction(this.SetUse));
            SetThink(ThinkFunction(this.SetThink));

            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }

    void CreateSpawnPoint()
    {
        CBaseEntity@ pRespawnPoint = g_EntityFuncs.Create( "info_player_deathmatch", self.Center(), self.pev.angles, false, self.edict() );

        @self.pev.owner = pRespawnPoint.pev.pContainingEntity;

        g_Game.AlertMessage( at_console, "My owner es "+pMyOwner.pev.classname+"\n" );
    }

    void SetUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f )
    {
        if( pActivator is null || !pActivator.IsPlayer() )
            return;

         SavePath( cast<CBasePlayer@>(pActivator) );
    }

    void SetThink()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                continue;

            if( self.Intersects(pPlayer) ) //UTILS::InsideZone( pPlayer, self ) my balls 
            {
                SavePath( pPlayer );   
            }
        }

        self.pev.nextthink = g_Engine.time + 0.1;   
    }

    void SavePath( CBasePlayer@ pPlayer )
    {
        string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        string Saved; dicPlayersPaths.get(SteamID, Saved);

        if( Saved != string(self.pev.target) )
        {
            dicPlayersPaths.set(SteamID, string(self.pev.target));

            if( Saved.IsEmpty() )
            {
                g_Game.AlertMessage( at_console, "El jugador con la SteamID "+SteamID+" se le guardo en el camino "+string(self.pev.target)+"\n" );
            }
            else
            {
                g_Game.AlertMessage( at_console, "El jugador con la SteamID "+SteamID+" sobreescribio su camino anterio y ahora es "+string(self.pev.target)+"\n" );
            }
        }  
    }
}

void RegisterTriggerDifferentPaths()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "trigger_different_paths", "trigger_different_paths" );
    g_Game.PrecacheOther( "trigger_different_paths" );
}