
/*

INSTALL:

#include "mikk/env_scanner"

void MapInit()
{
	RegisterCScanner();
}

*/

void RegisterCScanner()
{
	g_CustomEntityFuncs.RegisterCustomEntity("CScanner", "env_scanner");
}

class CScanner : ScriptBaseEntity
{
    dictionary dictKeyValues;
    EHandle hPlayer;
    EHandle hMManager;

    bool IsLooking = false;
    bool IsTriggered = false;
    bool IsMMTriggered = false;

    float flDistance = 45.0f;
    float flTime = 5.0f;
    float flFOV = 0.85f;
    float flThink = 0.75f;
    float flLastTime = 0.0f;

    int   iDelay = 4;

    string FailSound = "null.wav"; 
    string ObservingSound = "null.wav";
    string TriggerSound = "null.wav";

    float HighesNumber()
    {
        array<string> KeyNames = dictKeyValues.getKeys();
        array<float> KeyValues;

        for(uint ui = 0; ui < KeyNames.length(); ++ui)
        {   
            KeyValues.insertLast(atof(string(dictKeyValues[KeyNames[ui]])));
        }

        KeyValues.sortDesc();

        g_Game.AlertMessage( at_console, ""+KeyValues[0]+"\n" );

        if( KeyValues.length() > 0 )
        {
            flThink = (flThink == 0.75f) ? (KeyValues[0] == 0.0) ? 0.1 : (KeyValues[0]/8) : flThink;
            return KeyValues[0]; 
        }
        else
            return flTime;
    }

    bool KeyValue(const string& in szKey, const string& in szValue)
    {
        if( szKey == "distance" )
            flDistance = atof( szValue );
        else if( szKey == "time" )
            flTime = atof( szValue );
        else if( szKey == "fov" ) 
            flFOV = atof( szValue );
        else if( szKey == "thinktime" )
            flThink = atof( szValue );
        else if( szKey == "delay" )
            iDelay = atoi( szValue );
        else if( szKey == "failsound" )
            FailSound = szValue;
        else if( szKey == "observingsound" )
            ObservingSound = szValue;
        else if( szKey == "triggersound" )
            TriggerSound = szValue;
        else
            dictKeyValues[szKey] = szValue;

        return true;
    }

	void Spawn() 
	{
        Precache();

		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NONE;

		g_EntityFuncs.SetOrigin( self, self.Center() );
    
        self.pev.nextthink = g_Engine.time + 0.1;

		BaseClass.Spawn();	
	}

    EHandle CreateMultiManager()
    {
        return g_EntityFuncs.CreateEntity( "multi_manager", dictKeyValues, true );
    }

    EHandle RemoveMultiManager()
    {
        if( hMManager )
            g_EntityFuncs.Remove( hMManager.GetEntity() );

        return EHandle(null);
    }

    void Precache()
    {
        g_SoundSystem.PrecacheSound( "sound" + FailSound );
        g_Game.PrecacheGeneric( "sound/" +  FailSound );

        g_SoundSystem.PrecacheSound( ObservingSound );
        g_Game.PrecacheGeneric( "sound/" + ObservingSound );

        g_SoundSystem.PrecacheSound( TriggerSound );
        g_Game.PrecacheGeneric( "sound/" + TriggerSound );
    }

    void Think()
    {
        // Usar scheduler SetTimeOut me daba error no se que xuxa
        if( IsTriggered )
		{
			IsLooking = false;
			hPlayer = null;
			hMManager = RemoveMultiManager();
			flLastTime = 0.0f;
			IsMMTriggered = false;
			IsTriggered = false;
			self.pev.nextthink = g_Engine.time + iDelay;
			return;
		}
        
		for(int i = 1; i <= g_Engine.maxClients; i++) 
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

            if( pPlayer is null || !pPlayer.IsAlive() || !pPlayer.IsConnected() || IsLooking ) 
                continue;

            if( (pPlayer.EyePosition() - self.Center()).Length() <= flDistance && self.FVisible( pPlayer, false ) && IsFacingCustom( pPlayer.pev, self.Center() ) )
            {
                IsLooking = true;
                hPlayer = EHandle(pPlayer);
                hMManager = CreateMultiManager();
                flLastTime = g_Engine.time + HighesNumber();
            }
        }

        CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());

        if( pPlayer !is null && pPlayer.IsAlive() && pPlayer.IsConnected() && IsLooking && !IsTriggered ) 
        {
            if( (pPlayer.EyePosition() - self.Center()).Length() <= flDistance && self.FVisible( pPlayer, false ) && IsFacingCustom( pPlayer.pev, self.Center() ) )
            {
                if( g_Engine.time >= flLastTime )
                {
                    IsTriggered = true;
                    g_EntityFuncs.FireTargets( self.pev.netname, pPlayer, self, USE_OFF );
                    g_EntityFuncs.FireTargets( self.pev.target, pPlayer, self, USE_TOGGLE );
                    g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, TriggerSound, VOL_NORM, ATTN_NORM );
                }       
                else
                {
                    if( !IsMMTriggered )
                    {
                        IsMMTriggered = true;
                        hMManager.GetEntity().Use( pPlayer, self, USE_TOGGLE );
                    }

                    g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, ObservingSound, VOL_NORM, ATTN_NORM );
                    g_EntityFuncs.FireTargets( self.pev.netname, pPlayer, self, USE_ON );
                }
            }
            else
            {
                IsLooking = false;
                hPlayer = null;
                hMManager = RemoveMultiManager();
                flLastTime = 0.0f;
                IsMMTriggered = false;

                g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, FailSound, VOL_NORM, ATTN_NORM );
            }
        }

        self.pev.nextthink = g_Engine.time + flThink;
    }

    bool IsFacingCustom( entvars_t@ pevTest, Vector reference )
    {
        Vector vecDir = (reference - pevTest.origin);
        vecDir.z = 0;
        vecDir = vecDir.Normalize();
        Vector angle = pevTest.v_angle;

        Vector forward, right, up;
        g_EngineFuncs.AngleVectors( angle, forward, right, up );

        bool ConditionForward = DotProduct(forward, vecDir) > flFOV;
        bool ConditionRight = DotProduct(right, vecDir) < 0.45 && DotProduct(right, vecDir) > -0.45;
        bool ConditionUp = DotProduct(up, vecDir) < 0.50 && DotProduct(up, vecDir) > 0;

        if( ConditionForward && ConditionRight && ConditionUp ) 
        {
            return true;
        }

        return false;
    }
}