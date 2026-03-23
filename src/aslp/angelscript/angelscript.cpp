#include <extdll.h>
#include <pm_defs.h>
#include <entity_state.h>
#include <meta_api.h>

#include "aslp.h"
#include "asext_api.h"
#include "angelscriptlib.h"

#include "angelscript/json.hpp"

#include "Hooks/AddToFullPack.hpp"
#include "Hooks/PM_Move.hpp"

angelhook_t g_AngelHook;

/**
 * @brief The plugin's namespace
**/
#define NAMESPACE_ASLP "aslp"

/**
 * @brief Global name space
**/
#define NAMESPACE_NONE ""

void RegisterAngelScriptMethods() 
{
ASEXT_RegisterScriptBuilderDefineCallback( []( CScriptBuilder* pScriptBuilder )
{
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "METAMOD_PLUGIN_ASLP" );

#if _DEBUG
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "METAMOD_DEBUG" );
#else
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "METAMOD_RELEASE" );
#endif

#if LINUX
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "LINUX" );
#elif _WINDOWS
ASEXT_CScriptBuilder_DefineWord( pScriptBuilder, "WINDOWS" );
#endif
} );

ASEXT_RegisterDocInitCallback( []( CASDocumentation* pASDoc ) 
{
ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_ASLP "::json" );
#pragma region Json
ASEXT_RegisterGlobalFunction( pASDoc, "Deserialize a string json-format into a dictionary. if str ends with .json it will be a file to open",
    "bool Deserialize( const string &in str, dictionary &out obj )", (void*)CASJsonDeserialize, asCALL_CDECL );
#pragma endregion

ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_ASLP );

#pragma region physent_t
ASEXT_RegisterObjectType( pASDoc, "Physics data",
    "PhysicalEntity", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectMethod( pASDoc, "Name of this entity",
    "PhysicalEntity", "string get_name() const property",
    (void*)( +[]( physent_t* pthis ) -> CString
    {
        CString result = CString();
        result.assign( pthis->name, strlen( pthis->name ) );
        return result;
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectMethod( pASDoc, "Is this entity a player?",
    "PhysicalEntity", "bool IsPlayer() const",
    (void*)( +[]( physent_t* pthis ) -> bool
    {
        return( strcmp( pthis->name, "player" ) == 0 );
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector origin", offsetof( physent_t, origin ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector mins", offsetof( physent_t, mins ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector maxs", offsetof( physent_t, maxs ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index or identifier associated with this physent.",
    "PhysicalEntity", "int info", offsetof( physent_t, info ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector angles", offsetof( physent_t, angles ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int solid", offsetof( physent_t, solid ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int skin", offsetof( physent_t, skin ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int rendermode", offsetof( physent_t, rendermode ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float frame", offsetof( physent_t, frame ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int sequence", offsetof( physent_t, sequence ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int controller", offsetof( physent_t, controller ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int blending", offsetof( physent_t, blending ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int movetype", offsetof( physent_t, movetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int takedamage", offsetof( physent_t, takedamage ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int blooddecal", offsetof( physent_t, blooddecal ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int team", offsetof( physent_t, team ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int classnumber", offsetof( physent_t, classnumber ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser1", offsetof( physent_t, iuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser2", offsetof( physent_t, iuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser3", offsetof( physent_t, iuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "int iuser4", offsetof( physent_t, iuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser1", offsetof( physent_t, fuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser2", offsetof( physent_t, fuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser3", offsetof( physent_t, fuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "float fuser4", offsetof( physent_t, fuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser1", offsetof( physent_t, vuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser2", offsetof( physent_t, vuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser3", offsetof( physent_t, vuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PhysicalEntity", "Vector vuser4", offsetof( physent_t, vuser4 ) );
#pragma endregion

#pragma region playermove_t
ASEXT_RegisterObjectType( pASDoc, "Player movement data",
    "PlayerMovement", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectMethod( pASDoc, "index of the player that is moving",
    "PlayerMovement", "int get_player() const property",
    (void*)( +[]( playermove_t* pthis ) -> int
    {
        return pthis->player_index + 1; // player_index starts from zero. let's not confuse scripters.
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectProperty( pASDoc, "Realtime on host, for reckoning duck timing",
    "PlayerMovement", "const float time", offsetof( playermove_t, time ) );

ASEXT_RegisterObjectProperty( pASDoc, "Duration of this frame",
    "PlayerMovement", "const float frametime", offsetof( playermove_t, frametime ) );

ASEXT_RegisterObjectProperty( pASDoc, "Vectors for angles",
    "PlayerMovement", "Vector forward", offsetof( playermove_t, forward ) );

ASEXT_RegisterObjectProperty( pASDoc, "Vectors for angles",
    "PlayerMovement", "Vector right", offsetof( playermove_t, right ) );

ASEXT_RegisterObjectProperty( pASDoc, "Vectors for angles",
    "PlayerMovement", "Vector up", offsetof( playermove_t, up ) );

ASEXT_RegisterObjectProperty( pASDoc, "Movement origin.",
    "PlayerMovement", "Vector origin", offsetof( playermove_t, origin ) );

ASEXT_RegisterObjectProperty( pASDoc, "Movement view angles.",
    "PlayerMovement", "Vector angles", offsetof( playermove_t, angles ) );

ASEXT_RegisterObjectProperty( pASDoc, "Angles before movement view angles were looked at.",
    "PlayerMovement", "Vector oldangles", offsetof( playermove_t, oldangles ) );

ASEXT_RegisterObjectProperty( pASDoc, "Current movement direction.",
    "PlayerMovement", "Vector velocity", offsetof( playermove_t, velocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "For waterjumping, a forced forward velocity so we can fly over lip of ledge.",
    "PlayerMovement", "Vector movedir", offsetof( playermove_t, movedir ) );

ASEXT_RegisterObjectProperty( pASDoc, "Velocity of the conveyor we are standing, e.g.",
    "PlayerMovement", "Vector basevelocity", offsetof( playermove_t, basevelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "Our eye position.",
    "PlayerMovement", "Vector view_ofs", offsetof( playermove_t, view_ofs ) );

ASEXT_RegisterObjectProperty( pASDoc, "Time we started duck",
    "PlayerMovement", "float flDuckTime", offsetof( playermove_t, flDuckTime ) );

ASEXT_RegisterObjectProperty( pASDoc, "In process of ducking or ducked already?",
    "PlayerMovement", "int bInDuck", offsetof( playermove_t, bInDuck ) );

ASEXT_RegisterObjectProperty( pASDoc, "Next time we can play a step sound",
    "PlayerMovement", "int flTimeStepSound", offsetof( playermove_t, flTimeStepSound ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iStepLeft", offsetof( playermove_t, iStepLeft ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float flFallVelocity", offsetof( playermove_t, flFallVelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector punchangle", offsetof( playermove_t, punchangle ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float flSwimTime", offsetof( playermove_t, flSwimTime ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float flNextPrimaryAttack", offsetof( playermove_t, flNextPrimaryAttack ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int effects", offsetof( playermove_t, effects ) );

ASEXT_RegisterObjectProperty( pASDoc, "FL_ONGROUND, FL_DUCKING, etc.",
    "PlayerMovement", "int flags", offsetof( playermove_t, flags ) );

ASEXT_RegisterObjectProperty( pASDoc, "0 = regular player hull, 1 = ducked player hull, 2 = point hull",
    "PlayerMovement", "int usehull", offsetof( playermove_t, usehull ) );

ASEXT_RegisterObjectProperty( pASDoc, "Our current gravity and friction.",
    "PlayerMovement", "float gravity", offsetof( playermove_t, gravity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float friction", offsetof( playermove_t, friction ) );

ASEXT_RegisterObjectProperty( pASDoc, "Buttons last usercmd",
    "PlayerMovement", "int oldbuttons", offsetof( playermove_t, oldbuttons ) );

ASEXT_RegisterObjectProperty( pASDoc, "Amount of time left in jumping out of water cycle.",
    "PlayerMovement", "float waterjumptime", offsetof( playermove_t, waterjumptime ) );

ASEXT_RegisterObjectProperty( pASDoc, "Are we a dead player?",
    "PlayerMovement", "const int dead", offsetof( playermove_t, dead ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "const int deadflag", offsetof( playermove_t, deadflag ) );

ASEXT_RegisterObjectProperty( pASDoc, "Should we use spectator physics model?",
    "PlayerMovement", "const int spectator", offsetof( playermove_t, spectator ) );

ASEXT_RegisterObjectProperty( pASDoc, "Our movement type, NOCLIP, WALK, FLY",
    "PlayerMovement", "int movetype", offsetof( playermove_t, movetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index the player is standing on (-1 if none).",
    "PlayerMovement", "int onground", offsetof( playermove_t, onground ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int waterlevel", offsetof( playermove_t, waterlevel ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int watertype", offsetof( playermove_t, watertype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int oldwaterlevel", offsetof( playermove_t, oldwaterlevel ) );

ASEXT_RegisterObjectMethod( pASDoc, "Texture name the player is currently standing at",
    "PlayerMovement", "string get_TextureName() property",
    (void*)( +[]( playermove_t* pthis ) -> CString
    {
        CString result = CString();
        result.assign( pthis->sztexturename, strlen( pthis->sztexturename ) );
        return result;
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectProperty( pASDoc, "Texture type the player is currently standing at",
    "PlayerMovement", "const char TextureType", offsetof( playermove_t, chtexturetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float maxspeed", offsetof( playermove_t, maxspeed ) );

ASEXT_RegisterObjectProperty( pASDoc, "Player specific maxspeed",
    "PlayerMovement", "float clientmaxspeed", offsetof( playermove_t, clientmaxspeed ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser1", offsetof( playermove_t, iuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser2", offsetof( playermove_t, iuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser3", offsetof( playermove_t, iuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "int iuser4", offsetof( playermove_t, iuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser1", offsetof( playermove_t, fuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser2", offsetof( playermove_t, fuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser3", offsetof( playermove_t, fuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "float fuser4", offsetof( playermove_t, fuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser1", offsetof( playermove_t, vuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser2", offsetof( playermove_t, vuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser3", offsetof( playermove_t, vuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "PlayerMovement", "Vector vuser4", offsetof( playermove_t, vuser4 ) );

// physents
ASEXT_RegisterObjectMethod( pASDoc, "Get the number of physical entity in collision list.",
    "PlayerMovement", "uint get_numphysent()",
    (void*)( +[]( playermove_t* pthis ) -> int {
        return pthis->numphysent;
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectMethod( pASDoc, "Set the number of physical entity in collision list.",
    "PlayerMovement", "void set_numphysent( uint size )",
    (void*)( +[]( playermove_t* pthis, int size ) {
        CASPM_ContainerSizeSet( &pthis->numphysent, MAX_PHYSENTS_10152, size );
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectMethod( pASDoc, "Get the physical entity in collision list for the given index.",
    "PlayerMovement", NAMESPACE_ASLP "::PhysicalEntity@ get_physents( uint index )",
    (void*)( +[]( playermove_t* pthis, int index ) -> physent_t* {
        return CASPM_ContainerGet( pthis->physents, MAX_PHYSENTS_10152, index );
    } ), asCALL_CDECL_OBJFIRST );

ASEXT_RegisterObjectMethod( pASDoc, "Set the physical entity in collision list for the given index.",
    "PlayerMovement", "void set_physents( " NAMESPACE_ASLP "::PhysicalEntity@ entity, uint index )",
    (void*)( +[]( playermove_t* pthis, physent_t* entity, int index ) {
        CASPM_ContainerSet( pthis->physents, MAX_PHYSENTS_10152, index, entity );
    } ), asCALL_CDECL_OBJFIRST );

#pragma endregion

#pragma region MetaResult
ASEXT_RegisterEnum( pASDoc, "Flags returned by a plugin's api function.",
    "MetaResult", 0 );
ASEXT_RegisterEnumValue( pASDoc, "Plugin didn't take any action",
    "MetaResult", "Ignored", static_cast<int>( META_RES::MRES_IGNORED ) );
ASEXT_RegisterEnumValue( pASDoc, "Plugin did something, but real function should still be called",
    "MetaResult", "Handled", static_cast<int>( META_RES::MRES_HANDLED ) );
ASEXT_RegisterEnumValue( pASDoc, "Call real function, but use my return value",
    "MetaResult", "Override", static_cast<int>( META_RES::MRES_OVERRIDE ) );
ASEXT_RegisterEnumValue( pASDoc, "Skip real function and use my return value",
    "MetaResult", "Supercede", static_cast<int>( META_RES::MRES_SUPERCEDE ) );
#pragma endregion

#pragma region entity_state_t
ASEXT_RegisterObjectType(pASDoc, "Entity state is used for the baseline and for delta compression of a packet of entities that is sent to a client.",
    "EntityState", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectProperty( pASDoc, "Type classification used by the engine (normal entity, player, beam, etc.). Mostly internal; affects how the client interprets the state.",
    "EntityState", "int entityType", offsetof( entity_state_t, entityType ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index",
    "EntityState", "int number", offsetof( entity_state_t, number ) );

ASEXT_RegisterObjectProperty( pASDoc, "Server time when this state was generated. Used for interpolation and networking.",
    "EntityState", "float msg_time", offsetof( entity_state_t, msg_time ) );

ASEXT_RegisterObjectProperty( pASDoc, "Incrementing message sequence number. Helps delta compression determine differences.",
    "EntityState", "int messagenum", offsetof( entity_state_t, messagenum ) );

ASEXT_RegisterObjectProperty( pASDoc, "Position in world",
    "EntityState", "Vector origin", offsetof( entity_state_t, origin ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity angles",
    "EntityState", "Vector angles", offsetof( entity_state_t, angles ) );

ASEXT_RegisterObjectProperty( pASDoc, "Index into the precached model table. Determines which .mdl, .spr, or brush model to render.",
    "EntityState", "int modelindex", offsetof( entity_state_t, modelindex ) );

ASEXT_RegisterObjectProperty( pASDoc, "Model animation sequence number.",
    "EntityState", "int sequence", offsetof( entity_state_t, sequence ) );

ASEXT_RegisterObjectProperty( pASDoc, "Current animation frame.",
    "EntityState", "float frame", offsetof( entity_state_t, frame ) );

ASEXT_RegisterObjectProperty( pASDoc, "Color remap index",
    "EntityState", "int colormap", offsetof( entity_state_t, colormap ) );

ASEXT_RegisterObjectProperty( pASDoc, "Skin index inside the model.",
    "EntityState", "int16 skin", offsetof( entity_state_t, skin ) );

ASEXT_RegisterObjectProperty( pASDoc, "Bodygroup selection.",
    "EntityState", "int body", offsetof( entity_state_t, body ) );

ASEXT_RegisterObjectProperty( pASDoc, "Solid mode (How the client interacts with this entity)",
    "EntityState", "int16 solid", offsetof( entity_state_t, solid ) );

ASEXT_RegisterObjectProperty( pASDoc, "Rendering effects flag",
    "EntityState", "int effects", offsetof( entity_state_t, effects ) );

ASEXT_RegisterObjectProperty( pASDoc, "Model/Sprite scale multiplier",
    "EntityState", "float scale", offsetof( entity_state_t, scale ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int8 eflags", offsetof( entity_state_t, eflags ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render mode",
    "EntityState", "int rendermode", offsetof( entity_state_t, rendermode ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render ammount",
    "EntityState", "int renderamt", offsetof( entity_state_t, renderamt ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render color",
    "EntityState", "Vector rendercolor", offsetof( entity_state_t, rendercolor ) );

ASEXT_RegisterObjectProperty( pASDoc, "Render effect",
    "EntityState", "int renderfx", offsetof( entity_state_t, renderfx ) );

ASEXT_RegisterObjectProperty( pASDoc, "Move type",
    "EntityState", "int movetype", offsetof( entity_state_t, movetype ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float animtime", offsetof( entity_state_t, animtime ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float framerate", offsetof( entity_state_t, framerate ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector velocity", offsetof( entity_state_t, velocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector mins", offsetof( entity_state_t, mins ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector maxs", offsetof( entity_state_t, maxs ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int aiment", offsetof( entity_state_t, aiment ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int owner", offsetof( entity_state_t, owner ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float friction", offsetof( entity_state_t, friction ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float gravity", offsetof( entity_state_t, gravity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int team", offsetof( entity_state_t, team ) );

ASEXT_RegisterObjectProperty( pASDoc, "Player-specific classification",
    "EntityState", "int playerclass", offsetof( entity_state_t, playerclass ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int health", offsetof( entity_state_t, health ) );

ASEXT_RegisterObjectProperty( pASDoc, "Player-specific spectator. 0/1 false/true",
    "EntityState", "int spectator", offsetof( entity_state_t, spectator ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int weaponmodel", offsetof( entity_state_t, weaponmodel ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int gaitsequence", offsetof( entity_state_t, gaitsequence ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector basevelocity", offsetof( entity_state_t, basevelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int usehull", offsetof( entity_state_t, usehull ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int oldbuttons", offsetof( entity_state_t, oldbuttons ) );

ASEXT_RegisterObjectProperty( pASDoc, "Entity index the player is standing on (-1 if none).",
    "EntityState", "int onground", offsetof( entity_state_t, onground ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iStepLeft", offsetof( entity_state_t, iStepLeft ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float flFallVelocity", offsetof( entity_state_t, flFallVelocity ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fov", offsetof( entity_state_t, fov ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int weaponanim", offsetof( entity_state_t, weaponanim ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser1", offsetof( entity_state_t, iuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser2", offsetof( entity_state_t, iuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser3", offsetof( entity_state_t, iuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "int iuser4", offsetof( entity_state_t, iuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser1", offsetof( entity_state_t, fuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser2", offsetof( entity_state_t, fuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser3", offsetof( entity_state_t, fuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "float fuser4", offsetof( entity_state_t, fuser4 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser1", offsetof( entity_state_t, vuser1 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser2", offsetof( entity_state_t, vuser2 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser3", offsetof( entity_state_t, vuser3 ) );

ASEXT_RegisterObjectProperty( pASDoc, "",
    "EntityState", "Vector vuser4", offsetof( entity_state_t, vuser4 ) );
#pragma endregion

#pragma region addtofullpack_t
ASEXT_RegisterObjectType( pASDoc, "Entity networking packet.",
    "ClientPacket", 0, asOBJ_REF | asOBJ_NOCOUNT );

ASEXT_RegisterObjectProperty( pASDoc, "Entity state being processed.",
    "ClientPacket", NAMESPACE_ASLP "::EntityState@ state", offsetof( addtofullpack_t, state ) );

ASEXT_RegisterObjectProperty( pASDoc, "The index of the entity currently being considered for transmission.",
    "ClientPacket", "const int index", offsetof( addtofullpack_t, index ) );

ASEXT_RegisterObjectProperty( pASDoc, "The entity currently being considered for transmission.",
    "ClientPacket", "edict_t@ entity", offsetof( addtofullpack_t, entity ) );

ASEXT_RegisterObjectProperty( pASDoc, "The client receiving this packet.",
    "ClientPacket", "edict_t@ host", offsetof( addtofullpack_t, host ) );

ASEXT_RegisterObjectProperty( pASDoc, "Flags describing properties of the receiving client.",
    "ClientPacket", "int hostFlags", offsetof( addtofullpack_t, hostFlags ) );

ASEXT_RegisterObjectProperty( pASDoc, "The index of the client receiving this packet.",
    "ClientPacket", "const int playerIndex", offsetof( addtofullpack_t, playerIndex ) );
#pragma endregion

ASEXT_SetDefaultNamespace( pASDoc, NAMESPACE_NONE );
    } );
}

#define CREATE_AS_HOOK(item, des, tag, name, arg) g_AngelHook.item=ASEXT_RegisterHook(des,StopMode_CALL_ALL,2,ASFlag_MapScript|ASFlag_Plugin,tag,name,arg)

void RegisterAngelScriptHooks()
{
CREATE_AS_HOOK( pClientCommandHook, "Pre call of ClientCommand. See CEngineFuncs Cmd_Args, Cmd_Argv and Cmd_Argc",
    NAMESPACE_ASLP, "ClientCommand", "CBasePlayer@ player, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPlayerUserInfoChanged, "Pre call before a player info changed",
    NAMESPACE_ASLP, "UserInfoChanged", "CBasePlayer@ player, string buffer, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPreMovement, "Called before the Server-side logic of the player movement.",
    NAMESPACE_ASLP, "PlayerPreMovement", NAMESPACE_ASLP "::PlayerMovement@ &out movement, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPostMovement, "Called after the Server-side logic of the player movement.",
    NAMESPACE_ASLP, "PlayerPostMovement", NAMESPACE_ASLP "::PlayerMovement@ &out movement, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPreAddToFullPack, "Called when the server is about to network a entity to a client",
    NAMESPACE_ASLP, "PreAddToFullPack", NAMESPACE_ASLP "::ClientPacket@ packet, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pPostAddToFullPack, "Called when the server is about to network a entity to a client",
    NAMESPACE_ASLP, "PostAddToFullPack", NAMESPACE_ASLP "::ClientPacket@ packet, " NAMESPACE_ASLP "::MetaResult &out meta_result" );

CREATE_AS_HOOK( pShouldCollide, "Called whatever a entity is touched by another. Set Collide to false to prevent the interaction.",
    NAMESPACE_ASLP, "ShouldCollide", "CBaseEntity@ touched, CBaseEntity@ other, " NAMESPACE_ASLP "::MetaResult &out meta_result, bool &out Collide" );

CREATE_AS_HOOK(pPlayerPostTakeDamage, "Pre call before a player took damage", "Player", "PlayerPostTakeDamage", "DamageInfo@ info");

CREATE_AS_HOOK( pPlayerTakeHealth, "Pre call before a player is healed",
    NAMESPACE_ASLP, "PlayerTakeHealth", "CBasePlayer@ player, float &out health, int &out bitsDamage" );

CREATE_AS_HOOK( pEntityIRelationship, "Pre call before checking relation", "Entity", "IRelationship", "CBaseEntity@ pEntity, CBaseEntity@ pOther, bool param, int& out newValue");

CREATE_AS_HOOK( pMonsterTraceAttack,
    "Pre call before a monster trace attack",
    "Monster", "MonsterTraceAttack", "CBaseMonster@ pMonster, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType");
CREATE_AS_HOOK( pMonsterPostTakeDamage,
    "Post call after a monster took damage",
    "Monster", "MonsterPostTakeDamage", "DamageInfo@ info"
);

CREATE_AS_HOOK( pBreakableTraceAttack,
    "Pre call before a breakable trace attack",
    "Entity", "BreakableTraceAttack", "CBaseEntity@ pBreakable, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType"
);

CREATE_AS_HOOK( pBreakableKilled,
    "Pre call before a breakable died",
    "Entity", "BreakableDie", "CBaseEntity@ pBreakable, entvars_t@ pevAttacker, int iGib"
);

CREATE_AS_HOOK( pBreakableTakeDamage,
    "Pre call before a breakable took damage",
    "Entity", "BreakableTakeDamage", "DamageInfo@ info"
);

CREATE_AS_HOOK( pGrappleCheckMonsterType,
    "Pre call before Weapon Grapple checking monster type",
    "Weapon", "GrappleGetMonsterType", "CBaseEntity@ pThis, CBaseEntity@ pEntity, uint& out flag"
);
}
#undef CREATE_AS_HOOK

void CloseAngelScriptsItem() 
{
}
