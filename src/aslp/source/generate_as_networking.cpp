#include "generate_as_networking.h"

void CGenerateNetworkMessageAPI :: Initialize( const asIScriptEngine* engine )
{
}

void CGenerateNetworkMessageAPI :: Begin( int msg_dest, int msg_type, const float *origin, edict_t *edict )
{
}

CGenerateNetworkMessageAPI* g_NetworkMessageAPI;

void GenerateScriptNetworking( const asIScriptEngine* engine )
{
	g_NetworkMessageAPI = new CGenerateNetworkMessageAPI();
}
